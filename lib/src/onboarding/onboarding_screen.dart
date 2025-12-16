import 'package:flutter/material.dart';
import 'package:genome/main.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../theme_provider.dart';
import '../utils/language_provider.dart';  // Import LanguageProvider
import '../utils/router_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();

  Future<void> _goToAuth() async {
    // Mark onboarding as completed
    await RouterService.setOnboardingCompleted();
    // Navigate to auth screen
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    final isEnglish = langProvider.locale.languageCode == 'en';  // Check if language is English

    return AppBackground(
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 10, right: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 🌐 Language Toggle Icon beside Skip Button
                  GestureDetector(
                    onTap: () => langProvider.toggleLanguage(),
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.grey[200],
                      child: Text(
                        isEnglish ? 'EN' : 'AR',  // Show EN or AR
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Skip button
                  TextButton(
                    onPressed: _goToAuth,
                    child: const AutoTranslateText(
                      "Skip",
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: PageView(
              controller: _controller,
              children: [
                _OnboardPage(
                  titleTop: "WELCOME TO",
                  titleBottom: "GENORA",
                  description: "",
                  buttonText: "START",
                  imagePath: "assets/images/illustration1.png",
                  controller: _controller,
                  isLast: false,
                  goToAuth: _goToAuth,
                ),
                _OnboardPage(
                  titleTop: "Get To Know Your",
                  titleBottom: "Genes",
                  description: "AI driven tests to know more about your genes",
                  buttonText: "Next",
                  imagePath: "assets/images/illustration2.png",
                  controller: _controller,
                  isLast: false,
                  goToAuth: _goToAuth,
                ),
                _OnboardPage(
                  titleTop: "Get To Know Your",
                  titleBottom: "Children Genes",
                  description:
                      "AI driven tests to know more about your children genes",
                  buttonText: "Next",
                  imagePath: "assets/images/illustration3.png",
                  controller: _controller,
                  isLast: false,
                  goToAuth: _goToAuth,
                ),
                _OnboardPage(
                  titleTop: "Get To Know Your",
                  titleBottom: "Genes",
                  description: "AI driven tests to know more about your genes",
                  buttonText: "Get Started",
                  imagePath: "assets/images/illustration4.png",
                  controller: _controller,
                  isLast: true,
                  goToAuth: _goToAuth,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SmoothPageIndicator(
            controller: _controller,
            count: 4,
            effect: const ExpandingDotsEffect(
              activeDotColor: Color(0xFF1E2046),
              dotHeight: 8,
              dotWidth: 8,
            ),
          ),
          const SizedBox(height: 25),
        ],
      ),
    );
  }
}

class _OnboardPage extends StatelessWidget {
  final String titleTop;
  final String titleBottom;
  final String description;
  final String buttonText;
  final String imagePath;
  final PageController controller;
  final bool isLast;
  final VoidCallback goToAuth;

  const _OnboardPage({
    required this.titleTop,
    required this.titleBottom,
    required this.description,
    required this.buttonText,
    required this.imagePath,
    required this.controller,
    required this.isLast,
    required this.goToAuth,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Spacer(),
          AutoTranslateText(
            titleTop,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),
          AutoTranslateText(
            titleBottom,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: titleBottom.contains("GENORA")
                  ? const Color(0xFF1E2046)
                  : Colors.redAccent,
            ),
          ),
          const SizedBox(height: 10),
          if (description.isNotEmpty)
            AutoTranslateText(
              description,
              style: const TextStyle(color: Colors.black54, fontSize: 14),
            ),
          const SizedBox(height: 30),
          Image.asset(imagePath, height: 230, fit: BoxFit.contain),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E2046),
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () {
                if (isLast) {
                  goToAuth();
                } else {
                  controller.nextPage(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOut,
                  );
                }
              },
              child: AutoTranslateText(buttonText),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class AppBackground extends StatelessWidget {
  final Widget child;
  const AppBackground({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: themeProvider.isDarkMode
              ? [Color(0xFF0D0D1A), Color(0xFF1E2046)] // Dark Mode
              : [Color(0xFFB2B7FF), Color(0xFFE6E7FF)], // Light Mode
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(child: child),
    );
  }
}
