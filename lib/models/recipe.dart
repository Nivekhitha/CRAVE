import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'recipe.g.dart';

@HiveType(typeId: 1)
class Recipe extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late String source; // 'manual' or 'video'

  @HiveField(3)
  String? sourceUrl; // YouTube/Instagram link

  @HiveField(4)
  late List<String> ingredients;

  @HiveField(5)
  String? imageUrl;

  @HiveField(6)
  int? prepTime; // in minutes

  @HiveField(7)
  int? cookTime; // in minutes

  @HiveField(8)
  int? servings;

  @HiveField(9)
  String? instructions;

  @HiveField(10)
  late bool isPremium; // For RevenueCat paywall

  @HiveField(11)
  late DateTime createdAt;

  @HiveField(12)
  DateTime? lastCookedAt;

  @HiveField(13)
  int cookCount; // How many times user cooked this

  @HiveField(14)
  List<String>? tags; // e.g., 'quick', 'healthy', 'vegetarian'

  @HiveField(15)
  String? difficulty; // 'Easy', 'Medium', 'Hard'

  @HiveField(16)
  double? calories; // Nutritional information

  @HiveField(17)
  double? protein;

  @HiveField(18)
  double? carbs;

  @HiveField(19)
  double? fats;

  @HiveField(20)
  double? fiber;

  @HiveField(21)
  double? sugar;

  @HiveField(22)
  double? sodium; // mg

  @HiveField(23)
  Map<String, double>? vitamins; // Vitamin A, C, D, etc.

  @HiveField(24)
  Map<String, double>? minerals; // Iron, Calcium, etc.

  @HiveField(25)
  int? glycemicIndex;

  // Non-persisted field for demo flow (Extraction -> Editor)
  String? description;

  Recipe({
    required this.id,
    required this.title,
    required this.source,
    this.sourceUrl,
    required this.ingredients,
    this.imageUrl,
    this.prepTime,
    this.cookTime,
    this.servings,
    this.instructions,
    this.isPremium = false,
    DateTime? createdAt,
    this.lastCookedAt,
    this.cookCount = 0,
    this.tags,
    this.difficulty,
    this.description,
    this.calories,
    this.protein,
    this.carbs,
    this.fats,
    this.fiber,
    this.sugar,
    this.sodium,
    this.vitamins,
    this.minerals,
    this.glycemicIndex,
  }) : createdAt = createdAt ?? DateTime.now();

  // Calculated properties
  int? get totalTime {
    if (prepTime != null && cookTime != null) {
      return prepTime! + cookTime!;
    }
    return prepTime ?? cookTime;
  }

  bool get isVideoRecipe => source == 'video' && sourceUrl != null;

  // Mark as cooked
  void markAsCooked() {
    lastCookedAt = DateTime.now();
    cookCount++;
    save(); // Hive auto-save
    // Note: Firestore sync needs to be handled by service
  }

  // For search
  bool matchesQuery(String query) {
    final q = query.toLowerCase();
    return title.toLowerCase().contains(q) ||
        ingredients.any((i) => i.toLowerCase().contains(q)) ||
        (tags?.any((t) => t.toLowerCase().contains(q)) ?? false);
  }

  // --- Firestore Serialization ---

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'source': source,
      'sourceUrl': sourceUrl,
      'ingredients': ingredients,
      'imageUrl': imageUrl,
      'prepTime': prepTime,
      'cookTime': cookTime,
      'servings': servings,
      'instructions': instructions,
      'isPremium': isPremium,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastCookedAt': lastCookedAt != null ? Timestamp.fromDate(lastCookedAt!) : null,
      'cookCount': cookCount,
      'tags': tags,
      'difficulty': difficulty,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'fiber': fiber,
      'sugar': sugar,
      'sodium': sodium,
      'vitamins': vitamins,
      'minerals': minerals,
      'glycemicIndex': glycemicIndex,
    };
  }

  factory Recipe.fromMap(Map<String, dynamic> map, String docId) {
    return Recipe(
      id: docId,
      title: map['title'] ?? 'Untitled Recipe',
      source: map['source'] ?? 'manual',
      sourceUrl: map['sourceUrl'],
      ingredients: List<String>.from(map['ingredients'] ?? []),
      imageUrl: map['imageUrl'],
      prepTime: map['prepTime'],
      cookTime: map['cookTime'],
      servings: map['servings'],
      instructions: map['instructions'],
      isPremium: map['isPremium'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastCookedAt: (map['lastCookedAt'] as Timestamp?)?.toDate(),
      cookCount: map['cookCount'] ?? 0,
      tags: map['tags'] != null ? List<String>.from(map['tags']) : null,
      difficulty: map['difficulty'],
      calories: map['calories']?.toDouble(),
      protein: map['protein']?.toDouble(),
      carbs: map['carbs']?.toDouble(),
      fats: map['fats']?.toDouble(),
      fiber: map['fiber']?.toDouble(),
      sugar: map['sugar']?.toDouble(),
      sodium: map['sodium']?.toDouble(),
      vitamins: map['vitamins'] != null ? Map<String, double>.from(map['vitamins']) : null,
      minerals: map['minerals'] != null ? Map<String, double>.from(map['minerals']) : null,
      glycemicIndex: map['glycemicIndex'],
    );
  }

  @override
  String toString() => 'Recipe(id: $id, title: $title, isPremium: $isPremium)';
}

// Recipe sources enum
class RecipeSource {
  static const String manual = 'manual';
  static const String video = 'video';
}

// Common tags
class RecipeTags {
  static const List<String> all = [
    'Quick & Easy',
    'Healthy',
    'Comfort Food',
    'Vegetarian',
    'Vegan',
    'Low Carb',
    'Budget Friendly',
    'Meal Prep',
    'One Pot',
    'Dessert',
  ];
}
