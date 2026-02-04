import 'package:flutter/material.dart';

class CustomBottomBar extends StatelessWidget {
  const CustomBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      height: 70,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E24).withOpacity(0.9), // Glassmorphism base
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.home_rounded, true),
          _buildNavItem(Icons.favorite_outline, false),
          _buildNavItem(Icons.notifications_none_rounded, false),
          _buildNavItem(Icons.person_outline_rounded, false),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, bool isActive) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: isActive
          ? BoxDecoration(
              color: const Color(0xFFFE2B75).withOpacity(0.15),
              shape: BoxShape.circle,
            )
          : null,
      child: Icon(
        icon,
        color: isActive
            ? const Color(0xFFFE2B75)
            : Colors.white.withOpacity(0.5),
        size: 24,
      ),
    );
  }
}
