import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../theme/app_background.dart';
import 'package:genome/src/utils/user_provider.dart';
import 'package:genome/src/utils/language_provider.dart';
import 'package:genome/src/utils/router_service.dart';

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

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _auth = FirebaseAuth.instance;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ---------------------------
  // Login / SignUp Logic
  // ---------------------------
  Future<void> _handleAuthAction() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

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

      final String? firestoreName = doc.data()?["name"] as String?;
      final String? docEmail = doc.data()?["email"] as String?;
      final authUser = cred.user;

      if (firestoreName == null || docEmail == null) {
        throw Exception("User data (name or email) is missing in Firestore.");
      }
      
      // 1. تحديث اسم العرض في Firebase Auth
      final bool isAuthNameMissing = authUser!.displayName == null || authUser.displayName!.isEmpty;
      
      if (isAuthNameMissing || authUser.displayName != firestoreName) {
        await authUser.updateProfile(displayName: firestoreName); 
        await authUser.reload(); 
      }
      
      // 2. تحديث الـ UserProvider
      Provider.of<UserProvider>(context, listen: false).setUser(
        firestoreName, 
        docEmail,
      );

      final token = await cred.user!.getIdToken();
      if (token != null && token.isNotEmpty) {
        await RouterService.setAuthToken(token);
      }

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      String message = "Login failed";
      if (e.code == "user-not-found") message = "User not found";
      if (e.code == "wrong-password") message = "Incorrect password";
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Future<void> _signUpUser() async {
    final pass = _passwordController.text.trim();
    final email = _emailController.text.trim();
    final name = _nameController.text.trim();

    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: pass,
      );

      final uid = cred.user!.uid;

      // تعيين الاسم في Firebase Auth عند التسجيل
      await cred.user!.updateProfile(displayName: name);

      // حفظ البيانات في Firestore
      await FirebaseFirestore.instance.collection("users").doc(uid).set({
        "uid": uid, 
        "name": name,
        "email": email,
        "role": "patient",
        "createdAt": FieldValue.serverTimestamp(),
      });

      await RouterService.setSignedUp();

      if (!mounted) return;
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
      if (!mounted) return;
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
        title: Text(isEnglish ? 'Reset Password' : 'إعادة تعيين كلمة المرور'),
        content: TextField(
          controller: resetController,
          decoration: InputDecoration(
            labelText: isEnglish ? 'Enter your email' : 'أدخل بريدك الإلكتروني',
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isEnglish ? 'Cancel' : 'إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _auth.sendPasswordResetEmail(
                  email: resetController.text.trim(),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(isEnglish ? 'Password reset link sent!' : 'تم إرسال رابط إعادة تعيين كلمة المرور!')),
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
            child: Text(isEnglish ? 'Send' : 'إرسال'),
          ),
        ],
      ),
    );
  }

  // ---------------------------
  // UI Building
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
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
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
                    _buildFormFields(theme),
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

  Widget _buildFormFields(ThemeData theme) {
    return Form(
      key: _formKey, 
      child: Column(
        children: [
          // حقل الاسم الكامل (للتسجيل فقط)
          if (!isLogin)
            _buildTextFormField(
              controller: _nameController,
              label: isEnglish ? 'Full Name' : 'الاسم الكامل',
              theme: theme,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return isEnglish ? 'Name is required' : 'الاسم مطلوب';
                }
                // 🚀 تعديل الاسم: يجب أن يحتوي على حروف ومسافات فقط
                // يدعم الحروف اللاتينية والعربية
                if (!RegExp(r"^[a-zA-Z\u0600-\u06FF\s]+$").hasMatch(value.trim())) {
                    return isEnglish ? 'Name must contain letters only' : 'يجب أن يحتوي الاسم على أحرف فقط';
                }
                return null;
              },
            ),
          if (!isLogin) const SizedBox(height: 10),

          // حقل البريد الإلكتروني
          _buildTextFormField(
            controller: _emailController,
            label: isEnglish ? 'Email' : 'البريد الإلكتروني',
            theme: theme,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || !value.contains('@') || !value.contains('.')) {
                return isEnglish ? 'Enter a valid email' : 'أدخل بريد إلكتروني صحيح';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),

          // حقل كلمة المرور
          _buildTextFormField(
            controller: _passwordController,
            label: isEnglish ? 'Password' : 'كلمة المرور',
            theme: theme,
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: theme.iconTheme.color,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            validator: (value) {
              if (value == null || value.length < 6) {
                return isEnglish ? 'Password must be at least 6 characters' : 'كلمة المرور 6 أحرف على الأقل';
              }
              
              // 🚀 تعديل الباسورد: يجب أن يحتوي على حروف وأرقام
              final hasLetters = RegExp(r'[a-zA-Z\u0600-\u06FF]').hasMatch(value);
              final hasDigits = RegExp(r'[0-9]').hasMatch(value);

              if (!hasLetters || !hasDigits) {
                return isEnglish ? 'Must contain letters and numbers' : 'يجب أن تحتوي على حروف وأرقام';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),

          // حقل تأكيد كلمة المرور (للتسجيل فقط)
          if (!isLogin)
            _buildTextFormField(
              controller: _confirmPasswordController,
              label: isEnglish ? 'Confirm Password' : 'تأكيد كلمة المرور',
              theme: theme,
              obscureText: true,
              validator: (value) {
                if (value != _passwordController.text) {
                  return isEnglish ? 'Passwords do not match' : 'كلمتا المرور غير متطابقتين';
                }
                return null;
              },
            ),
        ],
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
  
  // دالة مُساعدة لبناء TextFormField (تم إبقاؤها بدون تغيير جوهري)
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required ThemeData theme,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: TextStyle(color: theme.textTheme.bodyMedium!.color),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: theme.hintColor),
        suffixIcon: suffixIcon,
      ),
      validator: validator,
    );
  }
}