import 'package:flutter/material.dart';

class CustomBottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomBar({
    super.key,
    this.currentIndex = 0,
    required this.onTap,
  });

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
          _buildNavItem(Icons.home_rounded, 0),
          _buildNavItem(Icons.favorite_outline, 1),
          _buildNavItem(Icons.shopping_bag_outlined, 2),
          _buildNavItem(Icons.person_outline_rounded, 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    bool isActive = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
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
      ),
    );
  }
}
