import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'lib/services/premium_service.dart';
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

  runApp(const PremiumUnlockTestApp());
}

class PremiumUnlockTestApp extends StatelessWidget {
  const PremiumUnlockTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PremiumService(),
      child: MaterialApp(
        title: 'Premium Unlock Test',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: AppColors.background,
        ),
        home: const PremiumUnlockTestScreen(),
      ),
    );
  }
}

class PremiumUnlockTestScreen extends StatefulWidget {
  const PremiumUnlockTestScreen({super.key});

  @override
  State<PremiumUnlockTestScreen> createState() => _PremiumUnlockTestScreenState();
}

class _PremiumUnlockTestScreenState extends State<PremiumUnlockTestScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize premium service
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PremiumService>(context, listen: false).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Premium Unlock Test'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<PremiumService>(
        builder: (context, premiumService, _) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Premium Service Status:',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                
                _buildStatusRow('Initialized', premiumService.isInitialized),
                _buildStatusRow('Premium', premiumService.isPremium.value),
                _buildStatusRow('Loading', premiumService.isLoading),
                _buildStatusRow('Mock Mode', premiumService.isMockMode),
                
                const SizedBox(height: 24),
                
                Text(
                  'Feature Access:',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                
                _buildStatusRow('AI Dietitian', premiumService.canUseFeature('ai_dietitian')),
                _buildStatusRow('Journal', premiumService.canUseFeature('journal')),
                _buildStatusRow('Nutrition Dashboard', premiumService.canUseFeature('nutrition_dashboard')),
                
                const SizedBox(height: 32),
                
                ElevatedButton(
                  onPressed: premiumService.isLoading ? null : () async {
                    debugPrint('🧪 Test button pressed - attempting premium unlock');
                    
                    try {
                      final result = await premiumService.purchasePremium(isYearly: false);
                      
                      if (result.isSuccess) {
                        debugPrint('🧪 Premium unlock successful!');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✅ Premium unlocked successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        debugPrint('🧪 Premium unlock failed: ${result.error}');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('❌ Failed: ${result.error}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } catch (e) {
                      debugPrint('🧪 Premium unlock exception: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('❌ Exception: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: premiumService.isLoading 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Test Premium Unlock'),
                ),
                
                const SizedBox(height: 16),
                
                ElevatedButton(
                  onPressed: () async {
                    debugPrint('🧪 Reset button pressed');
                    await premiumService.resetPremium();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('🔄 Premium status reset'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: const Text('Reset Premium Status'),
                ),
                
                const SizedBox(height: 32),
                
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TestNavigationScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: const Text('Test Navigation'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusRow(String label, bool status) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: status ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status ? 'YES' : 'NO',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TestNavigationScreen extends StatelessWidget {
  const TestNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Navigation'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<PremiumService>(
        builder: (context, premiumService, _) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  premiumService.isPremium.value ? Icons.star : Icons.star_border,
                  size: 64,
                  color: premiumService.isPremium.value ? Colors.amber : Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  premiumService.isPremium.value ? 'Premium Active!' : 'Not Premium',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Go Back'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}