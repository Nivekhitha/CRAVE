import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'recipe.dart';

part 'meal_plan.g.dart';

@HiveType(typeId: 4)
class MealPlan extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late DateTime date;

  @HiveField(2)
  late List<PlannedMeal> meals;

  @HiveField(3)
  late DateTime createdAt;

  @HiveField(4)
  DateTime? updatedAt;

  @HiveField(5)
  String? notes; // User notes for the day

  @HiveField(6)
  bool isCompleted; // Did user cook all planned meals?

  @HiveField(7)
  List<String>? shoppingList; // Auto-generated from planned meals

  MealPlan({
    required this.id,
    required this.date,
    required this.meals,
    required this.createdAt,
    this.updatedAt,
    this.notes,
    this.isCompleted = false,
    this.shoppingList,
  });

  // Convert to/from Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': Timestamp.fromDate(date),
      'meals': meals.map((meal) => meal.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'notes': notes,
      'isCompleted': isCompleted,
      'shoppingList': shoppingList,
    };
  }

  factory MealPlan.fromMap(Map<String, dynamic> map, String id) {
    return MealPlan(
      id: id,
      date: (map['date'] as Timestamp).toDate(),
      meals: (map['meals'] as List<dynamic>)
          .map((mealMap) => PlannedMeal.fromMap(mealMap))
          .toList(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null 
          ? (map['updatedAt'] as Timestamp).toDate() 
          : null,
      notes: map['notes'],
      isCompleted: map['isCompleted'] ?? false,
      shoppingList: map['shoppingList'] != null 
          ? List<String>.from(map['shoppingList']) 
          : null,
    );
  }

  // Helper methods
  bool get hasBreakfast => meals.any((meal) => meal.mealType == MealType.breakfast);
  bool get hasLunch => meals.any((meal) => meal.mealType == MealType.lunch);
  bool get hasDinner => meals.any((meal) => meal.mealType == MealType.dinner);
  bool get hasSnack => meals.any((meal) => meal.mealType == MealType.snack);

  int get totalCalories => meals.fold<int>(0, (sum, meal) => sum + (meal.recipe?.calories ?? 0));
  int get totalCookTime => meals.fold<int>(0, (sum, meal) => sum + (meal.recipe?.cookTime ?? 0));

  List<String> get allIngredients {
    final ingredients = <String>[];
    for (final meal in meals) {
      if (meal.recipe != null) {
        ingredients.addAll(meal.recipe!.ingredients);
      }
    }
    return ingredients.toSet().toList(); // Remove duplicates
  }

  void markAsCompleted() {
    isCompleted = true;
    updatedAt = DateTime.now();
    save();
  }

  void addMeal(PlannedMeal meal) {
    meals.add(meal);
    updatedAt = DateTime.now();
    save();
  }

  void removeMeal(String mealId) {
    meals.removeWhere((meal) => meal.id == mealId);
    updatedAt = DateTime.now();
    save();
  }

  void updateNotes(String newNotes) {
    notes = newNotes;
    updatedAt = DateTime.now();
    save();
  }
}

@HiveType(typeId: 5)
class PlannedMeal extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late MealType mealType;

  @HiveField(2)
  Recipe? recipe; // Can be null for custom meals

  @HiveField(3)
  String? customMealName; // For meals without recipes

  @HiveField(4)
  DateTime? scheduledTime; // Specific time to cook/eat

  @HiveField(5)
  bool isCooked; // Did user actually cook this?

  @HiveField(6)
  String? notes; // Meal-specific notes

  @HiveField(7)
  int? servings; // How many servings planned

  PlannedMeal({
    required this.id,
    required this.mealType,
    this.recipe,
    this.customMealName,
    this.scheduledTime,
    this.isCooked = false,
    this.notes,
    this.servings,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mealType': mealType.index,
      'recipe': recipe?.toMap(),
      'customMealName': customMealName,
      'scheduledTime': scheduledTime != null 
          ? Timestamp.fromDate(scheduledTime!) 
          : null,
      'isCooked': isCooked,
      'notes': notes,
      'servings': servings,
    };
  }

  factory PlannedMeal.fromMap(Map<String, dynamic> map) {
    return PlannedMeal(
      id: map['id'],
      mealType: MealType.values[map['mealType']],
      recipe: map['recipe'] != null 
          ? Recipe.fromMap(map['recipe'], map['recipe']['id']) 
          : null,
      customMealName: map['customMealName'],
      scheduledTime: map['scheduledTime'] != null 
          ? (map['scheduledTime'] as Timestamp).toDate() 
          : null,
      isCooked: map['isCooked'] ?? false,
      notes: map['notes'],
      servings: map['servings'],
    );
  }

  String get displayName => recipe?.title ?? customMealName ?? 'Unnamed Meal';
  
  void markAsCooked() {
    isCooked = true;
    save();
  }
}

@HiveType(typeId: 6)
enum MealType {
  @HiveField(0)
  breakfast,
  
  @HiveField(1)
  lunch,
  
  @HiveField(2)
  dinner,
  
  @HiveField(3)
  snack,
}

extension MealTypeExtension on MealType {
  String get displayName {
    switch (this) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
      case MealType.snack:
        return 'Snack';
    }
  }

  String get emoji {
    switch (this) {
      case MealType.breakfast:
        return '🌅';
      case MealType.lunch:
        return '☀️';
      case MealType.dinner:
        return '🌙';
      case MealType.snack:
        return '🍎';
    }
  }
}