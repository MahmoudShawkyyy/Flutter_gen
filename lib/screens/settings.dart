import 'package:flutter/material.dart';
import 'package:genome/src/chat/chat_screen.dart';
import 'package:genome/src/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:genome/src/utils/language_provider.dart';
import 'package:genome/src/utils/user_provider.dart';
import '../../main.dart';
import 'package:genome/src/auth/auth_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';
import 'profile.dart';
import '../doctor_patient_chat.dart'; 
 // تأكد من استيراد صفحة البروفايل

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  late bool isLanguageSwitched;
  int _currentIndex = 2; // الإعدادات هي الصفحة الثالثة (index 2)

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    isLanguageSwitched = lang.locale?.languageCode == 'en';
  }

  void _onItemTapped(int index) {
    if (index == _currentIndex) return; // إذا كانت الصفحة نفسها، لا تفعل شيء

    // التنقل بين الصفحات باستخدام pushReplacement بدل pushAndRemoveUntil
    if (index == 0) {
      // الانتقال إلى Home
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => HomeScreen()));
    } else if (index == 1) {
      // الانتقال إلى Chat
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => ChatScreen()));
    }
    // index == 2 هو Settings ونحن بالفعل هنا، لذلك لا نفعل شيء
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? Color(0xff121212) : Color(0xffe5e4f7),
      body: SafeArea(
        child: Column(
          children: [
            // Top: Profile Section
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: themeProvider.isDarkMode ? Colors.deepPurple.shade800 : Colors.deepPurple.shade50,
                    backgroundImage: const AssetImage(
                      'assets/images/avatar_placeholder.png',
                    ),
                  ),
                  const SizedBox(height: 14),

                  AutoTranslateText(
                    user.name ?? "User",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: themeProvider.isDarkMode ? Colors.white : Colors.indigo.shade900,
                    ),
                  ),

                  const SizedBox(height: 2),

                  AutoTranslateText(
                    user.email ?? "example@gmail.com",
                    style: TextStyle(
                      color: themeProvider.isDarkMode ? Colors.grey.shade300 : Colors.indigo.shade700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                children: [
                  _buildSwitchTile('Dark Mode', themeProvider.isDarkMode, (val) {
                    themeProvider.toggleTheme(val);
                  }),
                  const SizedBox(height: 18),

                  _buildSwitchTile('Switch Language', isLanguageSwitched, (
                    val,
                  ) {
                    setState(() => isLanguageSwitched = val);
                    final lang = Provider.of<LanguageProvider>(
                      context,
                      listen: false,
                    );
                    if (val) {
                      lang.setLocale(const Locale('en'));
                    } else {
                      lang.setLocale(const Locale('ar'));
                    }
                  }),

                  const SizedBox(height: 24),

                  _buildMenuCard([
                    _buildMenuTile(
                      'Edit Profile',
                      onTap: () {
                        // الانتقال إلى صفحة البروفايل
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => ProfilePage()),
                        );
                      },
                    ),
                  ]),

                  const SizedBox(height: 20),

                  _buildMenuCard([
                    _buildMenuTile(
                      'Logout',
                      onTap: () async {
                        Provider.of<UserProvider>(
                          context,
                          listen: false,
                        ).clearUser();

                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => AuthScreen()),
                          (route) => false,
                        );
                      },
                    ),
                  ]),

                  const SizedBox(height: 20),

                  _buildMenuCard([
                    _buildMenuTile(
                      'Delete Account',
                      onTap: () {
                        _showDeleteConfirmation(context);
                      },
                    ),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 10,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onItemTapped,
            backgroundColor: themeProvider.isDarkMode ? Color(0xff1e1e1e) : Color(0xffcac7e0),
            selectedItemColor: themeProvider.isDarkMode ? Colors.deepPurple.shade200 : Colors.indigo.shade900,
            unselectedItemColor: themeProvider.isDarkMode ? Colors.grey.shade400 : Colors.indigo.shade700,
            selectedLabelStyle: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            unselectedLabelStyle: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
            items: [
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.home_rounded,
                  size: _currentIndex == 0 ? 28 : 24,
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.chat_rounded,
                  size: _currentIndex == 1 ? 28 : 24,
                ),
                label: 'Chat',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.settings_rounded,
                  size: _currentIndex == 2 ? 28 : 24,
                ),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔵 dialog تأكيد حذف الحساب
  void _showDeleteConfirmation(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: themeProvider.isDarkMode ? Color(0xff1e1e1e) : Colors.white,
          title: AutoTranslateText(
            "Are you sure?",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: themeProvider.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          content: AutoTranslateText(
            "Do you really want to delete your account?",
            style: TextStyle(
              color: themeProvider.isDarkMode ? Colors.grey.shade300 : Colors.black87,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: AutoTranslateText(
                "No",
                style: TextStyle(color: Colors.blueGrey),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _deleteAccount();
              },
              child: AutoTranslateText(
                "Yes",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  // 🔥 حذف حساب المستخدم نهائياً من Firebase
  Future<void> _deleteAccount() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await user.delete();
      }

      Provider.of<UserProvider>(context, listen: false).clearUser();

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => AuthScreen()),
        (route) => false,
      );
    } catch (e) {
      print("Delete account error: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to delete account. You may need to re-login."),
        ),
      );
    }
  }

  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Container(
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? Color(0xff1e1e1e) : Color(0xffcac7e0),
        borderRadius: BorderRadius.circular(22),
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
        title: AutoTranslateText(
          title,
          style: TextStyle(
            color: themeProvider.isDarkMode ? Colors.white : Colors.indigo.shade900,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        activeColor: Colors.deepPurple.shade400,
        inactiveThumbColor: Colors.grey.shade400,
        inactiveTrackColor: Colors.grey.shade200,
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildMenuCard(List<Widget> children) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Container(
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? Color(0xff1e1e1e) : Color(0xffcac7e0),
        borderRadius: BorderRadius.circular(22),
      ),
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: Column(children: children),
    );
  }

  Widget _buildMenuTile(String title, {Function()? onTap}) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return ListTile(
      title: AutoTranslateText(
        title,
        style: TextStyle(
          color: themeProvider.isDarkMode ? Colors.white : Colors.indigo.shade900,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: themeProvider.isDarkMode ? Colors.grey.shade400 : Colors.indigo.shade700,
      ),
      onTap: onTap,
    );
  }
}