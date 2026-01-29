// Simple test to verify recipe matching logic
import 'lib/services/recipe_matching_service.dart';
import 'lib/models/recipe.dart';

void main() {
  final matcher = RecipeMatchingService();
  
  // Sample recipes
  final recipes = [
    Recipe(
      id: 'pasta',
      title: 'Pesto Pasta',
      ingredients: ['Pasta', 'Pesto', 'Cream'],
      source: 'test',
    ),
    Recipe(
      id: 'eggs',
      title: 'Scrambled Eggs',
      ingredients: ['Eggs', 'Butter', 'Milk'],
      source: 'test',
    ),
    Recipe(
      id: 'sandwich',
      title: 'Grilled Cheese',
      ingredients: ['Bread', 'Cheese', 'Butter'],
      source: 'test',
    ),
  ];
  
  // Sample pantry
  final pantry = [
    {'name': 'Penne Pasta', 'category': 'Grains'},
    {'name': 'Heavy Cream', 'category': 'Dairy'},
    {'name': 'Eggs', 'category': 'Proteins'},
    {'name': 'Butter', 'category': 'Dairy'},
  ];
  
  print('🧪 Testing Recipe Matching System');
  print('Pantry items: ${pantry.map((p) => p['name']).join(', ')}');
  print('');
  
  final matches = matcher.getMatches(recipes, pantry);
  
  for (var match in matches) {
    print('📝 ${match.recipe.title}');
    print('   Match: ${match.matchPercentage.toStringAsFixed(1)}%');
    print('   Found: ${match.matchingIngredientCount}/${match.recipe.ingredients.length} ingredients');
    print('   Missing: ${match.missingIngredients.join(', ')}');
    print('');
  }
}