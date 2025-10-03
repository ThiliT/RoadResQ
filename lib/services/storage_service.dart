import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class StorageKeys {
  static const String driver = 'driver_user';
  static const String role = 'user_role';
}

class StorageService {
  Future<void> saveDriver(DriverUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageKeys.driver, jsonEncode(user.toJson()));
    await prefs.setString(StorageKeys.role, UserRole.driver.name);
  }

  Future<DriverUser?> getDriver() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(StorageKeys.driver);
    if (jsonStr == null) return null;
    return DriverUser.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
  }

  Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(StorageKeys.role);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(StorageKeys.driver);
    await prefs.remove(StorageKeys.role);
  }
}


