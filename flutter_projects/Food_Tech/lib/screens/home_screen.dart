import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/food_item.dart';
import '../models/cart_model.dart';
import '../models/restaurant_model.dart';
import '../widgets/food_card.dart';
import '../widgets/custom_bottom_bar.dart';
import 'detail_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';
import 'favorites_screen.dart';
import 'navigation_screen.dart';
import 'restaurant_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;

  // Dummy Data - Food Items (Expanded for variety)
  final List<FoodItem> _allFoodItems = [
    const FoodItem(
      id: '1',
      name: 'Beet Leaf Bowl',
      imageUrl:
          'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?ixlib=rb-4.0.3&auto=format&fit=crop&w=1740&q=80',
      price: 24.00,
      calories: 434,
      weight: 200,
      description:
          'A fresh mix of beet leaves, spinach, and organic vegetables.',
      category: 'Special',
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
          'Toasted sourdough bread topped with creamy smashed avocado.',
      category: 'Breakfast',
    ),
    const FoodItem(
      id: '3',
      name: 'Butter Chicken',
      imageUrl:
          'https://images.unsplash.com/photo-1603894584373-5ac82b2ae398?ixlib=rb-4.0.3&auto=format&fit=crop&w=1740&q=80',
      price: 16.00,
      calories: 600,
      weight: 350,
      description:
          'Classic rich creamy tomato curry with tender chicken pieces.',
      category: 'Indian',
    ),
    const FoodItem(
      id: '4',
      name: 'Paneer Tikka',
      imageUrl:
          'https://images.unsplash.com/photo-1567188040759-fb8a883dc6d8?ixlib=rb-4.0.3&auto=format&fit=crop&w=1740&q=80',
      price: 14.00,
      calories: 450,
      weight: 300,
      description: 'Spiced and grilled cottage cheese cubes with veggies.',
      category: 'Indian',
    ),
    const FoodItem(
      id: '5',
      name: 'Pasta Carbonara',
      imageUrl:
          'https://images.unsplash.com/photo-1612874742237-6526221588e3?ixlib=rb-4.0.3&auto=format&fit=crop&w=1740&q=80',
      price: 22.00,
      calories: 550,
      weight: 300,
      description: 'Creamy pasta with pancetta, egg, and cheese.',
      category: 'Italian',
    ),
    const FoodItem(
      id: '6',
      name: 'Tiramisu',
      imageUrl:
          'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?ixlib=rb-4.0.3&auto=format&fit=crop&w=870&q=80',
      price: 12.00,
      calories: 400,
      weight: 150,
      description: 'Classic Italian coffee-flavored dessert.',
      category: 'Dessert',
    ),
    const FoodItem(
      id: '7',
      name: 'Croissant',
      imageUrl:
          'https://images.unsplash.com/photo-1555507036-ab1f4038808a?ixlib=rb-4.0.3&auto=format&fit=crop&w=1526&q=80',
      price: 5.00,
      calories: 250,
      weight: 80,
      description: 'Buttery, flaky, and golden-brown French pastry.',
      category: 'French',
    ),
  ];

  // Special Menu
  late final List<FoodItem> _specialMenu;

  // Restaurants
  late final List<Restaurant> _restaurants;

  @override
  void initState() {
    super.initState();
    _specialMenu = _allFoodItems
        .where((i) => i.id == '1' || i.id == '5' || i.id == '6')
        .toList();

    _restaurants = [
      Restaurant(
        id: 'r1',
        name: 'Truly Indian',
        imageUrl:
            'https://images.unsplash.com/photo-1585937421612-70a008356f36?ixlib=rb-4.0.3&auto=format&fit=crop&w=1740&q=80',
        rating: 4.8,
        tags: ['Spicy', 'Curry', 'Tandoor'],
        menu: _allFoodItems
            .where((i) => i.category == 'Indian' || i.category == 'Special')
            .toList(),
      ),
      Restaurant(
        id: 'r2',
        name: 'Global Bistro',
        imageUrl:
            'https://images.unsplash.com/photo-1559339352-11d035aa65de?ixlib=rb-4.0.3&auto=format&fit=crop&w=1548&q=80',
        rating: 4.5,
        tags: ['Italian', 'Continental', 'Salads'],
        menu: _allFoodItems
            .where((i) => i.category == 'Italian' || i.category == 'Breakfast')
            .toList(),
      ),
      Restaurant(
        id: 'r3',
        name: 'Cafe Delice',
        imageUrl:
            'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?ixlib=rb-4.0.3&auto=format&fit=crop&w=1678&q=80',
        rating: 4.9,
        tags: ['Dessert', 'French', 'Coffee'],
        menu: _allFoodItems
            .where((i) => i.category == 'French' || i.category == 'Dessert')
            .toList(),
      ),
    ];
  }

  void _onNavTapped(int index) {
    if (index == 0) return;
    if (index == 1)
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => FavoritesScreen()),
      );
    if (index == 2)
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CartScreen()),
      );
    if (index == 3)
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF0F0),
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Good Morning',
                              style: TextStyle(
                                color: Color(0xFF4A0E13),
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Kavish Vachhet',
                              style: TextStyle(
                                color: Color(0xFF8B1C28),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const NavigationScreen(),
                              ),
                            );
                          },
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF8B1C28).withOpacity(0.1),
                              border: Border.all(
                                color: const Color(0xFF8B1C28).withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.location_on_outlined,
                              color: Color(0xFF8B1C28),
                              size: 28,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Special Menu Section
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Special Menu of the Day',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A0E13),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    height: 280,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: _specialMenu.length,
                      itemBuilder: (context, index) {
                        return SizedBox(
                          width: 200,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: FoodCard(
                              food: _specialMenu[index],
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DetailScreen(food: _specialMenu[index]),
                                  ),
                                );
                              },
                              onAddTap: () {
                                Provider.of<CartProvider>(
                                  context,
                                  listen: false,
                                ).addItem(_specialMenu[index]);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${_specialMenu[index].name} added to cart',
                                    ),
                                    duration: const Duration(seconds: 1),
                                    backgroundColor: const Color(0xFF8B1C28),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Restaurants Section
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Restaurants',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A0E13),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _restaurants.length,
                    itemBuilder: (context, index) {
                      Restaurant restaurant = _restaurants[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RestaurantDetailScreen(
                                restaurant: restaurant,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.horizontal(
                                  left: Radius.circular(20),
                                ),
                                child: Image.network(
                                  restaurant.imageUrl,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 100,
                                      height: 100,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.store),
                                    );
                                  },
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        restaurant.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF4A0E13),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.star,
                                            color: Color(0xFF8B1C28),
                                            size: 16,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            restaurant.rating.toString(),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            restaurant.tags.first,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.all(12),
                                child: Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: Color(0xFF8B1C28),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomBottomBar(
              currentIndex: _currentNavIndex,
              onTap: _onNavTapped,
            ),
          ),
        ],
      ),
    );
  }
}
