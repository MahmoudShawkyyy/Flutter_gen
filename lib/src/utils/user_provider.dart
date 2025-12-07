import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider with ChangeNotifier {
  String? _userName;
  String? _email;

  String? get name => _userName;
  String? get email => _email;

  // تحميل بيانات المستخدم من SharedPreferences
  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _userName = prefs.getString('userName');
    _email = prefs.getString('userEmail');
    notifyListeners();
  }

  // تعيين بيانات المستخدم وحفظها
  Future<void> setUser(String name, String email) async {
    _userName = name;
    _email = email;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', name);
    await prefs.setString('userEmail', email);
    
    notifyListeners();
  }

  // تحديث الاسم وحفظه
  Future<void> updateUserName(String newName) async {
    _userName = newName;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', newName);
    
    notifyListeners();
  }

  // مسح بيانات المستخدم
  Future<void> clearUser() async {
    _userName = null;
    _email = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userName');
    await prefs.remove('userEmail');
    
    notifyListeners();
  }
}