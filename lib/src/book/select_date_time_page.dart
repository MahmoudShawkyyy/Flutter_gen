import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SelectDateTimePage extends StatefulWidget {
  const SelectDateTimePage({super.key});

  @override
  State<SelectDateTimePage> createState() => _SelectDateTimePageState();
}

class _SelectDateTimePageState extends State<SelectDateTimePage> {
  DateTime _focusedDay = DateTime(2025, 12, 1);
  DateTime? _selectedDay;
  String selectedTime = "";

  final DateTime _minDate = DateTime(2025, 12, 1);
  final DateTime _today = DateTime.now();

  final List<String> timeSlots = [
    "05:00 PM",
    "06:00 PM",
    "07:00 PM",
    "08:00 PM",
    "09:00 PM",
    "10:00 PM",
    "11:00 PM",
    "12:00 PM",
  ];

  Map<String, bool> bookedSlots = {}; // time -> isBooked

  @override
  void initState() {
    super.initState();
    _selectedDay = _today.isBefore(_minDate) ? _minDate : _today;
    _fetchBookedSlots();
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

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    // منع اختيار أيام قبل اليوم الحالي أو قبل 1 ديسمبر 2025
    if (selectedDay.isBefore(_today) || selectedDay.isBefore(_minDate)) {
      return;
    }

    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      selectedTime = "";
    });

    _fetchBookedSlots();
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
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(25),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back,
                      size: 30, color: Color(0xffB71C1C)),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Select a Date & Time",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff1F3C88),
                  ),
                ),
                const SizedBox(height: 20),

                // -------------------------------- CALENDAR ------------------------------------------------
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(0xffeef0f8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TableCalendar(
                    firstDay: _minDate,
                    lastDay: DateTime(2026, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),

                    // منع اختيار الأيام الغير متاحة
                    enabledDayPredicate: (day) {
                      if (day.isBefore(_today)) return false;
                      if (day.isBefore(_minDate)) return false;
                      return true;
                    },

                    onDaySelected: _onDaySelected,

                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    calendarStyle: CalendarStyle(
                      disabledDecoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        shape: BoxShape.circle,
                      ),
                      disabledTextStyle: const TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.bold),
                      selectedDecoration: const BoxDecoration(
                        color: Color(0xff1F3C88),
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(color: Color(0xff1F3C88), width: 2),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // ----------------------------- SELECTED DATE TEXT -------------------------------
                Text(
                  _selectedDay == null
                      ? "Select a date"
                      : "${_selectedDay!.weekdayName}, ${_selectedDay!.monthName} ${_selectedDay!.day}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff1F3C88),
                  ),
                ),

                const SizedBox(height: 15),

                // -------------------------------- TIME SLOTS -----------------------------------
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: timeSlots.map((t) {
                    final isBooked = bookedSlots[t] ?? false;
                    final isSelected = t == selectedTime;

                    return GestureDetector(
                      onTap: isBooked
                          ? null
                          : () {
                              setState(() {
                                selectedTime = t;
                              });
                            },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: isBooked
                              ? Colors.red.shade100
                              : isSelected
                                  ? const Color(0xff1F3C88)
                                  : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          t,
                          style: TextStyle(
                            color: isBooked
                                ? Colors.red
                                : isSelected
                                    ? Colors.white
                                    : Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 30),

                // -------------------------------- BUTTON -----------------------------------
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
                    onPressed: (_selectedDay != null && selectedTime.isNotEmpty)
                        ? () {
                            Navigator.pop(context, {
                              'date': _selectedDay,
                              'time': selectedTime,
                            });
                          }
                        : null,
                    child: const Text(
                      "Schedule now",
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
}

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
    return months[this.month];
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
    return days[this.weekday];
  }
}
