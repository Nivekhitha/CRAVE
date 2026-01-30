import 'dart:convert';
import 'dart:io';

void main() async {
  print('🔍 Checking available models for your API Key...');

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
     print("❌ Could not load .env file");
     return;
  }

  if (key == null) {
    print("❌ No API Key found");
    return;
  }

  final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models?key=$key');
  final client = HttpClient();
  
  try {
    final request = await client.getUrl(url);
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    print("Status: ${response.statusCode}");
    if (response.statusCode == 200) {
      print("✅ Success! API Key is working. Available models:");
      final data = jsonDecode(responseBody);
      final models = data['models'] as List;
      for (var m in models) {
        print(" - ${m['name']}");
      }
    } else {
      print("❌ Failed. Response:");
      print(responseBody);
    }
  } catch (e) {
    print("❌ Network Error: $e");
  } finally {
    client.close();
  }
}
