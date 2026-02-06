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
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: premium.isPremium.value
              ? const JournalDashboard()
              : const PaywallView(
                  featureId: 'journal',
                ),
        );
      },
    );
  }
}
