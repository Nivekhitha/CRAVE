import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Added
import 'package:hive_flutter/hive_flutter.dart'; // Added
import 'services/hive_service.dart';
import 'services/premium_service.dart';
import 'app/app.dart';
import 'providers/user_provider.dart';
import 'firebase_options.dart'; // Ensure this file exists, assuming it was generated

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

  // Load environment variables
  await dotenv.load();

  // Initialize Hive
  await Hive.initFlutter(); // Changed to use Hive.initFlutter directly
  // The original HiveService might still be used for opening specific boxes,
  // but the global initialization is now done with Hive.initFlutter().
  // If HiveService.init() contained more logic than just Hive.initFlutter(),
  // that logic would need to be re-evaluated or moved.
  // For now, assuming Hive.initFlutter() replaces the need for HiveService.init()
  // for the global initialization step.
  
  if (kIsWeb) {
    debugPrint("⚠️ WARNING: RevenueCat is NOT supported on Web. Please run on Android for full features.");
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
