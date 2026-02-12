import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/premium_service.dart';
import 'paywall_view.dart';

/// Premium gate widget that shows content for premium users or paywall for free users
class PremiumGate extends StatelessWidget {
  final Widget child;
  final String featureId;
  final String? title;
  final String? description;
  final bool showTrialInfo;

  const PremiumGate({
    super.key,
    required this.child,
    required this.featureId,
    this.title,
    this.description,
    this.showTrialInfo = true,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<PremiumService>(
      builder: (context, premiumService, _) {
        // Show loader until premium service is initialized
        if (!premiumService.isInitialized) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: const Color(0xFFC0392B),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // If user can access the feature, show the content
        if (premiumService.canUseFeature(featureId)) {
          // Use a post-frame callback to ensure smooth transition
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // This ensures the widget tree is stable before showing content
          });
          return child;
        }

        // Otherwise, show the paywall
        return PaywallView(
          featureId: featureId,
          title: title,
          description: description,
          showTrialInfo: showTrialInfo,
        );
      },
    );
  }
}

/// Convenience widget for journal features
class JournalGate extends StatelessWidget {
  final Widget child;

  const JournalGate({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumGate(
      featureId: 'journal',
      title: 'Food Journal',
      description: 'Track your meals and nutrition with detailed insights',
      child: child,
    );
  }
}

/// Convenience widget for meal planning features
class MealPlanningGate extends StatelessWidget {
  final Widget child;

  const MealPlanningGate({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumGate(
      featureId: 'meal_planning',
      title: 'Meal Planning',
      description: 'Plan your weekly meals with smart suggestions',
      child: child,
    );
  }
}

/// Convenience widget for nutrition dashboard
class NutritionGate extends StatelessWidget {
  final Widget child;

  const NutritionGate({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumGate(
      featureId: 'nutrition_dashboard',
      title: 'Nutrition Dashboard',
      description: 'Comprehensive nutrition tracking and analytics',
      showTrialInfo: false,
      child: child,
    );
  }
}

/// Convenience widget for AI dietitian features
class AIDietitianGate extends StatelessWidget {
  final Widget child;

  const AIDietitianGate({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumGate(
      featureId: 'ai_dietitian',
      title: 'Personal AI Dietitian',
      description: 'Get personalized nutrition advice and meal recommendations',
      showTrialInfo: false,
      child: child,
    );
  }
}