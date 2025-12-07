import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:genome/src/chat/chat_screen.dart';
import 'package:genome/src/utils/language_provider.dart';
import 'package:provider/provider.dart';
import 'package:genome/src/theme_provider.dart';
import 'package:genome/src/theme/app_background.dart';
import '../doctor_patient_chat.dart';
import 'package:genome/screens/settings.dart';
import 'package:genome/src/book/book_appointment_page.dart';
import 'package:genome/src/book/select_date_time_page.dart';
import 'package:genome/screens/home_screen.dart';

class ReviewPage extends StatefulWidget {
  final String name;
  final String specialty;
  final String imagePath;

  const ReviewPage({
    super.key,
    required this.name,
    required this.specialty,
    required this.imagePath,
  });

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  double rating = 4;
  final TextEditingController commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFE7E7F7),
                  Color(0xFFC5C4E2),
                  Color(0xFFB3B2D3),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: -60,
            right: -40,
            child: Opacity(
              opacity: 0.30,
              child: Image.asset("assets/images/dna_bg.png", width: 450),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.red,
                      size: 32,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Center(
                    child: Text(
                      "Review",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF273273),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image.asset(
                        widget.imagePath,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  Center(
                    child: Text(
                      widget.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF273273),
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  Center(
                    child: Text(
                      widget.specialty,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.favorite_border,
                          color: Color(0xFF273273),
                          size: 22,
                        ),
                        const SizedBox(width: 10),

                        ...List.generate(5, (index) {
                          return IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              setState(() {
                                rating = index + 1.toDouble();
                              });
                            },
                            icon: Icon(
                              index < rating ? Icons.star : Icons.star_border,
                              color: const Color(0xFF273273),
                              size: 26,
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.all(16),
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextField(
                      controller: commentController,
                      maxLines: 6,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Enter Your Comment Here...",
                        hintStyle: TextStyle(color: Colors.black54),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 50,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF273273),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const Text(
                        "Add Review",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
