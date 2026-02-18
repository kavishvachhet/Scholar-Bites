import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/cart_model.dart';
import 'screens/splash_screen.dart';

import 'models/favorites_model.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(FoodItemAdapter());
  Hive.registerAdapter(CartItemAdapter());
  await Hive.openBox<CartItem>('cartBox');

  runApp(const FoodTechApp());
}

class FoodTechApp extends StatelessWidget {
  const FoodTechApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
      ],
      child: MaterialApp(
        title: 'Food Tech',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFFDF0F0), // Cream background
          primaryColor: const Color(0xFF8B1C28), // Maroon primary
          brightness: Brightness.light,
          textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)
              .apply(
                bodyColor: const Color(0xFF4A0E13),
                displayColor: const Color(0xFF4A0E13),
              ), // Dark Maroon text
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF8B1C28),
            secondary: Color(0xFFF4B3B3), // Peach/Light Pink accent
            surface: Colors.white,
            background: Color(0xFFFDF0F0),
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
