import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

Future<void> main() async {
  await dotenv.load();
  
  final apiKey = dotenv.env['GEMINI_API_KEY'];
  print('🔑 Testing API Key: ${apiKey?.substring(0, 10)}...');
  
  if (apiKey == null || apiKey.isEmpty) {
    print('❌ No API key found');
    return;
  }

  // Test different models to see which ones work
  final modelsToTest = [
    'gemini-pro',
    'gemini-1.5-pro',
    'gemini-1.0-pro',
    'gemini-1.5-flash',
    'gemini-1.5-pro-latest',
  ];

  for (final modelName in modelsToTest) {
    try {
      print('\n🧪 Testing: $modelName');
      
      final model = GenerativeModel(
        model: modelName,
        apiKey: apiKey,
      );

      final response = await model.generateContent([
        Content.text('Say "Hello" in JSON format: {"message": "Hello"}')
      ]);
      
      if (response.text != null && response.text!.isNotEmpty) {
        print('✅ $modelName WORKS!');
        print('   Response: ${response.text!.substring(0, response.text!.length > 50 ? 50 : response.text!.length)}...');
      } else {
        print('⚠️ $modelName returned empty response');
      }
      
    } catch (e) {
      print('❌ $modelName FAILED: $e');
    }
  }
}