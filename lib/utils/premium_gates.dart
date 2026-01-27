import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/premium_service.dart';
import '../screens/premium/paywall_screen.dart';
import '../app/app_colors.dart';

class PremiumGates {
  /// Shows paywall if user doesn't have premium access to a feature
  /// Returns true if user has access (either premium or after purchase)
  static Future<bool> checkFeatureAccess(
    BuildContext context, {
    required String featureName,
    required String source,
    String? limitMessage,
  }) async {
    final premiumService = Provider.of<PremiumService>(context, listen: false);

    if (premiumService.canUseFeature(featureName)) {
      return true; // User has access
    }

    // Show paywall
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => PaywallScreen(source: source),
      ),
    );

    if (result == true) {
      return true; // User purchased premium
    }

    // User didn't purchase, show limit message if provided
    if (limitMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(limitMessage),
          backgroundColor: AppColors.primary,
          action: SnackBarAction(
            label: 'Upgrade',
            textColor: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PaywallScreen(source: '${source}_snackbar'),
                ),
              );
            },
          ),
        ),
      );
    }

    return false; // User doesn't have access
  }

  /// Check recipe limit before allowing creation
  static Future<bool> checkRecipeLimit(
    BuildContext context, {
    required int currentCount,
  }) async {
    return await checkFeatureAccess(
      context,
      featureName: 'unlimited_recipes',
      source: 'recipe_limit',
      limitMessage:
          'Recipe limit reached! Upgrade to Premium for unlimited recipes.',
    );
  }

  /// Check if user can use video recipe import
  static Future<bool> checkVideoRecipeAccess(BuildContext context) async {
    return await checkFeatureAccess(
      context,
      featureName: 'video_recipes',
      source: 'video_recipe',
      limitMessage: 'Video recipe import is a Premium feature.',
    );
  }

  /// Check if user can use auto-grocery feature
  static Future<bool> checkAutoGroceryAccess(BuildContext context) async {
    return await checkFeatureAccess(
      context,
      featureName: 'auto_grocery',
      source: 'auto_grocery',
      limitMessage: 'Auto-add to grocery list is a Premium feature.',
    );
  }

  /// Check if user can use advanced filters
  static Future<bool> checkAdvancedFiltersAccess(BuildContext context) async {
    return await checkFeatureAccess(
      context,
      featureName: 'advanced_filters',
      source: 'advanced_filters',
      limitMessage: 'Advanced filters are a Premium feature.',
    );
  }

  /// Check if user can export recipes
  static Future<bool> checkExportAccess(BuildContext context) async {
    return await checkFeatureAccess(
      context,
      featureName: 'export_recipes',
      source: 'export_recipes',
      limitMessage: 'Recipe export is a Premium feature.',
    );
  }

  /// Show a premium feature tooltip/banner
  static Widget premiumBadge({
    required Widget child,
    required bool isPremiumFeature,
    VoidCallback? onTap,
  }) {
    if (!isPremiumFeature) return child;

    return Stack(
      children: [
        Opacity(
          opacity: 0.6,
          child: child,
        ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'PRO',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Create a premium upgrade button
  static Widget upgradeButton(
    BuildContext context, {
    required String source,
    String text = 'Upgrade to Premium',
  }) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PaywallScreen(source: source),
          ),
        );
      },
      icon: const Icon(Icons.star, size: 16),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
