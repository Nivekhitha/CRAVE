import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'grocery_item.g.dart';

@HiveType(typeId: 2)
class GroceryItem extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late bool isChecked;

  @HiveField(3)
  late String category;

  @HiveField(4)
  String? quantity;

  @HiveField(5)
  late DateTime addedDate;

  @HiveField(6)
  String? recipeId; // Which recipe needs this ingredient

  GroceryItem({
    required this.id,
    required this.name,
    this.isChecked = false,
    required this.category,
    this.quantity,
    DateTime? addedDate,
    this.recipeId,
  }) : addedDate = addedDate ?? DateTime.now();

  // Toggle checked state
  void toggle() {
    isChecked = !isChecked;
    save(); // Hive auto-save
  }

  // For display
  String get displayName => quantity != null ? '$name ($quantity)' : name;

  // --- Firestore Serialization ---

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'isChecked': isChecked,
      'category': category,
      'quantity': quantity,
      'addedDate': Timestamp.fromDate(addedDate),
      'recipeId': recipeId,
    };
  }

  factory GroceryItem.fromMap(Map<String, dynamic> map, String docId) {
    return GroceryItem(
      id: docId,
      name: map['name'] ?? '',
      isChecked: map['isChecked'] ?? false,
      category: map['category'] ?? 'Other',
      quantity: map['quantity'],
      addedDate: (map['addedDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      recipeId: map['recipeId'],
    );
  }

  @override
  String toString() => 'GroceryItem(name: $name, checked: $isChecked)';
}
