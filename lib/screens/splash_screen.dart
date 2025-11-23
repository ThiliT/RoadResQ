import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../services/storage_service.dart';
import '../models/user.dart';
import 'welcome_screen.dart';
import 'driver/driver_dashboard.dart';
import 'mechanic/mechanic_dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Wait for splash screen display
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final storageService = StorageService();
    final role = await storageService.getRole();

    Widget targetScreen;
    if (role == UserRole.driver.name) {
      // Check if driver data exists
      final driver = await storageService.getDriver();
      if (driver != null) {
        targetScreen = const DriverDashboardScreen();
      } else {
        targetScreen = const WelcomeScreen();
      }
    } else if (role == UserRole.mechanic.name) {
      // Navigate to mechanic dashboard if mechanic is registered
      // Note: Currently mechanic registration doesn't save to storage,
      // but we check for the role anyway
      targetScreen = const MechanicDashboardScreen();
    } else {
      // No user registered, show welcome screen
      targetScreen = const WelcomeScreen();
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, __, ___) => targetScreen,
        transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.warmSunset),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.emergency_share_rounded, size: 96, color: Colors.white),
              SizedBox(height: 16),
              Text(AppStrings.appName, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}


