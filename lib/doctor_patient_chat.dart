// doctor_patient_chat.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DoctorPatientChat extends StatefulWidget {
  final String doctorId;
  final String doctorName;
  final String chatId; // use the chat doc id from inbox

  const DoctorPatientChat({
    super.key,
    required this.doctorId,
    required this.doctorName,
    required this.chatId,
  });

  @override
  State<DoctorPatientChat> createState() => _DoctorPatientChatState();
}

class _DoctorPatientChatState extends State<DoctorPatientChat> {
  final TextEditingController _controller = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  late String patientId;
  bool _chatReady = false;

  @override
  void initState() {
    super.initState();

    final user = _auth.currentUser;
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pop();
      });
      return;
    }
    patientId = user.uid;
    _ensureChatDoc(); // create/merge chat doc
  }

  Future<void> _ensureChatDoc() async {
    try {
      final docRef = _firestore.collection('chats').doc(widget.chatId);
      final snapshot = await docRef.get();

      if (!snapshot.exists) {
        // create with both sides info
        await docRef.set({
          'patientId': patientId,
          'doctorId': widget.doctorId,
          'doctorName': widget.doctorName,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // make sure patientId/doctorId exist (merge)
        await docRef.set({
          'patientId': patientId,
          'doctorId': widget.doctorId,
          'doctorName': widget.doctorName,
        }, SetOptions(merge: true));
      }
      setState(() => _chatReady = true);
    } catch (e) {
      debugPrint("Error ensuring chat doc: $e");
      // we still try to proceed — stream will show error if permissions fail
      setState(() => _chatReady = true);
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();

    try {
      final messagesRef = _firestore.collection('chats').doc(widget.chatId).collection('messages');

      await messagesRef.add({
        'senderId': patientId,
        'receiverId': widget.doctorId,
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // update chat preview
      await _firestore.collection('chats').doc(widget.chatId).set({
        'lastMessage': text,
        'lastSenderId': patientId,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Error sending message: $e");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to send message")));
    }
  }

  Widget _sentBubble(String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF2E3164),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(text, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _receivedBubble(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFBCBEE6),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(text, style: const TextStyle(color: Color(0xFF2E3164))),
      ),
    );
  }

  String _formatTime(dynamic ts) {
    if (ts == null) return "";
    try {
      DateTime dt;
      if (ts is Timestamp) dt = ts.toDate();
      else if (ts is DateTime) dt = ts;
      else if (ts is int) dt = DateTime.fromMillisecondsSinceEpoch(ts);
      else return "";
      return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_chatReady) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E3164),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFBCBEE6),
              child: Text(widget.doctorName.isNotEmpty ? widget.doctorName[0].toUpperCase() : "D",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(widget.doctorName, style: const TextStyle(fontWeight: FontWeight.w700))),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .doc(widget.chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snap) {
                if (snap.hasError) {
                  debugPrint("Stream error: ${snap.error}");
                  return Center(child: Text("Error loading messages:\n${snap.error.toString()}"));
                }
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snap.data!.docs;
                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.chat_bubble_outline, size: 64, color: Color(0xFFBCBEE6)),
                        SizedBox(height: 8),
                        Text("No messages yet — start the conversation!", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final raw = docs[index].data() as Map<String, dynamic>;
                    final text = (raw['text'] as String?) ?? '';
                    final sender = raw['senderId'] as String?;
                    final ts = raw['timestamp'];
                    final timeText = _formatTime(ts);

                    final isMe = sender == patientId;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        isMe ? _sentBubble(text) : _receivedBubble(text),
                        const SizedBox(height: 2),
                        Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 6.0, right: 6.0),
                            child: Text(timeText, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),

          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F0FA),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: "Write a message...",
                          border: InputBorder.none,
                        ),
                        minLines: 1,
                        maxLines: 4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Color(0xFF2E3164),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
