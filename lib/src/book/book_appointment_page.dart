import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'booked_successfully_page.dart';
import 'select_date_time_page.dart';

class BookAppointmentPage extends StatefulWidget {
  const BookAppointmentPage({super.key});

  @override
  State<BookAppointmentPage> createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  DateTime? _selectedDay;
  String? _selectedTime;
  String? selectedDoctorId;
  String? selectedDoctorName;
  List<Map<String, dynamic>> _doctors = [];

  // Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  // Error messages
  String? errorName;
  String? errorPhone;
  String? errorEmail;

  final _auth = FirebaseAuth.instance;

  List<String> timeSlots = [
    "05:00 PM",
    "06:00 PM",
    "07:00 PM",
    "08:00 PM",
    "09:00 PM",
    "10:00 PM",
    "11:00 PM",
    "12:00 PM",
  ];

  Map<String, bool> bookedSlots = {}; // Time -> booked?

  @override
  void initState() {
    super.initState();
    _loadDoctors();
    // Pre-fill email if logged in
    final currentUser = _auth.currentUser;
    if (currentUser != null && currentUser.email != null) {
      _emailController.text = currentUser.email!;
    }
  }

  // --- MODIFICATION 3: Enforce doctor selection before navigation and pass data ---
  Future<void> _selectDateTime() async {
    // Check if a doctor has been selected
    if (selectedDoctorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a doctor first")),
      );
      return;
    }

