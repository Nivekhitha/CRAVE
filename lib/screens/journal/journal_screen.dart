import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/premium_service.dart';
import '../../widgets/journal/journal_dashboard.dart';
import '../../widgets/premium/paywall_view.dart';
import '../../app/app_text_styles.dart';

class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PremiumService>(
      builder: (context, premium, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Food Journal', style: AppTextStyles.headlineMedium),
            centerTitle: true,
            automaticallyImplyLeading: false,
          ),
          body: premium.isPremium
              ? const JournalDashboard()
              : PaywallView(
                  isLoading: premium.isLoading,
                  onUnlock: () async {
                    try {
                      await premium.unlockPremium();
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(e.toString().replaceAll('Exception: ', '')),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                ),
        );
      },
    );
  }
}
