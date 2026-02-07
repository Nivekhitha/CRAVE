import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'lib/services/premium_service.dart';
import 'lib/widgets/premium/paywall_view.dart';
import 'lib/widgets/premium/premium_gate.dart';
import 'lib/app/app_colors.dart';

void main() {
  runApp(const PaywallFixApp());
}

class PaywallFixApp extends StatelessWidget {
  const PaywallFixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PremiumService(),
      child: MaterialApp(
        title: 'Paywall Fix Test',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: AppColors.background,
        ),
        home: const PaywallFixScreen(),
      ),
    );
  }
}

class PaywallFixScreen extends StatefulWidget {
  const PaywallFixScreen({super.key});

  @override
  State<PaywallFixScreen> createState() => _PaywallFixScreenState();
}

class _PaywallFixScreenState extends State<PaywallFixScreen> {
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
        title: const Text('Paywall Fix Test'),
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
                _buildStatusRow('Mock Mode', premiumService.isMockMode),
                
                const SizedBox(height: 32),
                
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AIDietitianGate(
                          child: MockAIDietitianScreen(),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: const Text('Test AI Dietitian Gate'),
                ),
                
                const SizedBox(height: 16),
                
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PaywallView(
                          featureId: 'ai_dietitian',
                          title: 'Personal AI Dietitian',
                          description: 'Get personalized nutrition advice and meal recommendations',
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: const Text('Test Direct Paywall'),
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

class MockAIDietitianScreen extends StatelessWidget {
  const MockAIDietitianScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Dietitian'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.psychology,
              size: 64,
              color: Colors.green,
            ),
            SizedBox(height: 16),
            Text(
              'AI Dietitian Unlocked!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'This screen should only show if premium is unlocked',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}