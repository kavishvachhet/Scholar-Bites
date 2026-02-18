import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/restaurant_model.dart';
import '../models/food_item.dart';
import '../models/cart_model.dart';
import '../widgets/food_card.dart';
import 'detail_screen.dart';

class RestaurantDetailScreen extends StatelessWidget {
  final Restaurant restaurant;

  const RestaurantDetailScreen({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF0F0),
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: const Color(0xFFFDF0F0),
            iconTheme: const IconThemeData(color: Color(0xFF4A0E13)),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                restaurant.name,
                style: const TextStyle(
                  color: Color(0xFF4A0E13),
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3.0,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
              background: Image.network(
                restaurant.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.restaurant, size: 50),
                  );
                },
              ),
            ),
          ),

          // Restaurant Info
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Color(0xFF8B1C28),
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${restaurant.rating} Rating',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A0E13),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.access_time,
                        color: Color(0xFF8B1C28),
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        restaurant.deliveryTime,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF4A0E13),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.delivery_dining,
                        color: Color(0xFF8B1C28),
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '\$${restaurant.deliveryFee}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF4A0E13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: restaurant.tags.map((tag) {
                      return Chip(
                        label: Text(
                          tag,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                        backgroundColor: const Color(
                          0xFF8B1C28,
                        ).withOpacity(0.8),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Menu',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A0E13),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Menu Grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                FoodItem food = restaurant.menu[index];
                return FoodCard(
                  food: food,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailScreen(food: food),
                      ),
                    );
                  },
                  onAddTap: () {
                    Provider.of<CartProvider>(
                      context,
                      listen: false,
                    ).addItem(food);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${food.name} added to cart'),
                        duration: const Duration(seconds: 1),
                        backgroundColor: const Color(0xFF8B1C28),
                      ),
                    );
                  },
                );
              }, childCount: restaurant.menu.length),
            ),
          ),

          // Bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }
}
