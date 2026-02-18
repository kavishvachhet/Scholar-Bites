import 'package:flutter/foundation.dart';
import 'food_item.dart';

class FavoritesProvider with ChangeNotifier {
  final Set<String> _favoriteIds = {};

  bool isFavorite(String id) {
    return _favoriteIds.contains(id);
  }

  void toggleFavorite(String id) {
    if (_favoriteIds.contains(id)) {
      _favoriteIds.remove(id);
    } else {
      _favoriteIds.add(id);
    }
    notifyListeners();
  }

  // Helper method to get favorite items from a list of all items
  List<FoodItem> getFavoriteItems(List<FoodItem> allItems) {
    return allItems.where((item) => _favoriteIds.contains(item.id)).toList();
  }
}
