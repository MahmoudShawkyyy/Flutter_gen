import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../theme/app_background.dart';
import 'package:genome/src/utils/user_provider.dart';
import 'package:genome/src/utils/language_provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  bool _obscurePassword = true;
  bool _isLoading = false;
  late bool isEnglish;

  final _auth = FirebaseAuth.instance;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // ---------------------------
  // Login / SignUp Logic
  // ---------------------------
  Future<void> _handleAuthAction() async {
    setState(() => _isLoading = true);

    try {
      if (isLogin) {
        await _loginUser();
      } else {
        await _signUpUser();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loginUser() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      throw Exception("Please enter email and password");
    }

    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = cred.user!.uid;
      final doc = await FirebaseFirestore.instance.collection("users").doc(uid).get();

      if (!doc.exists) {
        throw Exception("Account exists in Auth but not in Firestore");
      }

      final role = doc["role"];
      if (role != "patient") {
        throw Exception("Only patients can log in from this app.");
      }

      Provider.of<UserProvider>(context, listen: false).setUser(
        doc["name"],
        doc["email"],
      );

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      String message = "Login failed";
      if (e.code == "user-not-found") message = "User not found";
      if (e.code == "wrong-password") message = "Incorrect password";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Future<void> _signUpUser() async {
    final pass = _passwordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();
    final email = _emailController.text.trim();
    final name = _nameController.text.trim();

    if (pass != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    if (email.isEmpty || name.isEmpty || pass.isEmpty) {
      throw Exception("All fields are required");
    }

    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: pass,
      );

      final uid = cred.user!.uid;

      /// 🔥 Save patient with UID in Firestore
      await FirebaseFirestore.instance.collection("users").doc(uid).set({
        "uid": uid,                  // ← UID مضمونة
        "name": name,
        "email": email,
        "role": "patient",
        "createdAt": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully! Please log in.'),
          duration: Duration(seconds: 3),
        ),
      );

      setState(() => isLogin = true);
    } on FirebaseAuthException catch (e) {
      String message = "Sign Up failed";
      if (e.code == "email-already-in-use") message = "Email is already used";
      if (e.code == "weak-password") message = "Password is too weak";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  // ---------------------------
  // Forgot Password
  // ---------------------------
  void _showForgotPasswordDialog() {
    final resetController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: TextField(
          controller: resetController,
          decoration: const InputDecoration(
            labelText: 'Enter your email',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _auth.sendPasswordResetEmail(
                  email: resetController.text.trim(),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password reset link sent!')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E2046),
              foregroundColor: Colors.white,
            ),
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  // ---------------------------
  // UI
  // ---------------------------
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final langProvider = Provider.of<LanguageProvider>(context);
    isEnglish = langProvider.locale.languageCode == 'en';

    return AppBackground(
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, right: 16),
                  child: GestureDetector(
                    onTap: () => langProvider.toggleLanguage(),
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.grey[200],
                      child: Text(
                        isEnglish ? 'EN' : 'AR',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 80),
              Image.asset('assets/images/illustration1.png', height: 120),
              const SizedBox(height: 10),
              Text(
                "Genora",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: theme.textTheme.headlineLarge!.color,
                ),
              ),
              const SizedBox(height: 40),
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                padding:
                    const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                decoration: BoxDecoration(
                  color: theme.cardColor.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadowColor.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildTabs(theme),
                    const SizedBox(height: 24),
                    if (isLogin)
                      _buildLoginFields(theme)
                    else
                      _buildSignUpFields(theme),
                    const SizedBox(height: 30),
                    _buildActionButton(theme),
                    if (isLogin)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _showForgotPasswordDialog,
                          child: Text(
                            isEnglish ? 'Forgot password?' : "نسيت كلمة السر؟",
                            style: TextStyle(color: theme.hintColor),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabs(ThemeData theme) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: theme.dividerColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _tabButton(isEnglish ? "Login" : "تسجيل الدخول", true, theme),
          _tabButton(isEnglish ? "SignUp" : "التسجيل", false, theme),
        ],
      ),
    );
  }

  Expanded _tabButton(String text, bool login, ThemeData theme) {
    final active = isLogin == login;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => isLogin = login),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: active ? theme.colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: active ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginFields(ThemeData theme) {
    return Column(
      children: [
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: isEnglish ? 'Email' : 'البريد الإلكتروني',
            labelStyle: TextStyle(color: theme.hintColor),
          ),
          style: TextStyle(color: theme.textTheme.bodyMedium!.color),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: isEnglish ? 'Password' : 'كلمة المرور',
            labelStyle: TextStyle(color: theme.hintColor),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: theme.iconTheme.color,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          style: TextStyle(color: theme.textTheme.bodyMedium!.color),
        ),
      ],
    );
  }

  Widget _buildSignUpFields(ThemeData theme) {
    return Column(
      children: [
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: isEnglish ? 'Full Name' : 'الاسم الكامل',
            labelStyle: TextStyle(color: theme.hintColor),
          ),
          style: TextStyle(color: theme.textTheme.bodyMedium!.color),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: isEnglish ? 'Email' : 'البريد الإلكتروني',
            labelStyle: TextStyle(color: theme.hintColor),
          ),
          style: TextStyle(color: theme.textTheme.bodyMedium!.color),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: isEnglish ? 'Password' : 'كلمة المرور',
            labelStyle: TextStyle(color: theme.hintColor),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: theme.iconTheme.color,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          style: TextStyle(color: theme.textTheme.bodyMedium!.color),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _confirmPasswordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText:
                isEnglish ? 'Confirm Password' : 'تأكيد كلمة المرور',
            labelStyle: TextStyle(color: theme.hintColor),
          ),
          style: TextStyle(color: theme.textTheme.bodyMedium!.color),
        ),
      ],
    );
  }

  Widget _buildActionButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleAuthAction,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(vertical: 14),
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
            : Text(isLogin
                ? (isEnglish ? 'Login' : 'تسجيل الدخول')
                : (isEnglish ? 'Sign Up' : 'التسجيل')),
      ),
    );
  }
}
