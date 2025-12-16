import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// RouterService handles initial route determination based on user state
class RouterService {
  // SharedPreferences keys
  static const String _keyIsFirstTime = 'is_first_time';
  static const String _keyIsSignedUp = 'is_signed_up';
  static const String _keyAuthToken = 'auth_token';

  /// Determines the initial route based on user state in SharedPreferences
  /// 
  /// Returns:
  /// - '/onboarding' if user is first time (is_first_time is null or true)
  /// - '/auth' if onboarding completed but not logged in (is_first_time is false and no auth_token)
  /// - '/home' if user has valid auth_token (logged in)
  static Future<String> getInitialRoute() async {
    const String defaultRoute = '/onboarding';
    
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check if user has completed onboarding
      final isFirstTime = prefs.getBool(_keyIsFirstTime);
      
      // Check if user has auth token (logged in)
      final authToken = prefs.getString(_keyAuthToken);

      // New User: is_first_time is null or true
      if (isFirstTime == null || isFirstTime == true) {
        return '/onboarding';
      }

      // Logged-in User: has valid auth_token
      if (authToken != null && authToken.isNotEmpty) {
        return '/home';
      }

      // Visitor User: onboarding completed but not logged in
      // (is_first_time is false AND no auth_token)
      return '/auth';
    } catch (e, stackTrace) {
      // On error, default to onboarding
      debugPrint('Error in getInitialRoute: $e');
      debugPrint('Stack trace: $stackTrace');
      return defaultRoute;
    }
  }

  /// Sets is_first_time to false (onboarding completed)
  static Future<void> setOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsFirstTime, false);
  }

  /// Sets is_signed_up to true (account created)
  static Future<void> setSignedUp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsSignedUp, true);
  }

  /// Sets auth_token (user logged in)
  static Future<void> setAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAuthToken, token);
  }

  /// Clears auth_token (user logged out)
  static Future<void> clearAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAuthToken);
  }

  /// Gets current auth token
  static Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAuthToken);
  }

  /// Checks if user is signed up
  static Future<bool> isSignedUp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsSignedUp) ?? false;
  }

  /// Checks if onboarding is completed
  static Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstTime = prefs.getBool(_keyIsFirstTime);
    return isFirstTime != null && isFirstTime == false;
  }
}

