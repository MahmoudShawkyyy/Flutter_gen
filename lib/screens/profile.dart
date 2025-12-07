import 'package:flutter/material.dart';
import 'package:genome/main.dart';
import 'package:genome/src/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:genome/src/utils/user_provider.dart';
import 'package:genome/src/utils/language_provider.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final user = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? Color(0xff121212) : Color(0xffe5e4f7),
      appBar: AppBar(
        backgroundColor: themeProvider.isDarkMode ? Color(0xff1e1e1e) : Color(0xffcac7e0),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: themeProvider.isDarkMode ? Colors.white : Colors.indigo.shade900,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: AutoTranslateText(
          'Edit Profile',
          style: TextStyle(
            color: themeProvider.isDarkMode ? Colors.white : Colors.indigo.shade900,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.save_rounded,
              color: themeProvider.isDarkMode ? Colors.deepPurple.shade200 : Colors.deepPurple.shade600,
            ),
            onPressed: () {
              // حفظ التعديلات
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Profile Picture Section
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: themeProvider.isDarkMode ? Colors.deepPurple.shade400 : Colors.deepPurple.shade300,
                      width: 3,
                    ),
                  ),
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 55,
                        backgroundColor: themeProvider.isDarkMode ? Colors.deepPurple.shade800 : Colors.deepPurple.shade50,
                        backgroundImage: const AssetImage(
                          'assets/images/avatar_placeholder.png',
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: themeProvider.isDarkMode ? Colors.deepPurple.shade600 : Colors.deepPurple.shade400,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: themeProvider.isDarkMode ? Color(0xff1e1e1e) : Color(0xffe5e4f7),
                              width: 3,
                            ),
                          ),
                          child: Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    // إضافة منطق تغيير الصورة هنا
                  },
                  child: AutoTranslateText(
                    'Change Photo',
                    style: TextStyle(
                      color: themeProvider.isDarkMode ? Colors.deepPurple.shade200 : Colors.deepPurple.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Form Fields
                Expanded(
                  child: ListView(
                    children: [
                      _buildFormField(
                        label: 'Full Name',
                        icon: Icons.person_rounded,
                        themeProvider: themeProvider,
                      ),
                      const SizedBox(height: 16),
                      _buildFormField(
                        label: 'Email',
                        icon: Icons.email_rounded,
                        themeProvider: themeProvider,
                        enabled: false, // الإيميل لا يمكن تعديله
                      ),
                      const SizedBox(height: 32),
                      // Save Button
                      Container(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            // حفظ التعديلات
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: themeProvider.isDarkMode ? Colors.deepPurple.shade600 : Colors.deepPurple.shade400,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 2,
                          ),
                          child: AutoTranslateText(
                            'Save Changes',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
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
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required IconData icon,
    required ThemeProvider themeProvider,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? Color(0xff1e1e1e) : Color(0xffcac7e0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextFormField(
        enabled: enabled,
        keyboardType: keyboardType,
        style: TextStyle(
          color: themeProvider.isDarkMode ? Colors.white : Colors.indigo.shade900,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: themeProvider.isDarkMode ? Colors.grey.shade400 : Colors.indigo.shade700,
          ),
          prefixIcon: Icon(
            icon,
            color: themeProvider.isDarkMode ? Colors.deepPurple.shade300 : Colors.deepPurple.shade500,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: themeProvider.isDarkMode ? Colors.deepPurple.shade400 : Colors.deepPurple.shade500,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}