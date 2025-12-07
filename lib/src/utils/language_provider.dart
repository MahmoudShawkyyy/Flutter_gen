import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('en'); // Default language

  Locale get locale => _locale;

  void toggleLanguage() {
    _locale =
        _locale.languageCode == 'en' ? const Locale('ar') : const Locale('en');
    notifyListeners();
  }

  void setLanguage(Locale locale) {
    _locale = locale;
    notifyListeners();
  }

  // ⭐⭐⭐ الميثود المطلوبة للسويتش بتاعك ⭐⭐⭐
  void setLocale(Locale newLocale) {
    if (!['en', 'ar'].contains(newLocale.languageCode)) return;
    _locale = newLocale;
    notifyListeners();
  }
}
