import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/payment_method.dart';
import '../models/mechanic.dart';

class StorageKeys {
  static const String driver = 'driver_user';
  static const String mechanic = 'mechanic_user';
  static const String role = 'user_role';
  static const String paymentMethods = 'payment_methods';
  static const String password = 'user_password';
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

  Future<void> saveMechanic(Mechanic mechanic) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageKeys.mechanic, jsonEncode(mechanic.toJson()));
    await prefs.setString(StorageKeys.role, UserRole.mechanic.name);
  }

  Future<Mechanic?> getMechanic() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(StorageKeys.mechanic);
    if (jsonStr == null) return null;
    return Mechanic.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(StorageKeys.driver);
    await prefs.remove(StorageKeys.mechanic);
    await prefs.remove(StorageKeys.role);
    await prefs.remove(StorageKeys.paymentMethods);
    await prefs.remove(StorageKeys.password);
  }

  // Password management
  Future<void> savePassword(String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageKeys.password, password);
  }

  Future<String?> getPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(StorageKeys.password);
  }

  Future<bool> verifyPassword(String password) async {
    final savedPassword = await getPassword();
    return savedPassword == password;
  }

  // Payment methods management
  Future<void> savePaymentMethods(List<PaymentMethod> methods) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = methods.map((m) => m.toJson()).toList();
    await prefs.setString(StorageKeys.paymentMethods, jsonEncode(jsonList));
  }

  Future<List<PaymentMethod>> getPaymentMethods() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(StorageKeys.paymentMethods);
    if (jsonStr == null) return [];
    final jsonList = jsonDecode(jsonStr) as List<dynamic>;
    return jsonList.map((json) => PaymentMethod.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// Clears all persisted user-related data to safely log out the user.
  /// 
  /// This is a convenience wrapper around [clear] so that call sites
  /// can use a more semantic API (`logout()`).
  Future<void> logout() async {
    await clear();
  }
}


