import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';
import '../../app/routes.dart';
import '../../services/auth_service.dart';
import '../../services/premium_service.dart';
import '../../services/journal_service.dart';
import '../../services/meal_plan_service.dart';
import '../../services/nutrition_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();
    
    // Initialize all services
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      // Initialize premium service first
      await context.read<PremiumService>().initialize();
      
      // Initialize data services
      await context.read<JournalService>().init();
      await context.read<MealPlanService>().init();
      await context.read<NutritionService>().init();
      
      debugPrint("✅ All services initialized successfully");
    } catch (e) {
      debugPrint("❌ Service initialization error: $e");
    }

    // Navigate based on Auth State after animation and initialization
    await Future.delayed(const Duration(milliseconds: 2500));
    
    if (mounted) {
      final user = AuthService().currentUser;
      if (user != null) {
        // User is logged in, go to main navigation
        Navigator.of(context).pushReplacementNamed(AppRoutes.main);
      } else {
        // User not logged in, go to onboarding
        Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1A1A1A),
              Colors.black,
              AppColors.primary.withValues(alpha: 0.1),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Content
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Glassmorphic Logo Container
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.1),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Center(
                            child: Icon(
                              Icons.restaurant_menu_rounded,
                              color: AppColors.primary,
                              size: 60,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // App Name with glow
                      Text(
                        'CRAVE',
                        style: AppTextStyles.displayLarge.copyWith(
                          color: Colors.white,
                          letterSpacing: 4,
                          fontSize: 48,
                          shadows: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.5),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'YOUR PERSONAL AI CHEF',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: Colors.white70,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 48),
                      // Loading indicator
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primary.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
