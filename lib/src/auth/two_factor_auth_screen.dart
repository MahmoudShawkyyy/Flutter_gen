import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_background.dart';
import '../utils/transition.dart';
import 'verified_success_screen.dart';

class TwoFactorAuthScreen extends StatefulWidget {
  final String verificationId;
  const TwoFactorAuthScreen({super.key, required this.verificationId, required String phone});

  @override
  State<TwoFactorAuthScreen> createState() => _TwoFactorAuthScreenState();
}

class _TwoFactorAuthScreenState extends State<TwoFactorAuthScreen> {
  final _controllers = List.generate(6, (_) => TextEditingController());
  bool _isLoading = false;  // To track loading state

  Future<void> _verify() async {
    setState(() {
      _isLoading = true;  // Show loading state
    });

    final smsCode = _controllers.map((e) => e.text).join();
    if (smsCode.length < 6) {
      // Show error if the code is incomplete
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the complete OTP.')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final credential = PhoneAuthProvider.credential(
          verificationId: widget.verificationId, smsCode: smsCode);

      await FirebaseAuth.instance.signInWithCredential(credential);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        createRoute(const VerifiedSuccessScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verification failed: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;  // Hide loading state
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Enter 6-digit OTP", style: TextStyle(fontSize: 22)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              6,
              (i) => SizedBox(
                width: 40,
                child: TextField(
                  controller: _controllers[i],
                  maxLength: 1,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    counterText: "",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) {
                    if (v.isNotEmpty && i < 5) {
                      FocusScope.of(context).nextFocus();
                    }
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: _isLoading ? null : _verify,  // Disable button when loading
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E2046),
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text("Verify"),
          ),
        ],
      ),
    );
  }
}
