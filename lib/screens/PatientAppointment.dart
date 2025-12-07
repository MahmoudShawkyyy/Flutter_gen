import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyAppointmentsPage extends StatelessWidget {
  const MyAppointmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("You must be logged in")),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xffeef0f8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xffB71C1C), size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "My Appointments",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color(0xff1F3C88),
          ),
        ),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('appointments')
              .where('patientId', isEqualTo: user.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }

            final docs = snapshot.data?.docs ?? [];

            if (docs.isEmpty) {
              return const Center(
                child: Text(
                  "No Appointments Found",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              );
            }

            return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final ap = docs[index];
                final data = ap.data() as Map<String, dynamic>;

                return _appointmentCard(
                  appointment: data,
                );
              },
            );
          },
        ),
      ),
    );
  }

  // ------------------ Appointment Card UI ------------------

  Widget _appointmentCard({
    required Map<String, dynamic> appointment,
  }) {
    final doctorName = appointment['doctorName'];
    final status = appointment['status'];
    final date = appointment['date'];
    final time = appointment['time'];

    Color statusColor = Colors.orange;
    if (status == "Approved") statusColor = Colors.green;
    if (status == "Rejected") statusColor = Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),

      child: Row(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: const Color(0xff1F3C88),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.calendar_month,
                color: Colors.white, size: 30),
          ),

          const SizedBox(width: 18),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Dr. $doctorName",
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xff1F3C88),
                  ),
                ),
                const SizedBox(height: 5),
                Text("Date: $date"),
                Text("Time: $time"),
                const SizedBox(height: 7),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
