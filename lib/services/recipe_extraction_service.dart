import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:read_pdf_text/read_pdf_text.dart';
import '../models/recipe.dart';
import '../models/ingredient.dart';

/// Client-Side Service for "Demo" Recipe Extraction.
/// Bypasses the need for a live backend or Cloud Functions billing.
class RecipeExtractionService {
  // Singleton pattern
  static final RecipeExtractionService _instance = RecipeExtractionService._internal();
  factory RecipeExtractionService() => _instance;
  RecipeExtractionService._internal();

  /// Extract recipe from URL or PDF (Simulated locally)
  /// [pdfPath] is the absolute path to the local PDF file
  Future<Recipe?> extractRecipe({String? url, String? pdfPath}) async {
    
    // PDF Extraction
    if (pdfPath != null) {
      try {
        debugPrint("📄 Parsing PDF: $pdfPath");
        String text = await ReadPdfText.getPDFtext(pdfPath);
        
        if (text.trim().isEmpty) {
          debugPrint("⚠️ PDF text was empty. It might be an image-only PDF.");
          return null;
        }

        return _parseRecipeFromText(text, pdfPath);
      } catch (e) {
        debugPrint("❌ Error reading PDF: $e");
        return null;
      }
    }

    // 1. Simulate Network Delay for realism (URL flow simulation)
    await Future.delayed(const Duration(seconds: 2));

    final inputString = (url ?? '').toLowerCase();
    
    // 2. Deterministic Logic: Return specific recipes based on keywords for DEMO URLS
    if (inputString.contains('pasta') || inputString.contains('spaghetti') || inputString.contains('italian')) {
      return _getRecipeData(_pastaRecipe, url);
    }
    
    if (inputString.contains('chicken') || inputString.contains('curry') || inputString.contains('roast')) {
      return _getRecipeData(_chickenRecipe, url);
    }

    if (inputString.contains('salad') || inputString.contains('healthy') || inputString.contains('vegan')) {
      return _getRecipeData(_saladRecipe, url);
    }

    if (inputString.contains('cake') || inputString.contains('dessert') || inputString.contains('sweet')) {
      return _getRecipeData(_cakeRecipe, url);
    }

    // Default Fallback
    return _getRecipeData(_defaultRecipe, url);
  }

  Recipe _parseRecipeFromText(String text, String sourcePath) {
    debugPrint("🧠 Heuristic Analysis of PDF Text...");
    
    // Heuristic 1: Title
    // Assume the first non-empty line effectively, or check for specific formatting eventually
    // For now, we take the first line that looks like a title (not a page number)
    List<String> lines = text.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
    
    String title = "Extracted Recipe";
    if (lines.isNotEmpty) {
      // Simple heuristic: First realistic line is the title
      title = lines.firstWhere((l) => l.length > 3 && !l.contains('Page'), orElse: () => "Unknown Recipe");
    }

    // Heuristic 2: Sections
    List<String> ingredientsRaw = [];
    List<String> instructionsRaw = [];
    
    String? currentSection; // 'ingredients' or 'instructions'

    for (var line in lines) {
      String lower = line.toLowerCase();
      
      // Section Headers
      if (lower.contains('ingredients') || lower.contains('what you need') || lower.contains('shopping list')) {
        currentSection = 'ingredients';
        continue;
      }
      
      if (lower.contains('instructions') || lower.contains('method') || lower.contains('preparation') || lower.contains('directions') || lower.contains('how to make')) {
        currentSection = 'instructions';
        continue;
      }

      // Add Content to Sections
      if (currentSection == 'ingredients') {
        // Filter out junk
        if (line.length < 3) continue;
        ingredientsRaw.add(line);
      } else if (currentSection == 'instructions') {
        // Filter out junk
        if (line.length < 5) continue;
        instructionsRaw.add(line);
      }
    }

    // Convert to Models
    List<Ingredient> ingredients = ingredientsRaw.map((raw) {
      return Ingredient(
        id: DateTime.now().millisecondsSinceEpoch.toString() + raw.hashCode.toString(),
        name: raw, // For now, we dump the whole line as name. Smart parsing of "200g cups" is complex without NLP.
        quantity: '1', 
        unit: '', 
        category: 'Pantry', // Default
      );
    }).toList();

    String instructions = instructionsRaw.join('\n\n');

    return Recipe(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: "Extracted from your cookbook on ${DateTime.now().toString().split(' ')[0]}",
      source: 'cookbook',
      sourceUrl: sourcePath, // Using local path as "URL"
      ingredients: ingredients.map((i) => i.name).toList(), // Saving logical string list
      instructions: instructions,
      isPremium: true,
      imageUrl: 'assets/images/placeholder_food.png',
      cookCount: 0,
      tags: ['Cookbook', 'Extracted'],
      prepTime: 15, // Default
      cookTime: 20, // Default
      difficulty: 'Medium', // Default
    );
  }

