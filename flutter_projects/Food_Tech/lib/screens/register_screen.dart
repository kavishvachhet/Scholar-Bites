import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';
import 'home_screen.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E10),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Create Account',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign up to get started',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 40),

              // Form
              const CustomTextField(
                hintText: 'Full Name',
                prefixIcon: Icons.person_rounded,
              ),
              const SizedBox(height: 20),
              const CustomTextField(
                hintText: 'Email Address',
                prefixIcon: Icons.email_rounded,
              ),
              const SizedBox(height: 20),
              const CustomTextField(
                hintText: 'Password',
                prefixIcon: Icons.lock_rounded,
                isPassword: true,
              ),
              const SizedBox(height: 20),
              const CustomTextField(
                hintText: 'Confirm Password',
                prefixIcon: Icons.lock_outline_rounded,
                isPassword: true,
              ),

              const SizedBox(height: 40),
              PrimaryButton(
                text: 'Sign Up',
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                    (route) => false,
                  );
                },
              ),

              const SizedBox(height: 40),

              // Login Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Login',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFFFE2B75),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
