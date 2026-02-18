import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/favorites_model.dart';
import '../models/food_item.dart'; // Need access to the list or pass it
import '../models/cart_model.dart';
import '../widgets/food_card.dart';
import 'detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  // Ideally, this list should come from a central data source or be passed in.
  // For now, I'll duplicate the dummy data or we should move it to a Provider.
  // To avoid duplication issues, I will accept the list of items or just redefine it.
  // Better approach: Let's assume HomeScreen has the source of truth, but for now
  // I will redefine the list here to keep it simple as I can't easily refactor the whole app to use a ProductsProvider yet.
  final List<FoodItem> allFoodItems = const [
    FoodItem(
      id: '1',
      name: 'Beet Leaf Bowl',
      imageUrl:
          'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?ixlib=rb-4.0.3&auto=format&fit=crop&w=1740&q=80',
      price: 24.00,
      calories: 434,
      weight: 200,
      description:
          'A fresh mix of beet leaves, spinach, and organic vegetables topped with a light vinaigrette.',
      category: 'Salads',
    ),
    FoodItem(
      id: '2',
      name: 'Avocado Toast',
      imageUrl:
          'https://images.unsplash.com/photo-1588137372308-15f75323a51d?ixlib=rb-4.0.3&auto=format&fit=crop&w=870&q=80',
      price: 18.50,
      calories: 320,
      weight: 150,
      description:
          'Toasted sourdough bread topped with creamy smashed avocado, cherry tomatoes, and radish.',
      category: 'Breakfast',
    ),
    FoodItem(
      id: '3',
      name: 'Salmon Poke',
      imageUrl:
          'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?ixlib=rb-4.0.3&auto=format&fit=crop&w=1160&q=80',
      price: 28.00,
      calories: 510,
      weight: 300,
      description:
          'Fresh salmon poke bowl with rice, edamame, cucumber, and spicy mayo.',
      category: 'Lunch',
    ),
    FoodItem(
      id: '4',
      name: 'Quinoa Salad',
      imageUrl:
          'https://images.unsplash.com/photo-1505253716362-afaea1d3d1af?ixlib=rb-4.0.3&auto=format&fit=crop&w=987&q=80',
      price: 21.00,
      calories: 380,
      weight: 220,
      description:
          'Nutritious quinoa salad with black beans, corn, peppers, and lime dressing.',
      category: 'Salads',
    ),
    FoodItem(
      id: '5',
      name: 'Steak Dinner',
      imageUrl:
          'https://images.unsplash.com/photo-1546241072-48010ad28d5a?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      price: 32.00,
      calories: 700,
      weight: 400,
      description: 'Juicy steak with mashed potatoes and asparagus.',
      category: 'Dinner',
    ),
  ];

  FavoritesScreen({super.key});

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
