/// Ingredient categories for weighted matching logic.
/// Allows us to prioritize main ingredients over garnishes.
enum IngredientCategory {
  protein,
  vegetable,
  fruit,
  grain, // carbs
  dairy,
  pantry, // oil, spices, sauces
  liquid, // stocks, water
  other,
}

/// Maps common ingredients to their category.
const Map<String, IngredientCategory> ingredientCategories = {
  // Proteins
  'chicken': IngredientCategory.protein,
  'chicken breast': IngredientCategory.protein,
  'chicken thigh': IngredientCategory.protein,
  'beef': IngredientCategory.protein,
  'ground beef': IngredientCategory.protein,
  'steak': IngredientCategory.protein,
  'pork': IngredientCategory.protein,
  'bacon': IngredientCategory.protein,
  'sausage': IngredientCategory.protein,
  'fish': IngredientCategory.protein,
  'salmon': IngredientCategory.protein,
  'tuna': IngredientCategory.protein,
  'shrimp': IngredientCategory.protein,
  'egg': IngredientCategory.protein,
  'eggs': IngredientCategory.protein,
  'tofu': IngredientCategory.protein,
  'tempeh': IngredientCategory.protein,
  'beans': IngredientCategory.protein,
  'lentils': IngredientCategory.protein,
  'chickpeas': IngredientCategory.protein,

  // Grains / Carbs
  'rice': IngredientCategory.grain,
  'pasta': IngredientCategory.grain,
  'spaghetti': IngredientCategory.grain,
  'macaroni': IngredientCategory.grain,
  'bread': IngredientCategory.grain,
  'flour': IngredientCategory.grain,
  'oats': IngredientCategory.grain,
  'quinoa': IngredientCategory.grain,
  'potato': IngredientCategory.vegetable, // debating grain vs veg, usually main component
  'potatoes': IngredientCategory.vegetable,
  'sweet potato': IngredientCategory.vegetable,
  'noodles': IngredientCategory.grain,
  'wrapper': IngredientCategory.grain,
  'tortilla': IngredientCategory.grain,

  // Vegetables
  'onion': IngredientCategory.vegetable,
  'garlic': IngredientCategory.vegetable,
  'carrot': IngredientCategory.vegetable,
  'celery': IngredientCategory.vegetable,
  'tomato': IngredientCategory.vegetable,
  'pepper': IngredientCategory.vegetable,
  'bell pepper': IngredientCategory.vegetable,
  'broccoli': IngredientCategory.vegetable,
  'cauliflower': IngredientCategory.vegetable,
  'spinach': IngredientCategory.vegetable,
  'lettuce': IngredientCategory.vegetable,
  'cucumber': IngredientCategory.vegetable,
  'zucchini': IngredientCategory.vegetable,
  'mushroom': IngredientCategory.vegetable,
  'peas': IngredientCategory.vegetable,
  'corn': IngredientCategory.vegetable,
  'ginger': IngredientCategory.vegetable,
  'scallion': IngredientCategory.vegetable,
  'green onion': IngredientCategory.vegetable,

  // Fruits
  'apple': IngredientCategory.fruit,
  'banana': IngredientCategory.fruit,
  'orange': IngredientCategory.fruit,
  'lemon': IngredientCategory.fruit,
  'lime': IngredientCategory.fruit,
  'berry': IngredientCategory.fruit,
  'strawberry': IngredientCategory.fruit,
  'blueberry': IngredientCategory.fruit,
  'avocado': IngredientCategory.fruit,

  // Dairy
  'milk': IngredientCategory.dairy,
  'cream': IngredientCategory.dairy,
  'butter': IngredientCategory.dairy,
  'cheese': IngredientCategory.dairy,
  'yogurt': IngredientCategory.dairy,
  'sour cream': IngredientCategory.dairy,
  'parmesan': IngredientCategory.dairy,
  'mozzarella': IngredientCategory.dairy,
  'cheddar': IngredientCategory.dairy,

  // Pantry / Spices / Sauces
  'salt': IngredientCategory.pantry,
  'pepper': IngredientCategory.pantry,
  'oil': IngredientCategory.pantry,
  'olive oil': IngredientCategory.pantry,
  'vegetable oil': IngredientCategory.pantry,
  'sugar': IngredientCategory.pantry,
  'flour': IngredientCategory.pantry, // can be both but usually staple
  'baking powder': IngredientCategory.pantry,
  'baking soda': IngredientCategory.pantry,
  'soy sauce': IngredientCategory.pantry,
  'vinegar': IngredientCategory.pantry,
  'honey': IngredientCategory.pantry,
  'mustard': IngredientCategory.pantry,
  'ketchup': IngredientCategory.pantry,
  'mayonnaise': IngredientCategory.pantry,
  'stock': IngredientCategory.liquid,
  'broth': IngredientCategory.liquid,
  'water': IngredientCategory.liquid,
  'wine': IngredientCategory.liquid,
  'vanilla': IngredientCategory.pantry,
  'cinnamon': IngredientCategory.pantry,
  'cumin': IngredientCategory.pantry,
  'paprika': IngredientCategory.pantry,
  'chili powder': IngredientCategory.pantry,
  'oregano': IngredientCategory.pantry,
  'basil': IngredientCategory.pantry,
  
};
