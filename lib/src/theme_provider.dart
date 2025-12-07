import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  // حالة الوضع الداكن
  bool isDarkMode = false;

  // لإرجاع ThemeMode الحالي (Light / Dark)
  ThemeMode get currentTheme => isDarkMode ? ThemeMode.dark : ThemeMode.light;

  // تبديل الوضع الداكن
  void toggleTheme([bool? value]) {
    if (value != null) {
      isDarkMode = value;
    } else {
      isDarkMode = !isDarkMode;
    }
    notifyListeners();
  }

  // ThemeData للوضع الفاتح
  ThemeData get lightTheme => ThemeData(
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF1E2046),
          secondary: Color(0xFFE84118),
          background: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Poppins',
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black87),
          bodyMedium: TextStyle(color: Colors.black87),
        ),
        cardColor: Colors.white,
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.all(Color(0xFF4A64FE)),
          trackColor: MaterialStateProperty.all(Color(0xFFBDBDBD)),
        ),
      );

  // ThemeData للوضع الداكن
  ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF4A64FE),
          secondary: Color(0xFFE84118),
          background: Color(0xFF121212),
          surface: Color(0xFF1E1E2C),
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E2C),
        fontFamily: 'Poppins',
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white70),
          bodyMedium: TextStyle(color: Colors.white70),
          titleLarge: TextStyle(color: Colors.white),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.all(Color(0xFFE84118)),
          trackColor: MaterialStateProperty.all(Color(0xFF4A64FE)),
        ),
      );
}
