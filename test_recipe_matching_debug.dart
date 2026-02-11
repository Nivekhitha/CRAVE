import 'package:flutter/material.dart';
import 'lib/services/recipe_matching_service.dart';
import 'lib/models/recipe.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe Matching Test',
      home: const RecipeMatchingTest(),
    );
  }
}

class RecipeMatchingTest extends StatefulWidget {
  const RecipeMatchingTest({super.key});

  @override
  State<RecipeMatchingTest> createState() => _RecipeMatchingTestState();
}

class _RecipeMatchingTestState extends State<RecipeMatchingTest> {
  final RecipeMatchingService _matcher = RecipeMatchingService();
  List<RecipeMatch> _matches = [];

  @override
  void initState() {
    super.initState();
    _runTest();
  }

  void _runTest() {
    // Create test recipes
    final testRecipes = [
      Recipe(
        id: '1',
        title: 'Scrambled Eggs',
        source: 'manual',
        ingredients: ['Eggs', 'Milk', 'Butter', 'Salt'],
        isPremium: false,
        createdAt: DateTime.now(),
        cookCount: 0,
      ),
      Recipe(
        id: '2',
        title: 'Cheese Toast',
        source: 'manual',
        ingredients: ['Bread', 'Cheese', 'Butter'],
        isPremium: false,
        createdAt: DateTime.now(),
        cookCount: 0,
      ),
      Recipe(
        id: '3',
        title: 'Pasta Carbonara',
        source: 'manual',
        ingredients: ['Pasta', 'Eggs', 'Cheese', 'Bacon'],
        isPremium: false,
        createdAt: DateTime.now(),
        cookCount: 0,
      ),
    ];

    // Create test pantry
    final testPantry = [
      {'name': 'Eggs', 'category': 'Protein'},
      {'name': 'Milk', 'category': 'Dairy'},
      {'name': 'Cheese', 'category': 'Dairy'},
      {'name': 'Bread', 'category': 'Grains'},
    ];

    // Run matching
    final matches = _matcher.getMatches(testRecipes, testPantry);
    
    setState(() {
      _matches = matches;
    });

    // Print results
    print('🧪 RECIPE MATCHING TEST RESULTS:');
    print('Pantry items: ${testPantry.map((e) => e['name']).join(', ')}');
    print('Found ${matches.length} matches:');
    
    for (final match in matches) {
      print('  - ${match.recipe.title}: ${match.matchPercentage.round()}% match');
      print('    ✅ Has: ${match.matchingIngredientCount}/${match.recipe.ingredients.length} ingredients');
      if (match.missingIngredients.isNotEmpty) {
        print('    ❌ Missing: ${match.missingIngredients.join(', ')}');
      }
      print('');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Matching Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Test Pantry Items:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text('Eggs, Milk, Cheese, Bread'),
            const SizedBox(height: 20),
            const Text(
              'Recipe Matches:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _matches.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _matches.length,
                      itemBuilder: (context, index) {
                        final match = _matches[index];
                        return Card(
                          child: ListTile(
                            title: Text(match.recipe.title),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${match.matchPercentage.round()}% match'),
                                Text('Has: ${match.matchingIngredientCount}/${match.recipe.ingredients.length} ingredients'),
                                if (match.missingIngredients.isNotEmpty)
                                  Text('Missing: ${match.missingIngredients.join(', ')}'),
                              ],
                            ),
                            leading: CircleAvatar(
                              backgroundColor: _getMatchColor(match.matchPercentage),
                              child: Text(
                                '${match.matchPercentage.round()}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            ElevatedButton(
              onPressed: _runTest,
              child: const Text('Run Test Again'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getMatchColor(double percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
  }
}