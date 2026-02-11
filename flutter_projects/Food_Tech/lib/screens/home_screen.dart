import 'package:flutter/material.dart';
import '../models/food_item.dart';
import '../widgets/category_pill.dart';
import '../widgets/food_card.dart';
import '../widgets/custom_bottom_bar.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCategoryIndex = 0;
  final List<String> _categories = [
    'Salads',
    'Dinner',
    'Lunch',
    'Breakfast',
    'Dessert',
  ];

  // Dummy Data
  final List<FoodItem> _foodItems = [
    const FoodItem(
      id: '1',
      name: 'Beet Leaf Bowl',
      imageUrl:
          'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?ixlib=rb-4.0.3&auto=format&fit=crop&w=1740&q=80', // Salad bowl
      price: 24.00,
      calories: 434,
      weight: 200,
      description:
          'A fresh mix of beet leaves, spinach, and organic vegetables topped with a light vinaigrette.',
    ),
    const FoodItem(
      id: '2',
      name: 'Avocado Toast',
      imageUrl:
          'https://images.unsplash.com/photo-1588137372308-15f75323a51d?ixlib=rb-4.0.3&auto=format&fit=crop&w=870&q=80',
      price: 18.50,
      calories: 320,
      weight: 150,
      description:
          'Toasted sourdough bread topped with creamy smashed avocado, cherry tomatoes, and radish.',
    ),
    const FoodItem(
      id: '3',
      name: 'Salmon Poke',
      imageUrl:
          'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?ixlib=rb-4.0.3&auto=format&fit=crop&w=1160&q=80',
      price: 28.00,
      calories: 510,
      weight: 300,
      description:
          'Fresh salmon poke bowl with rice, edamame, cucumber, and spicy mayo.',
    ),
    const FoodItem(
      id: '4',
      name: 'Quinoa Salad',
      imageUrl:
          'https://images.unsplash.com/photo-1505253716362-afaea1d3d1af?ixlib=rb-4.0.3&auto=format&fit=crop&w=987&q=80',
      price: 21.00,
      calories: 380,
      weight: 220,
      description:
          'Nutritious quinoa salad with black beans, corn, peppers, and lime dressing.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Good Morning',
                            style: TextStyle(
                              color: Color(0xFF4A0E13), // Dark Maroon
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Kavish Vachhet',
                            style: TextStyle(
                              color: Color(0xFF8B1C28), // Maroon Primary
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Color(0xFF8B1C28).withOpacity(0.2),
                            width: 1,
                          ),
                          image: const DecorationImage(
                            image: NetworkImage(
                              'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?ixlib=rb-4.0.3&auto=format&fit=crop&w=1760&q=80',
                            ), // Avatar
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Categories
                SizedBox(
                  height: 44,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      return CategoryPill(
                        title: _categories[index],
                        isSelected:
                            index ==
                            1, // 'Dinner' selected as per prompt, hardcoded index 1 (Dinner) for now
                        onTap: () {
                          setState(() {
                            // In a real app we would update the index, keeping 'Dinner' selected for demo as per prompt
                            _selectedCategoryIndex = index;
                          });
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // Grid
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      24,
                      0,
                      24,
                      100,
                    ), // Bottom padding for floating bar
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: _foodItems.length,
                    itemBuilder: (context, index) {
                      return FoodCard(
                        food: _foodItems[index],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DetailScreen(food: _foodItems[index]),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Floating Bottom Bar
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomBottomBar(),
          ),
        ],
      ),
    );
  }
}
