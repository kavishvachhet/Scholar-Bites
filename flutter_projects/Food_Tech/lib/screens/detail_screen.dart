import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/food_item.dart';
import '../models/favorites_model.dart';

class DetailScreen extends StatelessWidget {
  final FoodItem food;

  const DetailScreen({super.key, required this.food});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF0F0),
      body: Stack(
        children: [
          // Background Image / Hero
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.55,
            child: Hero(
              tag: 'food-image-${food.id}',
              child: Image.network(
                food.imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                          : null,
                      color: const Color(0xFF8B1C28),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFFFDF0F0),
                    child: const Center(
                      child: Icon(
                        Icons.fastfood,
                        color: Color(0xFF8B1C28),
                        size: 60,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Floating Leaf Elements (Simulated)
          Positioned(
            top: 100,
            right: -20,
            child: Opacity(
              opacity: 0.6,
              child: Transform.rotate(
                angle: 0.5,
                child: Icon(
                  Icons.eco,
                  color: const Color(0xFF8B1C28).withOpacity(0.4),
                  size: 100,
                ),
              ),
            ),
          ),
          Positioned(
            top: 250,
            left: -30,
            child: Opacity(
              opacity: 0.4,
              child: Transform.rotate(
                angle: -0.5,
                child: Icon(
                  Icons.eco,
                  color: const Color(0xFF8B1C28).withOpacity(0.3),
                  size: 150,
                ),
              ),
            ),
          ),

          // Top Navigation (Back Button)
          Positioned(
            top: 50,
            left: 24,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(Icons.arrow_back, color: Color(0xFF4A0E13)),
              ),
            ),
          ),

          // Like Button (Top Right)
          Positioned(
            top: 50,
            right: 24,
            child: Consumer<FavoritesProvider>(
              builder: (context, favorites, child) {
                final isFavorite = favorites.isFavorite(food.id);
                return GestureDetector(
                  onTap: () {
                    favorites.toggleFavorite(food.id);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: const Color(0xFF8B1C28),
                    ),
                  ),
                );
              },
            ),
          ),

          // Content Sheet
          Positioned(
            top: MediaQuery.of(context).size.height * 0.5,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                // deep charcoal background or slightly lighter for contrast
                color: const Color(0xFFFDF0F0),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B1C28).withOpacity(0.1),
                    blurRadius: 30,
                    offset: const Offset(0, -10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    food.name,
                    style: const TextStyle(
                      color: Color(0xFF4A0E13),
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Metadata
                  Row(
                    children: [
                      _buildMetadataChip(
                        Icons.local_fire_department_rounded,
                        '${food.calories} cal',
                      ),
                      const SizedBox(width: 16),
                      _buildMetadataChip(
                        Icons.scale_rounded,
                        '${food.weight}g',
                      ),
                      const SizedBox(width: 16),
                      _buildMetadataChip(Icons.star_rounded, '4.8'),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Description
                  Text(
                    'Description',
                    style: TextStyle(
                      color: Color(0xFF4A0E13),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    food.description,
                    style: TextStyle(
                      color: const Color(0xFF4A0E13).withOpacity(0.7),
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),

                  const Spacer(),

                  // Bottom Action Bar
                  Row(
                    children: [
                      // Price
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Price',
                            style: TextStyle(
                              color: const Color(0xFF4A0E13).withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '\$${food.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Color(0xFF8B1C28),
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 32),

                      // Add to Cart Button
                      Expanded(
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B1C28),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF8B1C28).withOpacity(0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.shopping_bag_outlined,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Add to cart',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF8B1C28).withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF8B1C28).withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF8B1C28), size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: const Color(0xFF4A0E13).withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
