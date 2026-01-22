class Ingredient {
  final String id;
  final String name;
  final String imageUrl;
  final String category;
  final String quantity; // e.g., "2 pcs", "500g"

  Ingredient({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.category,
    required this.quantity,
  });
}
