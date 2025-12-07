import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_background.dart';
import '../utils/transition.dart';
import 'two_factor_auth_screen.dart';
import 'verified_success_screen.dart';

class SecureAccountScreen extends StatelessWidget {
  const SecureAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    final String email = args?['email'] ?? '';
    final String phone = args?['phone'] ?? '';

    return AppBackground(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🔹 Main Title
            Text(
              "Secure Your Account",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF1E2046),
              ),
            ),
            const SizedBox(height: 40),

            // --- EMAIL VERIFICATION OPTION ---
            if (email.isNotEmpty)
              _OptionButton(
                imagePath: "assets/images/gmail.png",
                label: "Verify Email ($email)",
                isDark: isDark,
                onTap: () async {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null && !user.emailVerified) {
                    await user.sendEmailVerification();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Verification email sent! Please check your inbox.",
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Email already verified.")),
                    );
                  }

                  Navigator.pushReplacement(
                    context,
                    createRoute(const VerifiedSuccessScreen()),
                  );
                },
              ),

            if (email.isNotEmpty) const SizedBox(height: 20),

            // --- PHONE VERIFICATION OPTION ---
            if (phone.isNotEmpty)
              _OptionButton(
                imagePath: "assets/images/sms.png",
                label: "Send OTP to $phone",
                isDark: isDark,
                onTap: () async {
                  await FirebaseAuth.instance.verifyPhoneNumber(
                    phoneNumber: phone,
                    verificationCompleted:
                        (PhoneAuthCredential credential) async {
                          await FirebaseAuth.instance.signInWithCredential(
                            credential,
                          );
                          if (context.mounted) {
                            Navigator.pushReplacement(
                              context,
                              createRoute(const VerifiedSuccessScreen()),
                            );
                          }
                        },
                    verificationFailed: (FirebaseAuthException e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Verification failed: ${e.message}'),
                        ),
                      );
                    },
                    codeSent: (String verificationId, int? resendToken) {
                      Navigator.push(
                        context,
                        createRoute(
                          TwoFactorAuthScreen(
                            verificationId: verificationId,
                            phone: phone,
                          ),
                        ),
                      );
                    },
                    codeAutoRetrievalTimeout: (String verificationId) {},
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  final String imagePath;
  final String label;
  final VoidCallback onTap;
  final bool isDark;

  const _OptionButton({
    required this.imagePath,
    required this.label,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.white10 : Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black12.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
          ],
          border: Border.all(
            color: isDark ? Colors.white24 : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Image.asset(imagePath, height: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: isDark
                  ? Colors.purpleAccent[200]
                  : const Color(0xFF1E2046),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