  /// Helper to convert Map data to Recipe model (Legacy Mock)
  Recipe _getRecipeData(Map<String, dynamic> data, String? source) {
    List<Ingredient> ingredients = [];
    if (data['ingredients'] != null) {
      for (var item in data['ingredients']) {
        ingredients.add(Ingredient(
          id: DateTime.now().millisecondsSinceEpoch.toString() + item['name'],
          name: item['name'],
          quantity: '1', // FIXED: Must be a String, not int
          unit: item['amount'] ?? '', 
          category: item['category'] ?? 'Uncategorized',
        ));
      }
    }

    // FIXED: Instructions must be a single String (joined by newlines), not a List
    String instructionsText = '';
    if (data['instructions'] != null && data['instructions'] is List) {
      instructionsText = (data['instructions'] as List).join('\n\n');
    }

    // Determine source type
    String sourceType = 'manual';
    if (source != null && (source.contains('http') || source.contains('www'))) {
      sourceType = 'video';
    }

    return Recipe(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: data['title'] ?? 'Untitled Recipe',
      description: data['description'] ?? '',
      source: sourceType,
      sourceUrl: source,
      ingredients: ingredients.map((i) => i.name).toList(), 
      instructions: instructionsText, // FIXED: Passing String, not List
      isPremium: true,
      imageUrl: 'assets/images/placeholder_food.png',
      cookCount: 0,
      tags: ['Extracted', 'Demo'],
    );
  }

  // ==========================================
  // LOCAL MOCK DATA LIBRARY (Matches Backend)
  // ==========================================

  final Map<String, dynamic> _pastaRecipe = {
    "title": "Creamy Tomato & Basil Pasta",
    "description": "A rich, velvety tomato sauce clinging to perfectly cooked pasta, finished with fresh fragrant basil.",
    "ingredients": [
      {"name": "Penne Pasta", "amount": "500g", "category": "Pantry"},
      {"name": "Tomato Puree", "amount": "400g", "category": "Pantry"},
      {"name": "Heavy Cream", "amount": "200ml", "category": "Dairy"},
      {"name": "Garlic", "amount": "3 cloves", "category": "Produce"},
      {"name": "Fresh Basil", "amount": "1 bunch", "category": "Produce"},
      {"name": "Parmesan Cheese", "amount": "50g", "category": "Dairy"}
    ],
    "instructions": [
      "Bring a large pot of salted water to a boil and cook pasta until al dente.",
      "In a saucepan, sauté minced garlic in olive oil until fragrant.",
      "Add tomato puree and simmer for 10 minutes on low heat.",
      "Stir in the heavy cream and half the parmesan. Season with salt and pepper.",
      "Toss the cooked pasta with the sauce.",
      "Serve hot, garnished with fresh basil leaves and remaining parmesan."
    ]
  };

