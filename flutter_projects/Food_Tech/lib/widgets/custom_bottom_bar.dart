import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cart_model.dart';

class CustomBottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  final GlobalKey? cartKey;
  final GlobalKey? favKey;

  const CustomBottomBar({
    super.key,
    this.currentIndex = 0,
    required this.onTap,
    this.cartKey,
    this.favKey,
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
          _buildNavItem(Icons.favorite_outline, 1, key: favKey),
          _buildNavItem(Icons.shopping_bag_outlined, 2, key: cartKey),
          _buildNavItem(Icons.person_outline_rounded, 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, {GlobalKey? key}) {
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
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              icon,
              key: key,
              color: isActive
                  ? const Color(0xFF8B1C28)
                  : const Color(0xFF4A0E13).withOpacity(0.5),
              size: 24,
            ),
            if (index == 2)
              Positioned(
                top: -5,
                right: -5,
                child: Consumer<CartProvider>(
                  builder: (context, cart, child) {
                    if (cart.items.isEmpty) return const SizedBox.shrink();
                    return Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFF8B1C28),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${cart.items.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
