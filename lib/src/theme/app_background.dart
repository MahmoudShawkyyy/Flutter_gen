import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  final Widget child;
  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [
                  Color(0xFF0A0A1F), // أزرق غامق جدًا من فوق
                  Color(0xFF1C1F40), // أزرق بنفسجي غامق من تحت
                ]
              : const [
                  Color(0xFFD9D9E9), // فاتح من فوق
                  Color(0xFFACACD3), // فاتح من تحت
                ],
        ),
      ),
      child: Stack(
        children: [
          // ✅ الخلفية (الصورة) بتتأثر بالثيم بشكل لطيف
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ColorFiltered(
              colorFilter: isDark
                  ? ColorFilter.mode(
                      Colors.blueGrey.withOpacity(0.35), // لمسة أزرق في الغامق
                      BlendMode.darken,
                    )
                  : const ColorFilter.mode(Colors.transparent, BlendMode.dst),
              child: Image.asset(
                'assets/images/dna_bg.png',
                fit: BoxFit.cover,
                height: 200,
              ),
            ),
          ),

          // ✅ نفس الـ Scaffold الشفاف
          Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(child: child),
          ),
        ],
      ),
    );
  }
}
