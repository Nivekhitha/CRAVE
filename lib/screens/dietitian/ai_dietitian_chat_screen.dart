import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';
import '../../widgets/premium/premium_gate.dart';

class AIDietitianChatScreen extends StatefulWidget {
  const AIDietitianChatScreen({super.key});

  @override
  State<AIDietitianChatScreen> createState() => _AIDietitianChatScreenState();
}

class _AIDietitianChatScreenState extends State<AIDietitianChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Message> _messages = [
     Message(text: "Hello! I'm your personal AI Dietitian. How can I help you reach your goals today?", isUser: false),
     Message(text: "I can suggest recipes based on your pantry or help you plan your weekly meals.", isUser: false),
  ];

  @override
  Widget build(BuildContext context) {
    return PremiumGate(
      featureId: 'ai_dietitian',
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
           backgroundColor: Colors.white,
           elevation: 0,
           title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                 Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(color: AppColors.freshMint, shape: BoxShape.circle),
                    child: const Icon(LucideIcons.leaf, color: Colors.white, size: 16),
                 ),
                 const SizedBox(width: 8),
                 Text("Crave Dietitian", style: AppTextStyles.headlineMedium)
              ],
           ),
           leading: IconButton(
             icon: const Icon(Icons.arrow_back_ios, color: AppColors.charcoal, size: 20),
             onPressed: () => Navigator.pop(context),
           ),
        ),
        body: Column(
           children: [
              Expanded(
                 child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                       final msg = _messages[index];
                       return Align(
                          alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                             margin: const EdgeInsets.only(bottom: 12),
                             padding: const EdgeInsets.all(16),
                             constraints: const BoxConstraints(maxWidth: 280),
                             decoration: BoxDecoration(
                                color: msg.isUser ? AppColors.primary : Colors.white,
                                borderRadius: BorderRadius.only(
                                   topLeft: const Radius.circular(20),
                                   topRight: const Radius.circular(20),
                                   bottomLeft: Radius.circular(msg.isUser ? 20 : 0),
                                   bottomRight: Radius.circular(msg.isUser ? 0 : 20)
                                ),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))]
                             ),
                             child: Text(
                                msg.text, 
                                style: TextStyle(color: msg.isUser ? Colors.white : AppColors.charcoal)
                             ),
                          ),
                       );
                    },
                 ),
              ),
              Container(
                 padding: const EdgeInsets.all(16),
                 decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]
                 ),
                 child: SafeArea(
                    child: Row(
                       children: [
                          Expanded(
                             child: TextField(
                                controller: _controller,
                                decoration: InputDecoration(
                                   hintText: "Ask about nutrition...",
                                   hintStyle: TextStyle(color: AppColors.slate.withOpacity(0.7)),
                                   filled: true,
                                   fillColor: AppColors.wash,
                                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                                   contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)
                                ),
                             ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                             onTap: () {
                                if (_controller.text.isNotEmpty) {
                                   setState(() {
                                      _messages.add(Message(text: _controller.text, isUser: true));
                                      _controller.clear();
                                      // Simulate reply
                                      Future.delayed(const Duration(seconds: 1), () {
                                         setState(() => _messages.add(Message(text: "That sounds delicious! Since you're tracking protein, maybe add some Greek yogurt?", isUser: false)));
                                      });
                                   });
                                }
                             },
                             child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: const BoxDecoration(
                                   gradient: AppColors.magicHour,
                                   shape: BoxShape.circle
                                ),
                                child: const Icon(LucideIcons.send, color: Colors.white, size: 20),
                             ),
                          )
                       ],
                    ),
                 ),
              )
           ],
        ),
      ),
    );
  }
}

class Message {
   final String text;
   final bool isUser;
   Message({required this.text, required this.isUser});
}
