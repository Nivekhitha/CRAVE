import 'package:hive/hive.dart';

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
  }

  // For search
  bool matchesQuery(String query) {
    final q = query.toLowerCase();
    return title.toLowerCase().contains(q) ||
        ingredients.any((i) => i.toLowerCase().contains(q)) ||
        (tags?.any((t) => t.toLowerCase().contains(q)) ?? false);
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
