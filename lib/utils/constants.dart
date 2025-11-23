import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFFF6B6B); // Emergency Red/Orange
  static const Color primaryAlt = Color(0xFFFF8C42); // Alternate Orange
  static const Color secondary = Color(0xFF2D3561); // Deep Blue
  static const Color accent = Color(0xFFFFD93D); // Safety Yellow
  static const Color success = Color(0xFF6BCF7F);
  static const Color background = Color(0xFFF8F9FA);
}

class AppText {
  static const double h1 = 28;
  static const double h2 = 24;
  static const double body = 16;
  static const double button = 18;
}

class AppStrings {
  static const String appName = 'RoadResQ';
  // Backend SMS number for offline emergency requests
  static const String backendSmsNumber = '0715562360'; // Replace with your actual backend SMS shortcode
}

class AppGradients {
  static const LinearGradient warmSunset = LinearGradient(
    colors: [AppColors.primary, AppColors.primaryAlt],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient deepOcean = LinearGradient(
    colors: [AppColors.secondary, Colors.black87],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

ThemeData buildTheme({Brightness brightness = Brightness.light}) {
  final isDark = brightness == Brightness.dark;
  final base = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
    ),
    useMaterial3: true,
    scaffoldBackgroundColor: isDark ? const Color(0xFF0F1115) : AppColors.background,
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
  return base.copyWith(
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: Colors.transparent,
      foregroundColor: isDark ? Colors.white : Colors.black87,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontSize: AppText.button, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 4,
      color: isDark ? const Color(0xFF151923) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}


