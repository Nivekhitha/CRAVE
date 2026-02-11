import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _logoScaleController;
  late AnimationController _logoRotateController;
  late AnimationController _titleController;
  late AnimationController _subtitleController;

  // Animations
  late Animation<double> _logoScale;
  late Animation<double> _logoRotate;
  late Animation<double> _titleOpacity;
  late Animation<double> _titleTranslateY;
  late Animation<double> _subtitleOpacity;
  late Animation<double> _subtitleTranslateY;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
    _initializeServices();
  }

  void _initializeAnimations() {
    // Logo scale animation (spring effect)
    _logoScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _logoScale = CurvedAnimation(
      parent: _logoScaleController,
      curve: Curves.elasticOut,
    );

    // Logo rotate animation
    _logoRotateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _logoRotate = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoRotateController, curve: Curves.easeInOut),
    );

    // Title animations
    _titleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(_titleController);
    _titleTranslateY = Tween<double>(begin: 12.0, end: 0.0).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.easeOut),
    );

    // Subtitle animations
    _subtitleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _subtitleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(_subtitleController);
    _subtitleTranslateY = Tween<double>(begin: 8.0, end: 0.0).animate(
      CurvedAnimation(parent: _subtitleController, curve: Curves.easeOut),
    );
  }

  Future<void> _startAnimationSequence() async {
    // 1. Logo scale (spring)
    await _logoScaleController.forward();
    
    // 2. Logo rotate
    await _logoRotateController.forward();
    
    // 3. Title fade in and translate
    await _titleController.forward();
    
    // 4. Subtitle fade in and translate
    await _subtitleController.forward();
    
    // Wait a bit before navigation
    await Future.delayed(const Duration(milliseconds: 400));
    
    // Navigate after animations complete
    _navigateToNextScreen();
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
  }

  void _navigateToNextScreen() {
    if (!mounted) return;
    
    final user = AuthService().currentUser;
    if (user != null) {
      // User is logged in, go to main navigation
      Navigator.of(context).pushReplacementNamed(AppRoutes.main);
    } else {
      // User not logged in, go to onboarding
      Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
    }
  }

  @override
  void dispose() {
    _logoScaleController.dispose();
    _logoRotateController.dispose();
    _titleController.dispose();
    _subtitleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC0392B), // Orange-red background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Logo
            AnimatedBuilder(
              animation: Listenable.merge([_logoScale, _logoRotate]),
              builder: (context, child) {
                // Interpolate rotation: 0deg -> 8deg -> 0deg
                final rotationValue = _logoRotate.value;
                double rotation = 0.0;
                if (rotationValue <= 0.5) {
                  rotation = (rotationValue * 2) * 0.14; // 0 to 8 degrees (0.14 radians)
                } else {
                  rotation = ((1.0 - rotationValue) * 2) * 0.14; // 8 to 0 degrees
                }

                return Transform.scale(
                  scale: _logoScale.value,
                  child: Transform.rotate(
                    angle: rotation,
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            offset: const Offset(0, 6),
                            blurRadius: 16,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: Image.asset(
                          'assets/images/logo.jpeg',
                          width: 160,
                          height: 160,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 28),
            
            // Animated Title
            AnimatedBuilder(
              animation: _titleController,
              builder: (context, child) {
                return Opacity(
                  opacity: _titleOpacity.value,
                  child: Transform.translate(
                    offset: Offset(0, _titleTranslateY.value),
                    child: const Text(
                      'CRAVE',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 6,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            
            // Animated Subtitle
            AnimatedBuilder(
              animation: _subtitleController,
              builder: (context, child) {
                return Opacity(
                  opacity: _subtitleOpacity.value,
                  child: Transform.translate(
                    offset: Offset(0, _subtitleTranslateY.value),
                    child: Text(
                      'Your AI kitchen companion',
                      style: TextStyle(
                        fontSize: 15,
                        color: const Color(0xFFFFE0DC).withValues(alpha: 0.85),
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
