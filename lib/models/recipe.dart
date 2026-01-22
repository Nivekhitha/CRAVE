class Recipe {
  final String id;
  final String title;
  final String category;
  final String imageUrl;
  final int durationMinutes;
  final String difficulty;
  final int calories;
  final double rating;

  Recipe({
    required this.id,
    required this.title,
    required this.category,
    required this.imageUrl,
    required this.durationMinutes,
    required this.difficulty,
    required this.calories,
    required this.rating,
  });
}
