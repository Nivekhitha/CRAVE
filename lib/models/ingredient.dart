import 'package:hive/hive.dart';

part 'ingredient.g.dart';

@HiveType(typeId: 0)
class Ingredient extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String category;

  @HiveField(3)
  String? quantity;

  @HiveField(4)
  late DateTime addedDate;

  Ingredient({
    required this.id,
    required this.name,
    required this.category,
    this.quantity,
    DateTime? addedDate,
  }) : addedDate = addedDate ?? DateTime.now();

  // Helper method for display
  String get displayName => quantity != null ? '$name ($quantity)' : name;

  // For search/filtering
  bool matchesQuery(String query) {
    return name.toLowerCase().contains(query.toLowerCase()) ||
        category.toLowerCase().contains(query.toLowerCase());
  }

  @override
  String toString() => 'Ingredient(id: $id, name: $name, category: $category)';
}

// Common categories (for UI dropdowns)
class IngredientCategories {
  static const List<String> all = [
    'Produce',
    'Protein',
    'Dairy',
    'Grains',
    'Pantry',
    'Spices',
    'Beverages',
    'Frozen',
    'Other',
  ];
}
