import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'utils/constants.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RoadResQApp());
}

class RoadResQApp extends StatelessWidget {
  const RoadResQApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = buildTheme();
    return MaterialApp(
      title: AppStrings.appName,
      theme: theme.copyWith(textTheme: GoogleFonts.poppinsTextTheme(theme.textTheme)),
      darkTheme:
          buildTheme(brightness: Brightness.dark).copyWith(textTheme: GoogleFonts.poppinsTextTheme()),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
