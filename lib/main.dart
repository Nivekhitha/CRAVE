import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/hive_service.dart';
import 'services/premium_service.dart';
import 'app/app.dart';
import 'providers/user_provider.dart';
import 'firebase_options.dart'; // Ensure this file exists, assuming it was generated

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  final hiveService = HiveService();
  await hiveService.init();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint("✅ Firebase initialized successfully");
  } catch (e) {
    debugPrint("⚠️ Firebase Init Error: $e");
    // Fallback or retry logic if needed, but for now just log
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => PremiumService()),
      ],
      child: const CraveApp(),
    ),
  );
}
