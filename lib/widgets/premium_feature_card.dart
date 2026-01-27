import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app/app_colors.dart';
import '../app/app_text_styles.dart';
import '../services/premium_service.dart';
import '../screens/premium/paywall_screen.dart';

class PremiumFeatureCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final String featureName;
  final Widget? child;
  final VoidCallback? onTap;

  const PremiumFeatureCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.featureName,
    this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<PremiumService>(
      builder: (context, premiumService, _) {
        final hasAccess = premiumService.canUseFeature(featureName);

        return GestureDetector(
          onTap: hasAccess ? onTap : () => _showPaywall(context),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: hasAccess
                  ? AppColors.surface
                  : AppColors.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasAccess
                    ? AppColors.primary.withValues(alpha: 0.2)
                    : AppColors.textSecondary.withValues(alpha: 0.2),
              ),
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          icon,
                          color: hasAccess
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            title,
                            style: AppTextStyles.titleMedium.copyWith(
                              color: hasAccess
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: hasAccess
                            ? AppColors.textSecondary
                            : AppColors.textSecondary.withValues(alpha: 0.7),
                      ),
                    ),
                    if (child != null) ...[
                      const SizedBox(height: 12),
                      child!,
                    ],
                  ],
                ),

                // Premium badge
                if (!hasAccess)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'PRO',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPaywall(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaywallScreen(source: featureName),
      ),
    );
  }
}

// Quick access widget for premium buttons
class PremiumButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final String featureName;
  final VoidCallback? onPressed;
  final String? source;

  const PremiumButton({
    super.key,
    required this.text,
    required this.featureName,
    this.icon,
    this.onPressed,
    this.source,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<PremiumService>(
      builder: (context, premiumService, _) {
        final hasAccess = premiumService.canUseFeature(featureName);

        return ElevatedButton.icon(
          onPressed: hasAccess ? onPressed : () => _showPaywall(context),
          icon: Icon(
            hasAccess ? (icon ?? Icons.check) : Icons.star,
            size: 16,
          ),
          label: Text(hasAccess ? text : 'Upgrade for $text'),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                hasAccess ? AppColors.primary : AppColors.textSecondary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }

  void _showPaywall(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaywallScreen(source: source ?? featureName),
      ),
    );
  }
}
