import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../theme/app_background.dart';

class VerifiedSuccessScreen extends StatelessWidget {
  const VerifiedSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final headlineColor = isDark ? Colors.white : const Color(0xFF1E2046);
    final bodyColor = isDark ? Colors.white70 : Colors.black54;
    final accent = theme.colorScheme.primary;

    // ❗ Ensuring shadowBase is a valid Color
    final Color shadowBase = isDark
        ? (Colors.purpleAccent[100] ?? Colors.purpleAccent)
        : const Color(0xFF1E2046);

    return AppBackground(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/animations/success.json',  // Ensure the asset exists
                width: 200,
                height: 200,
                repeat: false,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.check_circle_outline, size: 100);  // Fallback if Lottie fails
                },
              ),
              const SizedBox(height: 20),

              Text(
                "Email Verified Successfully 🎉",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: headlineColor,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 16),

              Text(
                "Your email has been verified.\nYou can now access your account safely.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: bodyColor, height: 1.4),
              ),
              const SizedBox(height: 40),

              Hero(
                tag: 'shield',
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withOpacity(0.5)
                            : shadowBase.withOpacity(0.18),
                        blurRadius: isDark ? 30 : 20,
                        spreadRadius: isDark ? 6 : 4,
                      ),
                    ],
                  ),
                  child: Image.asset('assets/images/sheild.png', height: 160),
                ),
              ),
              const SizedBox(height: 50),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/home'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Colors.purpleAccent[200] : accent,
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 6,
                    shadowColor: shadowBase.withOpacity(0.3),
                  ),
                  icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
                  label: const Text(
                    "Continue to Home",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
