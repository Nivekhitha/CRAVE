import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class DietitianMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  DietitianMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class DietitianService extends ChangeNotifier {
  static final DietitianService _instance = DietitianService._internal();
  factory DietitianService() => _instance;
  DietitianService._internal();

  GenerativeModel? _model;
  ChatSession? _chatSession;
  final List<DietitianMessage> _messages = [];
  bool _isLoading = false;

  List<DietitianMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;

  Future<void> init() async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null) {
      debugPrint('❌ GEMINI_API_KEY not found');
      return;
    }

    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        maxOutputTokens: 500, // Keep responses concise
      ),
      systemInstruction: Content.text('''
You are a professional, empathetic AI Dietitian assistant for the CRAVE app.
Your Goal: Help users with nutrition, meal planning, hydration, and healthy eating habits.

STRICT SCOPE:
- You ONLY answer questions about food, nutrition, diets (Keto, Vegan, etc.), hydration, and finding recipes in the app.
- If a user asks about anything else (politics, code, general knowledge, medical advice, stocks), you MUST politely refuse.
  Example refusal: "I specialize only in nutrition and food. I can't help with that, but I can suggest a healthy lunch!"
- DO NOT provide medical diagnoses. Always advise consulting a doctor for medical issues.

Tone: Encouraging, concise, professional but friendly.
Format: Use simple text, bullet points for lists. No markdown headers if possible, just natural conversation.
      '''),
    );
    
    _startChat();
  }

  void _startChat() {
    if (_model == null) return;
    _chatSession = _model!.startChat(history: []);
    _messages.clear();
    // Add initial greeting
    _messages.add(DietitianMessage(
      text: "Hi! I'm your personal nutrition assistant. Ask me about meal plans, macro goals, or healthy recipes!",
      isUser: false,
    ));
    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    if (_model == null) await init();
    if (_chatSession == null) return;

    final userMsg = DietitianMessage(text: text, isUser: true);
    _messages.add(userMsg);
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _chatSession!.sendMessage(Content.text(text));
      final responseText = response.text ?? "I'm having trouble thinking right now. Please try again.";
      
      _messages.add(DietitianMessage(text: responseText, isUser: false));
    } catch (e) {
      debugPrint("❌ Dietitian Error: $e");
      _messages.add(DietitianMessage(
        text: "Sorry, I'm having trouble connecting to my nutrition database. Please check your internet.",
        isUser: false,
      ));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearChat() {
    _startChat();
  }
}
