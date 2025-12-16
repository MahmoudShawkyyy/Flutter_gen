import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 💡 الاستيراد للحصول على اسم المستخدم
import 'package:provider/provider.dart';
// استيراد الشاشات والمكتبات الأخرى...
import 'package:genome/src/chat/chat_screen.dart';
import 'package:genome/screens/settings.dart';
import 'package:genome/screens/PatientAppointment.dart'; 
import 'package:genome/src/book/book_appointment_page.dart';
import 'package:genome/inbox_page.dart';

// تعريف الألوان الجديدة
class AppColors {
  static const Color primaryBlue = Color(0xFF2E3164);
  static const Color lightBackground = Color(0xFFD9DAF3);
  static const Color secondaryBackground = Color(0xFFB6B5D6);
  static const Color cardColor = Color(0xFFA9AAD4); 
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const double _imageSize = 110.0; 
  static const double _largeImageSize = 150.0; 
  static const double _smallCardHeight = 320.0; 

  @override
  Widget build(BuildContext context) {
    // 💡 الحصول على بيانات المستخدم وتحديد اسم العرض
    final User? currentUser = FirebaseAuth.instance.currentUser;
    // يتم استخدام displayName. إذا كان فارغًا، يتم استخدام "Guest"
    final String userName = currentUser?.displayName ?? "Guest"; 
    
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.lightBackground, AppColors.secondaryBackground],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            // صورة الخلفية
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
                    // --- تعديل العنوان والترحيب ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic, 
                      children: [
                        // 1. العنوان "HOMEPAGE"
                        const Text(
                          "HOMEPAGE",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        
                        // 2. ترحيب المستخدم
                        Expanded(
                          child: Text(
                            "Welcome, $userName", // استخدام اسم المستخدم المُحدَّث
                            textAlign: TextAlign.end,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16, 
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // --- نهاية تعديل العنوان والترحيب ---

                    const SizedBox(height: 25),

                    // 1. بطاقة حجز الموعد
                    _buildLargeCard(
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

                    // 2. صف البطاقات الصغيرة
                    Row(
                      children: [
                        Expanded(
                          // بطاقة الإعدادات
                          child: _buildSmallSquareCard(
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
                          // بطاقة خدمة العملاء
                          child: _buildSmallSquareCard(
                            title: "Customer Service",
                            subtitle:
                                "Get quick support from our team whenever you need it.",
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

                    // 3. بطاقة Chatbot
                    _buildLargeCard(
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

                    // 4. بطاقة مشاهدة المواعيد
                    _buildLargeCard(
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
                    const SizedBox(height: 25),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ******************************************************
  // دالة البطاقات الكبيرة الطولية (Retained)
  // ******************************************************

  Widget _buildLargeCard({
    required String title,
    required String subtitle,
    required String image,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20, 
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Image.asset(image, width: _largeImageSize), 
              _goButton(onTap),
            ],
          ),
        ],
      ),
    );
  }

  // ******************************************************
  // دالة البطاقات المربعة الصغيرة (Retained)
  // ******************************************************

  Widget _buildSmallSquareCard({
    required String title,
    required String subtitle,
    required String image,
    required VoidCallback onTap,
  }) {
    return Container(
      height: _smallCardHeight, 
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, color: AppColors.primaryBlue),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Expanded(
            child: Center(
              child: Image.asset(image, width: _largeImageSize), 
            ),
          ),

          const SizedBox(height: 10),
          
          Align(alignment: Alignment.bottomRight, child: _goButton(onTap)),
        ],
      ),
    );
  }

  // ******************************************************
  // دالة زر GO (Retained)
  // ******************************************************

  Widget _goButton(VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryBlue,
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