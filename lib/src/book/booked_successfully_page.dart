import 'package:flutter/material.dart';
import 'package:genome/screens/home_screen.dart';
import 'package:genome/screens/home_screen.dart'; // ← مهم: استيراد صفحة الهوم

class BookedSuccessfullyPage extends StatelessWidget {
  const BookedSuccessfullyPage({super.key});

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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Booked\nSuccessfully",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 42,     // ← كبرنا الخط هنا
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                  color: Color(0xff1F3C88),
                ),
              ),

              const SizedBox(height: 30),

              Image.asset(
                "assets/images/book.png",
                height: 200,
              ),

              const SizedBox(height: 40),

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
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HomeScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    "Go Back Home",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
