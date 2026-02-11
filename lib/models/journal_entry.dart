import 'package:cloud_firestore/cloud_firestore.dart';

enum JournalMealType { breakfast, lunch, dinner, snack }

class JournalEntry {
  final String id;
  final JournalMealType mealType;
  final String name;
  final int calories;
  final int protein; // in grams
  final int carbs; // in grams
  final int fats; // in grams
  final DateTime timestamp;
  final String? recipeId;
  final String? notes;
  final bool isSynced;

  JournalEntry({
    required this.id,
    required this.mealType,
    required this.name,
    this.calories = 0,
    this.protein = 0,
    this.carbs = 0,
    this.fats = 0,
    required this.timestamp,
    this.recipeId,
    this.notes,
    this.isSynced = false,
  });

  // Convert from Hive Map
  factory JournalEntry.fromMap(Map<dynamic, dynamic> map) {
    return JournalEntry(
      id: map['id'] ?? '',
      mealType: JournalMealType.values[map['mealType'] ?? 0],
      name: map['name'] ?? 'Unknown Meal',
      calories: map['calories'] ?? 0,
      protein: map['protein'] ?? 0,
      carbs: map['carbs'] ?? 0,
      fats: map['fats'] ?? 0,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? DateTime.now().millisecondsSinceEpoch),
      recipeId: map['recipeId'],
      notes: map['notes'],
      isSynced: map['isSynced'] ?? false,
    );
  }

  // Convert to Hive Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mealType': mealType.index,
      'name': name,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'timestamp': timestamp.millisecondsSinceEpoch, // Store as Int for Hive compatibility
      'recipeId': recipeId,
      'notes': notes,
      'isSynced': isSynced,
    };
  }

  // Convert to Firestore Map (Timestamp object)
  Map<String, dynamic> toFirestoreMap() {
    return {
      'id': id,
      'mealType': mealType.name,
      'name': name,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'timestamp': Timestamp.fromDate(timestamp),
      'recipeId': recipeId,
      'notes': notes,
      // isSynced is not needed in Firestore
    };
  }
  
  // Creates a copy with synced status updated
  JournalEntry copyWithSynced(bool synced) {
    return JournalEntry(
      id: id,
      mealType: mealType,
      name: name,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fats: fats,
      timestamp: timestamp,
      recipeId: recipeId,
      notes: notes,
      isSynced: synced,
    );
  }
}