    // Pass the selected doctor's ID and Name to the time selection page
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SelectDateTimePage(
          doctorId: selectedDoctorId!,
          doctorName: selectedDoctorName!,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedDay = result['date'];
        _selectedTime = result['time'];
      });
      // We no longer need to call _fetchBookedSlots here since the data is now selected.
    }
  }

  // NOTE: This function is only needed when the doctor dropdown changes, 
  // not after returning from SelectDateTimePage. 
  // We keep it as is since it is called on doctor selection.
  Future<void> _fetchBookedSlots() async {
    if (_selectedDay == null || selectedDoctorId == null) return;

    final dateStr =
        "${_selectedDay!.year}-${_selectedDay!.month.toString().padLeft(2, '0')}-${_selectedDay!.day.toString().padLeft(2, '0')}";

    final snapshot = await FirebaseFirestore.instance
        .collection('appointments')
        .where('date', isEqualTo: dateStr)
        .where('doctorId', isEqualTo: selectedDoctorId)
        .get();

    final Map<String, bool> slots = {};
    for (var slot in timeSlots) {
      slots[slot] = snapshot.docs.any((doc) => doc['time'] == slot);
    }

    setState(() {
      bookedSlots = slots;
    });
  }

  Future<void> _loadDoctors() async {
    try {
      final doctorsSnap = await FirebaseFirestore.instance
          .collection('doctors')
          .orderBy('createdAt')
          .get();

      setState(() {
        _doctors = doctorsSnap.docs
            .map((d) => {
                  'id': d.id,
                  'name': d.data()['fullName'] ?? 'Doctor',
                })
            .toList();
      });
    } catch (e) {
      // In a real app, use a more visible error reporting tool
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load doctors: $e')),
      );
    }
  }

  Future<void> _bookAppointment() async {
    final currentUser = _auth.currentUser;

    // Reset errors
    setState(() {
      errorName = null;
      errorPhone = null;
      errorEmail = null;
    });

    // --- VALIDATION ---
    if (_nameController.text.trim().isEmpty) {
      setState(() => errorName = "Name is required");
      return;
    }
    if (!RegExp(r"^[a-zA-Z ]+$").hasMatch(_nameController.text.trim())) {
      setState(() => errorName = "Name must contain letters only");
      return;
    }

    if (_phoneController.text.trim().isEmpty) {
      setState(() => errorPhone = "Phone number is required");
      return;
    }
    if (!RegExp(r"^[0-9]+$").hasMatch(_phoneController.text.trim())) {
      setState(() => errorPhone = "Phone must contain digits only");
      return;
    }
    if (_phoneController.text.trim().length != 11) {
      setState(() => errorPhone = "Phone must be 11 digits");
      return;
    }

    if (currentUser == null) {
      setState(() => errorEmail = "You must be logged in");
      return;
    }

    if (_emailController.text.trim().isEmpty) {
      setState(() => errorEmail = "Email is required");
      return;
    }

    if (_emailController.text.trim().toLowerCase() !=
        currentUser.email!.toLowerCase()) {
      setState(() => errorEmail = "Email does not match your account");
      return;
    }

    if (_selectedDay == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select date & time")),
      );
      return;
    }

    if (selectedDoctorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a doctor")),
      );
      return;
    }

    // Save
    final dateStr =
        "${_selectedDay!.year}-${_selectedDay!.month.toString().padLeft(2, '0')}-${_selectedDay!.day.toString().padLeft(2, '0')}";

    final appointmentsRef = FirebaseFirestore.instance.collection('appointments');

    try {
      // --- FINAL CONCURRENCY CHECK: Must check against the selected doctor ---
      final existing = await appointmentsRef
          .where('date', isEqualTo: dateStr)
          .where('time', isEqualTo: _selectedTime)
          .where('doctorId', isEqualTo: selectedDoctorId) // Correct filter
          .get();

      if (existing.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('This time slot is already booked for this doctor')),
        );
        return;
      }

      await appointmentsRef.doc().set({
        'patientId': currentUser.uid,
        'patientName': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': currentUser.email,
        'date': dateStr,
        'time': _selectedTime,
        'doctorId': selectedDoctorId,
        'doctorName': selectedDoctorName,
        'timestamp': Timestamp.fromDate(_selectedDay!),
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const BookedSuccessfullyPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffeef0f8),
      body: Center(
        child: Container(
          width: 350,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(25),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                const Text(
                  "Book an appointment",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Color(0xff1F3C88),
                  ),
                ),
                const SizedBox(height: 15),

                // Doctor dropdown
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "Select Doctor",
                    filled: true,
                    fillColor: const Color(0xffe8eaf3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  value: selectedDoctorId,
                  items: _doctors
                      .map(
                        (doc) => DropdownMenuItem<String>(
                          value: doc['id'],
                          child: Text(doc['name']),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      selectedDoctorId = val;
                      selectedDoctorName = _doctors
                          .firstWhere((d) => d['id'] == val)['name']
                          .toString();
                      // Clear previously selected time when doctor changes
                      _selectedDay = null;
                      _selectedTime = null;
                    });
                  },
                  hint: const Text("Choose doctor"),
                ),
                const SizedBox(height: 15),

                _customField("Full Name", _nameController, errorText: errorName),
                _customField("Phone Number", _phoneController,
                    errorText: errorPhone),
                _customField("Email", _emailController, errorText: errorEmail),

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Schedules",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    InkWell(
                      onTap: _selectDateTime,
                      child: const Text(
                        "View >",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(0xffe8eaf3),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month,
                          color: Color(0xff1F3C88), size: 30),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _selectedDay == null || _selectedTime == null
                              ? "No Selected time"
                              : "${_selectedDay!.weekdayName}, ${_selectedDay!.monthName} ${_selectedDay!.day}\nDoctor: ${selectedDoctorName ?? 'Not selected'}\n$_selectedTime",
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff1F3C88),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: _bookAppointment,
                    child: const Text(
                      "Book",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _customField(String label, TextEditingController controller,
      {String? errorText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 7),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xffe8eaf3),
            contentPadding: const EdgeInsets.symmetric(horizontal: 15),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            errorText: errorText,
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }
}

// Extensions for month/day names (retained)
extension on DateTime {
  String get monthName {
    const months = [
      "",
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];
    return months[month];
  }

  String get weekdayName {
    const days = [
      "",
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday"
    ];
    return days[weekday];
  }
}