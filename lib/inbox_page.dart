// inbox_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'doctor_patient_chat.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  late String patientId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() {
    final user = _auth.currentUser;
    if (user == null) return;
    patientId = user.uid;
    setState(() => _loading = false);
  }

  /// chatId formula (نفس اللي في صفحة الشات)
  String _makeChatId(String patientId, String doctorId) {
    return patientId.hashCode <= doctorId.hashCode
        ? "${patientId}_$doctorId"
        : "${doctorId}_$patientId";
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Doctors"),
        backgroundColor: const Color(0xFF2E3164),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection("doctors")
            .orderBy("createdAt", descending: true)
            .snapshots(),

        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snap.hasData || snap.data!.docs.isEmpty) {
            return const Center(child: Text("No Doctors Found"));
          }

          final doctors = snap.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: doctors.length,
            itemBuilder: (context, index) {
              final doc = doctors[index].data() as Map<String, dynamic>;

              final doctorId = doctors[index].id;
              final doctorName = doc["fullName"] ?? "Doctor";

              /// Chat ID
              final chatId = _makeChatId(patientId, doctorId);

              return FutureBuilder<DocumentSnapshot>(
                future: _firestore.collection("chats").doc(chatId).get(),

                builder: (context, chatSnap) {
                  String lastMessage = "";
                  if (chatSnap.hasData && chatSnap.data!.exists) {
                    final data = chatSnap.data!.data() as Map<String, dynamic>;
                    lastMessage = data["lastMessage"] ?? "";
                  }

                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFBCBEE6),
                        child: Icon(Icons.person, color: Colors.white),
                      ),

                      title: Text(
                        doctorName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      subtitle: Text(
                        lastMessage.isEmpty ? "Start a conversation" : lastMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      trailing: const Icon(Icons.chevron_right),

                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DoctorPatientChat(
                              doctorId: doctorId,
                              doctorName: doctorName,
                              chatId: chatId,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
