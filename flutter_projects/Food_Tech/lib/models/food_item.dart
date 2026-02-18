class FoodItem {
  final String id;
  final String name;
  final String imageUrl;
  final double price;
  final int calories;
  final int weight;
  final String description;
  final String category;

  const FoodItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.calories,
    required this.weight,
    required this.description,
    this.category = 'Dinner', // Default to Dinner for now or require it
  });
}
