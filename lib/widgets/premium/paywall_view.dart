import 'package:flutter/material.dart';
import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';

class PaywallView extends StatelessWidget {
  final VoidCallback onUnlock;
  final bool isLoading;

  const PaywallView({
    super.key,
    required this.onUnlock,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Blurred Content (Mock background)
        Positioned.fill(
          child: Opacity(
            opacity: 0.3,
            child: Container(
              color: AppColors.background,
              child: const Center(
                child: Icon(Icons.lock_clock, size: 100, color: AppColors.slate),
              ),
            ),
          ),
        ),
        
        // Paywall Card
        Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, size: 48, color: AppColors.warmPeach),
                const SizedBox(height: 16),
                Text('Upgrade to Premium', style: AppTextStyles.headlineMedium),
                const SizedBox(height: 8),
                Text(
                  'Unlock your Food Journal, Nutrition Tracking, and Daily Insights.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.slate),
                ),
                const SizedBox(height: 24),
                _buildBenefitRow('Track Calories & Macros'),
                const SizedBox(height: 8),
                _buildBenefitRow('Unlimited PDF Extractions'),
                const SizedBox(height: 8),
                _buildBenefitRow('Weekly Health Reports'),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : onUnlock,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.freshMint,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      disabledBackgroundColor: AppColors.freshMint.withOpacity(0.5),
                    ),
                    child: isLoading 
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Unlock Premium', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBenefitRow(String text) {
    return Row(
      children: [
        const Icon(Icons.check_circle, size: 20, color: AppColors.freshMint),
        const SizedBox(width: 12),
        Text(text, style: AppTextStyles.bodyMedium),
      ],
    );
  }
}
