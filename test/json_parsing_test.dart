import 'package:crave/services/recipe_ai_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  // Load environment variables for the integration test
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print("Warning: .env not loaded. Integration tests might fail if key not found.");
  }

  final service = RecipeAiService();

  group('JSON Parsing Logic (Unit Tests)', () {
    test('Valid JSON should be parsed correctly', () {
      final json = '''
      {
        "recipes": [
          {
            "title": "Test Recipe",
            "ingredients": ["1 cup Sugar"],
            "instructions": ["Mix"],
            "prepTime": 10,
            "difficulty": "Easy"
          }
        ]
      }
      ''';
      final recipes = service.parseRecipesFromJson(json);
      expect(recipes.length, 1);
      expect(recipes.first.title, "Test Recipe");
      expect(recipes.first.ingredients.first, "1 cup Sugar");
    });

    test('Markdown wrapped JSON (```json ... ```) should be cleaned', () {
      final json = '''
      ```json
      {
        "recipes": []
      }
      ```
      ''';
      final recipes = service.parseRecipesFromJson(json);
      expect(recipes.isEmpty, true);
    });

    test('Malformed JSON should throw FormatException or Exception', () {
      final json = '{ "recipes": [ { "title": "Broken" '; // Missing closing braces
      expect(() => service.parseRecipesFromJson(json), throwsA(isA<Exception>()));
    });
    
    test('Garbage prefix/suffix should be ignored', () {
      final json = '''
      Sure here is the json:
      {
        "recipes": []
      }
      Hope that helps!
      ''';
      final recipes = service.parseRecipesFromJson(json);
      expect(recipes.isEmpty, true);
    });
  });
  
  // NOTE: This test makes a REAL Network Call to Gemini
  group('Gemini Integration Test', () {
    test('Should extract 2 recipes from Mock Text', () async {
      final mockText = """
CHOC CHIP COOKIES
Ingredients:
- 2 cups flour
- 1 cup butter
- 1 cup chocolate chips
Instructions:
1. Mix.
2. Bake.

BANANA BREAD
Ingredients:
- 3 bananas
- 1 cup flour
Instructions:
1. Mash.
2. Bake.
""";
      
      // Skip if key is missing (e.g. CI)
      if (dotenv.env['GEMINI_API_KEY'] == null) {
        print("Skipping Gemini test: No API Key");
        return;
      }

      print("Sending mock text to Gemini...");
      final recipes = await service.analyzeText(mockText);
      
      expect(recipes.length, greaterThanOrEqualTo(2));
      
      final cookie = recipes.firstWhere((r) => r.title.toLowerCase().contains("cookie"), orElse: () => recipes[0]);
      expect(cookie.ingredients.length, greaterThanOrEqualTo(3));
      
      final bread = recipes.firstWhere((r) => r.title.toLowerCase().contains("banana"), orElse: () => recipes[1]);
      expect(bread.ingredients.isEmpty, false);
      
      print("✅ Integration Test Passed: Found ${recipes.length} recipes.");
    });
  });
}
