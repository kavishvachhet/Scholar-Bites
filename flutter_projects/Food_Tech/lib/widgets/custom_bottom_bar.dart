import 'package:flutter/material.dart';

class CustomBottomBar extends StatelessWidget {
  const CustomBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9), // Glassmorphism base
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B1C28).withOpacity(0.15),
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
              color: const Color(0xFF8B1C28).withOpacity(0.15),
              shape: BoxShape.circle,
            )
          : null,
      child: Icon(
        icon,
        color: isActive
            ? const Color(0xFF8B1C28)
            : const Color(0xFF4A0E13).withOpacity(0.5),
        size: 24,
      ),
    );
  }
}
