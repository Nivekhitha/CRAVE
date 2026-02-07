import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'lib/services/premium_service.dart';
import 'lib/widgets/premium/paywall_view.dart';
import 'lib/app/app_colors.dart';

void main() {
  runApp(const PaywallDebugApp());
}

class PaywallDebugApp extends StatelessWidget {
  const PaywallDebugApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PremiumService(),
      child: MaterialApp(
        title: 'Paywall Debug',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: AppColors.background,
        ),
        home: const PaywallDebugScreen(),
      ),
    );
  }
}

class PaywallDebugScreen extends StatefulWidget {
  const PaywallDebugScreen({super.key});

  @override
  State<PaywallDebugScreen> createState() => _PaywallDebugScreenState();
}

class _PaywallDebugScreenState extends State<PaywallDebugScreen> {
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
        title: const Text('Paywall Debug'),
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
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: const Text('Test Paywall View'),
                ),
                
                const SizedBox(height: 16),
                
                ElevatedButton(
                  onPressed: () async {
                    await premiumService.resetPremium();
                    setState(() {});
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: const Text('Reset Premium Status'),
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