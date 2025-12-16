import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'package:genome/src/theme_provider.dart';
import 'package:genome/src/utils/language_provider.dart';
import 'package:genome/src/utils/user_provider.dart';
import 'package:genome/src/utils/router_service.dart';

import 'firebase_options.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Screens
import 'package:genome/screens/home_screen.dart';
import 'package:genome/screens/PatientAppointment.dart';
import 'package:genome/screens/Review.dart';
import 'package:genome/screens/settings.dart';
import 'package:genome/src/auth/secure_account_screen.dart';
import 'package:genome/src/auth/verified_success_screen.dart';
import 'src/onboarding/onboarding_screen.dart';
import 'src/auth/auth_screen.dart';
import 'src/book/book_appointment_page.dart';
import 'src/chat/chat_screen.dart';
import 'src/book/desies_detection_screen.dart';
import 'package:translator/translator.dart';
import 'src/base_layout.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const GenoraApp(),
    ),
  );
}

// 🌐 Translation Service
class TranslatorService {
  final GoogleTranslator _translator = GoogleTranslator();

  Future<String> translateText(String text, String toLang) async {
    if (text.trim().isEmpty) return text;
    try {
      final translation = await _translator.translate(text, to: toLang);
      return translation.text;
    } catch (e) {
      return text;
    }
  }
}

final translatorService = TranslatorService();

// 📄 Auto Translate Text Widget
class AutoTranslateText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;

  const AutoTranslateText(this.text, {super.key, this.style, this.textAlign});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, langProvider, child) {
        final langCode = langProvider.locale.languageCode;
        return FutureBuilder<String>(
          future: translatorService.translateText(text, langCode),
          builder: (context, snapshot) {
            return Text(
              snapshot.data ?? text,
              style: style,
              textAlign: textAlign,
            );
          },
        );
      },
    );
  }
}

// 📄 Auto Translate TextField Widget
class AutoTranslateTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;

  const AutoTranslateTextField({
    super.key,
    required this.hintText,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, langProvider, child) {
        final langCode = langProvider.locale.languageCode;
        return FutureBuilder<String>(
          future: translatorService.translateText(hintText, langCode),
          builder: (context, snapshot) {
            return TextFormField(
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                hintText: snapshot.data ?? hintText,
                border: const OutlineInputBorder(),
              ),
            );
          },
        );
      },
    );
  }
}

// 🏁 Main App
class GenoraApp extends StatefulWidget {
  const GenoraApp({super.key});

  @override
  State<GenoraApp> createState() => _GenoraAppState();
}

class _GenoraAppState extends State<GenoraApp> {
  String _initialRoute = '/onboarding';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeRoute();
  }

  Future<void> _initializeRoute() async {
    try {
      final route = await RouterService.getInitialRoute();
      if (mounted) {
        setState(() {
          _initialRoute = route.isNotEmpty ? route : '/onboarding';
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      debugPrint('Error initializing route: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _initialRoute = '/onboarding';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show simple loading screen without providers
    if (_isLoading) {
      return MaterialApp(
        title: 'Genora',
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(
              color: const Color(0xFF1E2046),
            ),
          ),
        ),
      );
    }

    // Build main app with providers once route is determined
    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, languageProvider, child) {
        return MaterialApp(
          title: 'Genora',
          debugShowCheckedModeBanner: false,

          theme: themeProvider.lightTheme,
          darkTheme: themeProvider.darkTheme,
          themeMode: themeProvider.currentTheme,

          locale: languageProvider.locale,
          supportedLocales: const [Locale('en', ''), Locale('ar', '')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          initialRoute: _initialRoute,

          routes: {
            '/onboarding': (context) => const BaseLayout(
                  child: OnboardingScreen(),
                  showThemeButton: false,
                ),
            '/auth': (context) => const BaseLayout(child: AuthScreen()),
            '/secure': (context) => const BaseLayout(child: SecureAccountScreen()),
            '/verified': (context) =>
                const BaseLayout(child: VerifiedSuccessScreen()),

            '/home': (context) =>
                const BaseLayout(child: HomeScreen(), showThemeButton: false),

            '/settings': (context) => BaseLayout(child: SettingPage()),
            '/book': (context) => const BaseLayout(child: BookAppointmentPage()),
            '/chat': (context) => const BaseLayout(child: ChatScreen()),
            '/Disease': (context) =>
                const BaseLayout(child: DiseaseDetectionScreen()),
            '/PatientAppointment': (context) => const BaseLayout(
                  child: MyAppointmentsPage(),
                  showThemeButton: false,
                ),
          },
        );
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // أثناء تحميل بيانات اليوزر
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // المستخدم غير مسجل دخول → افتح صفحة AuthScreen
        if (!snapshot.hasData) {
          return const BaseLayout(child: AuthScreen());
        }

        // المستخدم مسجل دخول → افتح Home
        return const BaseLayout(child: HomeScreen(), showThemeButton: false);
      },
    );
  }
}
