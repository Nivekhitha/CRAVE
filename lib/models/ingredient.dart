import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  // Non-persisted field for demo
  String? unit;

  Ingredient({
    required this.id,
    required this.name,
    required this.category,
    this.quantity,
    this.unit,
    DateTime? addedDate,
  }) : addedDate = addedDate ?? DateTime.now();

  // Helper method for display
  String get displayName => quantity != null ? '$name ($quantity)' : name;

  // For search/filtering
  bool matchesQuery(String query) {
    return name.toLowerCase().contains(query.toLowerCase()) ||
        category.toLowerCase().contains(query.toLowerCase());
  }

  // --- Firestore Serialization ---

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'quantity': quantity,
      'addedDate': Timestamp.fromDate(addedDate),
      'unit': unit,
    };
  }

  factory Ingredient.fromMap(Map<String, dynamic> map, String docId) {
    return Ingredient(
      id: docId, // Use the document ID as the source of truth
      name: map['name'] ?? '',
      category: map['category'] ?? 'Other',
      quantity: map['quantity'],
      unit: map['unit'],
      addedDate: (map['addedDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
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
