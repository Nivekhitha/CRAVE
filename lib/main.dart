import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'services/hive_service.dart';
import 'services/premium_service.dart';
import 'services/journal_service.dart';
import 'services/meal_plan_service.dart';
import 'services/nutrition_service.dart';
import 'app/app.dart';
import 'providers/user_provider.dart';
import 'firebase_options.dart';

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
  }

  // Load environment variables
  try {
    await dotenv.load();
    debugPrint("✅ Environment variables loaded");
  } catch (e) {
    debugPrint("⚠️ Environment variables not found: $e");
  }

  // Initialize Hive
  await Hive.initFlutter();
  debugPrint("✅ Hive initialized");
  
  // Initialize HiveService for existing functionality
  try {
    await HiveService().init();
    debugPrint("✅ HiveService initialized");
  } catch (e) {
    debugPrint("⚠️ HiveService init error: $e");
  }
  
  if (kIsWeb) {
    debugPrint("⚠️ WARNING: RevenueCat is NOT supported on Web. Please run on Android for full features.");
  }

  runApp(
    MultiProvider(
      providers: [
        // Core providers
        ChangeNotifierProvider(create: (_) => UserProvider()),
        
        // Premium system
        ChangeNotifierProvider(create: (_) => PremiumService()),
        
        // Data services
        ChangeNotifierProvider(create: (_) => JournalService()),
        ChangeNotifierProvider(create: (_) => MealPlanService()),
        
        // Nutrition service depends on journal and meal plan services
        ChangeNotifierProxyProvider2<JournalService, MealPlanService, NutritionService>(
          create: (context) => NutritionService(
            Provider.of<JournalService>(context, listen: false),
            Provider.of<MealPlanService>(context, listen: false),
          ),
          update: (context, journalService, mealPlanService, previous) =>
              previous ?? NutritionService(journalService, mealPlanService),
        ),
      ],
      child: const CraveApp(),
    ),
  );
}
