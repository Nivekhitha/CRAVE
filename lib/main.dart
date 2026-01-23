import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/hive_service.dart';
import 'models/ingredient.dart';
import 'models/recipe.dart';
import 'app/app.dart';
import 'providers/user_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  final hiveService = HiveService();
  await hiveService.init();

  // TEST: Add some sample data
  await _addSampleData();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const CraveApp(),
    ),
  );
}

Future<void> _addSampleData() async {
  final hive = HiveService();

  // Add sample ingredients
  await hive.addIngredient(Ingredient(
    id: '1',
    name: 'Tomatoes',
    category: 'Produce',
    quantity: '3',
  ));

  await hive.addIngredient(Ingredient(
    id: '2',
    name: 'Chicken Breast',
    category: 'Protein',
    quantity: '500g',
  ));

  // Add sample recipe
  await hive.addRecipe(Recipe(
    id: '1',
    title: 'Chicken Tomato Pasta',
    source: 'manual',
    ingredients: ['Chicken Breast', 'Tomatoes', 'Pasta', 'Garlic'],
    prepTime: 15,
    cookTime: 20,
    isPremium: false,
  ));

  // Print statistics
  print('📊 Statistics:');
  print(hive.getStatistics());

  // Test recipe matching
  final topMatches = hive.getTopRecipeMatches(limit: 3);
  print('\n🍳 Top Recipe Matches:');
  for (final match in topMatches) {
    print('${match.key.title}: ${match.value.toStringAsFixed(1)}%');
  }
}
