import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Model (firebase → local object)
class Appointment {
  final String fullName;
  final String phone;
  final String email;
  final DateTime dateTime;
  final String status;

  Appointment({
    required this.fullName,
    required this.phone,
    required this.email,
    required this.dateTime,
    required this.status,
  });
}

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  Appointment? _selectedAppointment;

  Stream<List<Appointment>> _loadAppointments() {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return FirebaseFirestore.instance
        .collection('appointments')
        .where('patientId', isEqualTo: uid)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final date = doc['date']; // "2025-09-18"
        final time = doc['time']; // "07:00 PM"

        // Convert date & time → DateTime
        final fullDateTime =
            DateFormat("yyyy-MM-dd hh:mm a").parse("$date $time");

        return Appointment(
          fullName: doc['patientName'],
          phone: doc['phone'],
          email: doc['email'],
          dateTime: fullDateTime,
          status: doc['status'],
        );
      }).toList();
    });
  }

  void _showDetails(Appointment appointment) {
    setState(() {
      _selectedAppointment = appointment;
    });
  }

  void _hideDetails() {
    setState(() {
      _selectedAppointment = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          StreamBuilder<List<Appointment>>(
            stream: _loadAppointments(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final appointments = snapshot.data!;

              return _buildAppointmentList(appointments);
            },
          ),

          if (_selectedAppointment != null)
            _buildDetailOverlay(_selectedAppointment!),
        ],
      ),
    );
  }

  Widget _buildAppointmentList(List<Appointment> appointments) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              "My Appointments",
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2C3A8A),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                final appointment = appointments[index];
                return AppointmentSummaryCard(
                  appointment: appointment,
                  onTap: () => _showDetails(appointment),
                );
              },
            ),
          ),
          Image.asset(
            'assets/clipboard_graphic.png',
            height: 180,
            fit: BoxFit.contain,
            alignment: Alignment.bottomRight,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailOverlay(Appointment appointment) {
    return Stack(
      children: [
        GestureDetector(
          onTap: _hideDetails,
          child: Container(color: Colors.black.withOpacity(0.4)),
        ),

        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                AppointmentDetailCard(
                  appointment: appointment,
                  onClose: _hideDetails,
                ),
                Positioned(
                  top: -45,
                  child: Image.asset(
                    'assets/binder_clip.png',
                    height: 90,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// SUMMARY CARD
class AppointmentSummaryCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback onTap;

  const AppointmentSummaryCard({
    super.key,
    required this.appointment,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFD1D3F6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Icon(Icons.calendar_month,
                  color: Color(0xFF3F51B5), size: 30),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('EEEE, MMMM d, yyyy')
                        .format(appointment.dateTime),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C3A8A),
                    ),
                  ),
                  Text(
                    DateFormat('hh:mm a').format(appointment.dateTime),
                    style: const TextStyle(
                      color: Color(0xFF2C3A8A),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios,
                  color: Color(0xFF3F51B5), size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// DETAIL CARD
class AppointmentDetailCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback onClose;

  const AppointmentDetailCard({
    super.key,
    required this.appointment,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: onClose,
              ),
            ),
            const SizedBox(height: 10),
            _buildDetailRow(Icons.person_outline, "Full Name",
                appointment.fullName),
            _buildDetailRow(Icons.phone, "Phone number", appointment.phone),
            _buildDetailRow(Icons.email, "Email", appointment.email),
            _buildDetailRow(
                Icons.calendar_month,
                "Date",
                "${DateFormat('EEEE, MMMM d, yyyy').format(appointment.dateTime)}\n"
                "${DateFormat('hh:mm a').format(appointment.dateTime)}"),
            const SizedBox(height: 16),

            // Status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFE6E7F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time, color: Color(0xFF2C3A8A)),
                  const SizedBox(width: 8),
                  const Text("Status:",
                      style: TextStyle(
                          fontWeight: FontWeight.w600, color: Colors.grey)),
                  const SizedBox(width: 12),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: appointment.status == "Done"
                          ? Colors.green
                          : Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    appointment.status,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF3F51B5), size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}
