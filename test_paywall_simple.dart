import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'lib/services/premium_service.dart';
import 'lib/widgets/premium/paywall_view.dart';
import 'lib/app/app_colors.dart';
import 'firebase_options.dart';

void main() async {
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

  // Initialize Hive
  await Hive.initFlutter();
  debugPrint("✅ Hive initialized");

  runApp(const PaywallTestApp());
}

class PaywallTestApp extends StatelessWidget {
  const PaywallTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final premiumService = PremiumService();
        // Initialize asynchronously
        premiumService.init().catchError((e) {
          debugPrint('❌ PremiumService init error: $e');
        });
        return premiumService;
      },
      child: MaterialApp(
        title: 'Paywall Test',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: AppColors.background,
        ),
        home: const PaywallTestScreen(),
        routes: {
          '/main': (context) => const MainTestScreen(),
        },
      ),
    );
  }
}

class PaywallTestScreen extends StatelessWidget {
  const PaywallTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paywall Test'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<PremiumService>(
        builder: (context, premiumService, _) {
          if (!premiumService.isInitialized) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Initializing Premium Service...'),
                ],
              ),
            );
          }

          if (premiumService.isPremium.value) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star, size: 64, color: Colors.amber),
                  SizedBox(height: 16),
                  Text(
                    'Premium Active!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }

          return const PaywallView(
            featureId: 'test',
            title: 'Test Premium Feature',
            description: 'This is a test of the paywall functionality.',
          );
        },
      ),
    );
  }
}

class MainTestScreen extends StatelessWidget {
  const MainTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Screen'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home, size: 64, color: Colors.blue),
            SizedBox(height: 16),
            Text(
              'Welcome to Main Screen!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text('Navigation from paywall worked successfully!'),
          ],
        ),
      ),
    );
  }
}