  final Map<String, dynamic> _chickenRecipe = {
    "title": "Classic Butter Chicken",
    "description": "Tender chicken pieces simmered in a creamy, spiced tomato curry sauce. A crowd favorite.",
    "ingredients": [
      {"name": "Chicken Breast", "amount": "500g", "category": "Meat"},
      {"name": "Butter", "amount": "50g", "category": "Dairy"},
      {"name": "Tomato Paste", "amount": "2 tbsp", "category": "Pantry"},
      {"name": "Garam Masala", "amount": "2 tsp", "category": "Pantry"},
      {"name": "Heavy Cream", "amount": "1 cup", "category": "Dairy"},
      {"name": "Ginger Garlic Paste", "amount": "1 tbsp", "category": "Pantry"}
    ],
    "instructions": [
      "Marinate chicken cubes with ginger garlic paste and salt for 30 mins.",
      "Pan-fry the chicken in butter until golden brown.",
      "Add tomato paste, garam masala, and cream. Simmer for 15 minutes.",
      "Finish with a knob of butter and serve with naan or rice."
    ]
  };

  final Map<String, dynamic> _saladRecipe = {
    "title": "Mediterranean Quinoa Salad",
    "description": "A refreshing, nutrient-packed salad with quinoa, crisp vegetables, and a zesty lemon dressing.",
    "ingredients": [
      {"name": "Quinoa", "amount": "1 cup", "category": "Pantry"},
      {"name": "Cucumber", "amount": "1 medium", "category": "Produce"},
      {"name": "Cherry Tomatoes", "amount": "1 cup", "category": "Produce"},
      {"name": "Feta Cheese", "amount": "100g", "category": "Dairy"},
      {"name": "Olives", "amount": "1/2 cup", "category": "Pantry"},
      {"name": "Lemon Juice", "amount": "2 tbsp", "category": "Pantry"}
    ],
    "instructions": [
      "Rinse quinoa and cook in water according to package instructions. Let cool.",
      "Dice cucumber and halve the cherry tomatoes.",
      "In a large bowl, combine quinoa, veggies, olives, and crumbled feta.",
      "Drizzle with olive oil and lemon juice. Toss gently to combine."
    ]
  };

  final Map<String, dynamic> _cakeRecipe = {
    "title": "Molten Chocolate Lava Cake",
    "description": "Decadent individual chocolate cakes with a gooey, flowing center.",
    "ingredients": [
      {"name": "Dark Chocolate", "amount": "100g", "category": "Pantry"},
      {"name": "Butter", "amount": "100g", "category": "Dairy"},
      {"name": "Eggs", "amount": "2", "category": "Dairy"},
      {"name": "Sugar", "amount": "1/2 cup", "category": "Pantry"},
      {"name": "Flour", "amount": "2 tbsp", "category": "Pantry"}
    ],
    "instructions": [
      "Preheat oven to 200°C (400°F). Grease ramekins.",
      "Melt chocolate and butter together.",
      "Whisk eggs and sugar until pale, then fold into the chocolate mix.",
      "Sift in flour and fold gently.",
      "Pour into ramekins and bake for 12-14 minutes. Center should still be wobbly."
    ]
  };

  final Map<String, dynamic> _defaultRecipe = {
    "title": "Chef's Special: Grilled Salmon",
    "description": "Perfectly grilled salmon fillet with a lemon butter glaze and roasted asparagus.",
    "ingredients": [
      {"name": "Salmon Fillet", "amount": "2 pieces", "category": "Meat"},
      {"name": "Asparagus", "amount": "1 bunch", "category": "Produce"},
      {"name": "Butter", "amount": "3 tbsp", "category": "Dairy"},
      {"name": "Lemon", "amount": "1", "category": "Produce"},
      {"name": "Garlic Powder", "amount": "1 tsp", "category": "Pantry"}
    ],
    "instructions": [
      "Season salmon with salt, pepper, and garlic powder.",
      "Grill salmon for 4-5 minutes per side.",
      "In a small pan, melt butter with lemon juice.",
      "Roast asparagus in the oven with olive oil for 10 minutes.",
      "Pour lemon butter over salmon and serve with asparagus."
    ]
  };
}
