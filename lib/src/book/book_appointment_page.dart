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
  }

  Future<void> _selectDateTime() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SelectDateTimePage(),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedDay = result['date'];
        _selectedTime = result['time'];
      });
      _assignDoctorByDay();
      _fetchBookedSlots();
    }
  }

  // Assign doctor automatically by day
  Future<void> _assignDoctorByDay() async {
    if (_selectedDay == null) return;

    int weekday = _selectedDay!.weekday;

    final doctorsSnap = await FirebaseFirestore.instance
        .collection('doctors')
        .orderBy('createdAt')
        .get();

    if (doctorsSnap.docs.isEmpty) return;

    if (weekday == 6 || weekday == 7) {
      selectedDoctorId = doctorsSnap.docs[0].id;
      selectedDoctorName = doctorsSnap.docs[0]['fullName'];
    } else if (weekday == 1) {
      selectedDoctorId =
          doctorsSnap.docs.length > 1 ? doctorsSnap.docs[1].id : doctorsSnap.docs[0].id;
      selectedDoctorName =
          doctorsSnap.docs.length > 1 ? doctorsSnap.docs[1]['fullName'] : doctorsSnap.docs[0]['fullName'];
    } else if (weekday == 3 || weekday == 4) {
      selectedDoctorId =
          doctorsSnap.docs.length > 2 ? doctorsSnap.docs[2].id : doctorsSnap.docs[0].id;
      selectedDoctorName =
          doctorsSnap.docs.length > 2 ? doctorsSnap.docs[2]['fullName'] : doctorsSnap.docs[0]['fullName'];
    } else if (weekday == 5) {
      selectedDoctorId =
          doctorsSnap.docs.length > 3 ? doctorsSnap.docs[3].id : doctorsSnap.docs[0].id;
      selectedDoctorName =
          doctorsSnap.docs.length > 3 ? doctorsSnap.docs[3]['fullName'] : doctorsSnap.docs[0]['fullName'];
    } else if (weekday == 2) {
      selectedDoctorId =
          doctorsSnap.docs.length > 4 ? doctorsSnap.docs[4].id : doctorsSnap.docs[0].id;
      selectedDoctorName =
          doctorsSnap.docs.length > 4 ? doctorsSnap.docs[4]['fullName'] : doctorsSnap.docs[0]['fullName'];
    } 
    
  }

  Future<void> _fetchBookedSlots() async {
    if (_selectedDay == null) return;

    final dateStr =
        "${_selectedDay!.year}-${_selectedDay!.month.toString().padLeft(2, '0')}-${_selectedDay!.day.toString().padLeft(2, '0')}";

    final snapshot = await FirebaseFirestore.instance
        .collection('appointments')
        .where('date', isEqualTo: dateStr)
        .get();

    final Map<String, bool> slots = {};
    for (var slot in timeSlots) {
      slots[slot] = snapshot.docs.any((doc) => doc['time'] == slot);
    }

    setState(() {
      bookedSlots = slots;
    });
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

    if (_emailController.text.trim().toLowerCase() != currentUser.email!.toLowerCase()) {
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
        const SnackBar(content: Text("No doctor assigned")),
      );
      return;
    }

    // Save
    final dateStr =
        "${_selectedDay!.year}-${_selectedDay!.month.toString().padLeft(2, '0')}-${_selectedDay!.day.toString().padLeft(2, '0')}";

    final appointmentsRef = FirebaseFirestore.instance.collection('appointments');

    try {
      final existing = await appointmentsRef
          .where('date', isEqualTo: dateStr)
          .where('time', isEqualTo: _selectedTime)
          .get();

      if (existing.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This time slot is already booked')),
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

                _customField("Full Name", _nameController, errorText: errorName),
                _customField("Phone Number", _phoneController, errorText: errorPhone),
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
                              : "${_selectedDay!.weekdayName}, ${_selectedDay!.monthName} ${_selectedDay!.day}\nDoctor: $selectedDoctorName\n$_selectedTime",
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

  Widget _customField(String label, TextEditingController controller, {String? errorText}) {
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

// Extensions for month/day names
extension on DateTime {
  String get monthName {
    const months = [
      "",
      "January", "February", "March", "April", "May", "June",
      "July", "August", "September", "October", "November", "December",
    ];
    return months[this.month];
  }

  String get weekdayName {
    const days = [
      "",
      "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"
    ];
    return days[this.weekday];
  }
}
