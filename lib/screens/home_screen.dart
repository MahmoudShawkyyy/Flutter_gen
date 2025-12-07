import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:genome/src/chat/chat_screen.dart';
import 'package:genome/src/utils/language_provider.dart';
import 'package:provider/provider.dart';
import 'package:genome/src/theme_provider.dart';
import 'package:genome/src/theme/app_background.dart';
import '../doctor_patient_chat.dart';
import 'package:genome/screens/settings.dart';
import 'package:genome/screens/PatientAppointment.dart';
import 'package:genome/src/book/book_appointment_page.dart';
import 'package:genome/src/book/select_date_time_page.dart';
import 'package:genome/inbox_page.dart';
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFD9DAF3), Color(0xFFB6B5D6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              bottom: -20,
              right: -30,
              child: Opacity(
                opacity: 0.35,
                child: Image.asset("assets/images/dna_bg.png", width: 380),
              ),
            ),

            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "HOMEPAGE",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: Color(0xff2e3164),
                      ),
                    ),

                    const SizedBox(height: 25),

                    _buildHomeCard(
                      title: "Book An Appointment Now",
                      subtitle:
                          "Schedule your appointment instantly with just one click.",
                      image: "assets/images/Appointment.png",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const BookAppointmentPage(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 25),

                    Row(
                      children: [
                        Expanded(
                          child: _buildSmallCard(
                            title: "Go To Settings",
                            subtitle: "manage your account easily",
                            image: "assets/images/Settings.png",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SettingPage(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 20),

                        Expanded(
                          child: _buildSmallCard(
                            title: "Customer Service",
                            subtitle:
                                "Get quick support\nfrom our team whenever you need it.",
                            image: "assets/images/Customer Service.png",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const InboxScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    _buildHomeCard(
                      title: "Ask Our Chatbot",
                      subtitle:
                          "Chat with our smart assistant for fast answers and instant help.",
                      image: "assets/images/chatbot.png",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ChatScreen()),
                        );
                      },
                    ),

                    const SizedBox(height: 25),

                    _buildHomeCard(
                      title: "View Your Appointments",
                      subtitle: "Look at your schedules",
                      image: "assets/images/my appointment.png",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MyAppointmentsPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeCard({
    required String title,
    required String subtitle,
    required String image,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFBCBEE6),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(image, width: 70),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E3164),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF2E3164),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Align(alignment: Alignment.bottomRight, child: _goButton(onTap)),
        ],
      ),
    );
  }

  Widget _buildSmallCard({
    required String title,
    required String subtitle,
    required String image,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFBCBEE6),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Image.asset(image, width: 55),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E3164),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            subtitle,
            style: const TextStyle(fontSize: 13, color: Color(0xFF2E3164)),
          ),

          const SizedBox(height: 15),

          Align(alignment: Alignment.bottomRight, child: _goButton(onTap)),
        ],
      ),
    );
  }

  Widget _goButton(VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2E3164),
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      ),
      child: const Text(
        "GO",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}
