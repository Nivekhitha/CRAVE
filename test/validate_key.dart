import 'dart:convert';
import 'dart:io';

void main() async {
  print('🔑 Validating Gemini API Key Configuration...');

  String? key;
  try {
     final lines = await File('.env').readAsLines();
     for (var line in lines) {
       if (line.startsWith('GEMINI_API_KEY=')) {
         key = line.split('=')[1].trim();
         break;
       }
     }
  } catch(e) {
     print("❌ Could not load .env file: $e");
     return;
  }

  if (key == null) {
    print("❌ API Key not found in .env (Looked for GEMINI_API_KEY=...)");
    return;
  }

  print("ℹ️  Key found: ${key.substring(0, 5)}...${key.substring(key.length - 4)}");
  print("🔄 Sending logic-check to Gemini 1.5 Flash...");

  final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$key');
  
  final start = DateTime.now();
  final client = HttpClient();
  
  try {
    final request = await client.postUrl(url);
    request.headers.set('Content-Type', 'application/json');
    request.write(jsonEncode({
      "contents": [{
        "parts": [{"text": "Reply with exactly the word 'WORKING'"}]
      }]
    }));

    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    final elapsed = DateTime.now().difference(start);

    print("⏱️  Latency: ${elapsed.inMilliseconds}ms");

    if (response.statusCode == 200) {
      if (responseBody.contains("WORKING")) {
        print("\n✅ SUCCESS! The API Key is ACTIVE and working perfectly.");
        print("   The PDF Extraction will work smoothly.");
      } else {
        print("\n⚠️  API responded (200 OK) but result was unexpected.");
        print("   Response: $responseBody");
      }
    } else {
      print("\n❌ API ERROR (Status ${response.statusCode})");
      print("   Full Response: $responseBody");
      
      if (responseBody.contains("API_KEY_INVALID")) {
        print("\n👉 DIAGNOSIS: The Key string is wrong. Check for spaces or typo.");
      } else if (responseBody.contains("PERMISSION_DENIED") || responseBody.contains("Generative Language API has not been used")) {
        print("\n👉 DIAGNOSIS: Key is valid, but API is DISABLED.");
        print("   ACTION: Go to console.cloud.google.com, search 'Generative Language API' and click ENABLE.");
      } else if (responseBody.contains("not found")) {
        print("\n👉 DIAGNOSIS: Model 'gemini-1.5-flash' not accessible.");
        print("   ACTION: This key might be restricted to specific APIs.");
      }
    }
  } catch (e) {
    print("\n❌ NETWORK ERROR: $e");
  } finally {
    client.close();
  }
}
