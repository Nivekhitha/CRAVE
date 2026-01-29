import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/recipe.dart';

class SeedDataService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> seedRecipes() async {
    final List<Map<String, dynamic>> defaultRecipes = [
      {
        'title': 'Scrambled Eggs',
        'ingredients': ['Eggs', 'Milk', 'Butter', 'Salt', 'Pepper'],
        'instructions': '1. Whisk eggs, milk, salt and pepper.\n2. Melt butter in a pan.\n3. Pour in eggs and cook over medium heat, stirring gently until set.',
        'cookTime': 10,
        'difficulty': 'Easy',
        'calories': 320,
        'imagePath': 'assets/images/scrambled_eggs.jpg', // Placeholder
        'source': 'Crave Chef',
        'tags': ['Quick', 'Easy', 'Breakfast', 'Healthy'],
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Grilled Cheese Sandwich',
        'ingredients': ['Bread', 'Cheese', 'Butter'],
        'instructions': '1. Butter one side of each bread slice.\n2. Place one slice butter-side down in pan.\n3. Add cheese and top with second slice (butter-side up).\n4. Grill until golden brown on both sides.',
        'cookTime': 15,
        'difficulty': 'Easy',
        'calories': 450,
        'source': 'Crave Chef',
        'tags': ['Comfort Food', 'Easy', 'Quick', 'Vegetarian'],
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Pasta Aglio e Olio',
        'ingredients': ['Pasta', 'Garlic', 'Olive Oil', 'Chili Flakes', 'Parsley'],
        'instructions': '1. Boil pasta.\n2. Sauté minced garlic in generous olive oil until golden.\n3. Add chili flakes.\n4. Toss cooked pasta in the oil sauce.\n5. Garnish with parsley.',
        'cookTime': 20,
        'difficulty': 'Medium',
        'calories': 500,
        'source': 'Crave Chef',
        'tags': ['Italian', 'Vegetarian', 'Quick', 'Comfort Food'],
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Simple Salad',
        'ingredients': ['Lettuce', 'Tomato', 'Cucumber', 'Olive Oil', 'Lemon'],
        'instructions': '1. Chop all vegetables.\n2. Toss in a bowl.\n3. Drizzle with olive oil and lemon juice.\n4. Season with salt.',
        'cookTime': 10,
        'difficulty': 'Easy',
        'calories': 150,
        'source': 'Crave Chef',
        'tags': ['Healthy', 'Vegan', 'Salad', 'Quick'],
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Omelette',
        'ingredients': ['Eggs', 'Cheese', 'Onion', 'Tomato', 'Butter'],
        'instructions': '1. Whisk eggs.\n2. Sauté onions and tomatoes.\n3. Pour eggs over vegetables.\n4. Sprinkle cheese.\n5. Fold and serve.',
        'cookTime': 15,
        'difficulty': 'Medium',
        'calories': 350,
        'source': 'Crave Chef',
        'tags': ['Breakfast', 'Healthy', 'Protein', 'Quick'],
        'createdAt': FieldValue.serverTimestamp(),
      },
       {
        'title': 'Tomato Soup',
        'ingredients': ['Tomato', 'Onion', 'Garlic', 'Cream', 'Butter'],
        'instructions': '1. Roast tomatoes, onion and garlic.\n2. Blend until smooth.\n3. Simmer with butter and cream.',
        'cookTime': 30,
        'difficulty': 'Medium',
        'calories': 280,
        'source': 'Crave Chef',
        'tags': ['Soup', 'Comfort Food', 'Warm', 'Vegetarian'],
        'createdAt': FieldValue.serverTimestamp(),
      },
       {
        'title': 'Chicken Stir Fry',
        'ingredients': ['Chicken', 'Rice', 'Soy Sauce', 'Vegetables', 'Garlic'],
        'instructions': '1. Cook rice.\n2. Stir fry chicken chunks.\n3. Add veggies and sauce.\n4. Serve over rice.',
        'cookTime': 25,
        'difficulty': 'Medium',
        'calories': 550,
        'source': 'Crave Chef',
        'tags': ['Healthy', 'Dinner', 'Protein', 'Quick'],
        'createdAt': FieldValue.serverTimestamp(),
      }
    ];

    try {
      final batch = _db.batch();
      
      for (var recipe in defaultRecipes) {
        final docRef = _db.collection('recipes').doc(); // Auto-ID
        batch.set(docRef, recipe);
      }

      await batch.commit();
      debugPrint("✅ Successfully seeded ${defaultRecipes.length} recipes to Firestore.");
    } catch (e) {
      debugPrint("❌ Error seeding recipes: $e");
      throw Exception("Failed to seed recipes: $e");
    }
  }
}
