import 'food_item.dart';

class Restaurant {
  final String id;
  final String name;
  final String imageUrl;
  final double rating;
  final List<String> tags;
  final List<FoodItem> menu;
  final String deliveryTime;
  final double deliveryFee;

  Restaurant({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.rating,
    required this.tags,
    required this.menu,
    this.deliveryTime = '30-45 min',
    this.deliveryFee = 2.99,
  });
}
