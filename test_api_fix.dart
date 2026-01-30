import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

Future<void> main() async {
  // Load environment variables
  await dotenv.load();
  
  final apiKey = dotenv.env['GEMINI_API_KEY'];
  print('🔑 API Key: ${apiKey != null && apiKey.isNotEmpty ? '${apiKey.substring(0, 5)}...${apiKey.substring(apiKey.length - 4)}' : 'NULL'}');
  
  if (apiKey == null || apiKey.isEmpty) {
    print('❌ No API key found in .env file');
    return;
  }

  // Test available models
  final models = ['gemini-1.5-pro', 'gemini-pro', 'gemini-1.0-pro'];
  
  for (final modelName in models) {
    try {
      print('\n🤖 Testing model: $modelName');
      
      final model = GenerativeModel(
        model: modelName,
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          temperature: 0.3,
        ),
      );

      final prompt = '''
Extract recipes from this text and return JSON:

"Chocolate Chip Cookies
Ingredients: 2 cups flour, 1 cup sugar, 1/2 cup butter
Instructions: Mix ingredients, bake at 350°F for 12 minutes"

Return format: {"recipes": [{"title": "...", "ingredients": [...], "instructions": [...]}]}
''';

      final response = await model.generateContent([Content.text(prompt)]);
      
      if (response.text != null && response.text!.isNotEmpty) {
        print('✅ $modelName works! Response length: ${response.text!.length}');
        print('📄 Sample response: ${response.text!.substring(0, response.text!.length > 100 ? 100 : response.text!.length)}...');
        break; // Found working model
      } else {
        print('⚠️ $modelName returned empty response');
      }
      
    } catch (e) {
      print('❌ $modelName failed: $e');
    }
  }
  
  print('\n✅ API test complete!');
}