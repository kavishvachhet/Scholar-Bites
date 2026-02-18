import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/favorites_model.dart';
import '../models/food_item.dart'; // Need access to the list or pass it
import '../models/cart_model.dart';
import '../data/mock_data.dart';
import '../widgets/food_card.dart';
import 'detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  // Ideally, this list should come from a central data source or be passed in.
  // For now, I'll duplicate the dummy data or we should move it to a Provider.
  // To avoid duplication issues, I will accept the list of items or just redefine it.
  // Better approach: Let's assume HomeScreen has the source of truth, but for now
  // I will redefine the list here to keep it simple as I can't easily refactor the whole app to use a ProductsProvider yet.
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF4A0E13),
      ),
      body: Consumer<FavoritesProvider>(
        builder: (context, favoritesProvider, child) {
          final favoriteItems = favoritesProvider.getFavoriteItems(
            allFoodItems,
          );

          if (favoriteItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: const Color(0xFF8B1C28).withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No favorites yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF4A0E13),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: favoriteItems.length,
            itemBuilder: (context, index) {
              FoodItem food = favoriteItems[index];
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
            },
          );
        },
      ),
    );
  }
}
