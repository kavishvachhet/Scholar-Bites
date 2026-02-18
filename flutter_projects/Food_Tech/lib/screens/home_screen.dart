import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/food_item.dart';
import '../models/cart_model.dart';
import '../models/restaurant_model.dart';
import '../data/mock_data.dart';
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

  // Special Menu
  late final List<FoodItem> _specialMenu;

  // Restaurants
  late final List<Restaurant> _restaurants;

  @override
  void initState() {
    super.initState();
    _specialMenu = allFoodItems
        .where((i) => i.id == '1' || i.id == '5' || i.id == '6')
        .toList();

    _restaurants = allRestaurants;
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
