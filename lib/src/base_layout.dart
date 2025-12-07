import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:genome/src/theme_provider.dart';

class BaseLayout extends StatelessWidget {
  final Widget child;
  final bool showThemeButton; // ✅ إضافة جديدة للتحكم في ظهور الزرار

  const BaseLayout({
    super.key,
    required this.child,
    this.showThemeButton =
        true, // ✅ القيمة الافتراضية: الزرار يظهر في كل الصفحات
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor:
          theme.scaffoldBackgroundColor, // ✅ الخلفية تتغير حسب الثيم

      body: Stack(
        children: [
          // ✅ الخلفية تتبع الثيم
          Container(color: theme.scaffoldBackgroundColor),

          // ✅ محتوى الصفحة
          Theme(data: theme, child: child),

          // 🌙 زرار تغيير الثيم (يظهر بس لو showThemeButton = true)
          if (showThemeButton)
            Positioned(
              top: 30,
              left: 20,
              child: FloatingActionButton(
                onPressed: () {
                  themeProvider.toggleTheme();
                },
                backgroundColor: themeProvider.isDarkMode
                    ? const Color(0xFF4A64FE) // بنفسجي فاتح
                    : const Color(0xFF1E2046), // بنفسجي غامق
                child: Icon(
                  themeProvider.isDarkMode ? Icons.wb_sunny : Icons.dark_mode,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
