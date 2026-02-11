import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const FoodTechApp());
}

class FoodTechApp extends StatelessWidget {
  const FoodTechApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Tech',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF0E0E10),
        primaryColor: const Color(0xFFFE2B75),
        brightness: Brightness.dark,
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ).apply(bodyColor: Colors.white, displayColor: Colors.white),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFE2B75),
          secondary: Color(0xFFFE2B75),
          surface: Color(
            0xFF1E1E24,
          ), // Slightly lighter implementation for cards
          background: Color(0xFF0E0E10),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
