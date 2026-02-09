import 'package:flutter/material.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/main/main_navigation_screen.dart';
import '../screens/journal/journal_hub_screen.dart';
import '../screens/journal/daily_food_journal_screen.dart';
import '../screens/journal/weekly_meal_planner_screen.dart';
import '../screens/nutrition/nutrition_dashboard_screen.dart';
import '../screens/dietitian/ai_dietitian_chat_screen.dart';
import '../screens/discovery/discovery_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/pantry/pantry_screen.dart';
import '../screens/grocery/grocery_screen.dart';
import '../screens/recipe_detail/recipe_detail_screen.dart';
import '../screens/add_recipe/add_recipe_screen.dart';
import '../screens/add_recipe/cookbook_upload_screen.dart';
import '../screens/add_recipe/add_recipe_options_screen.dart';
import '../screens/favorites/favorites_screen.dart';
import '../screens/paywall/paywall_screen.dart';
import '../models/recipe.dart';

class AppRoutes {
  // Core navigation
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String main = '/main';

  // Premium features
  static const String journalHub = '/journal';
  static const String dailyJournal = '/journal/daily';
  static const String weeklyPlanner = '/journal/weekly';
  static const String nutritionDashboard = '/nutrition';
  static const String aiDietitian = '/dietitian';
  static const String paywall = '/paywall';

  // Core features
  static const String discovery = '/discovery';
  static const String profile = '/profile';
  static const String pantry = '/pantry';
  static const String grocery = '/grocery';
  static const String recipeDetail = '/recipe';
  static const String addRecipe = '/add-recipe';
  static const String cookbookUpload = '/add-recipe/cookbook';
  static const String addRecipeOptions = '/add-recipe/options';
  static const String favorites = '/favorites';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Core navigation
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen());
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case main:
        return MaterialPageRoute(builder: (_) => const MainNavigationScreen());

      // Premium features
      case journalHub:
        return _createSlideRoute(const JournalHubScreen());
      case dailyJournal:
        return _createSlideRoute(const DailyFoodJournalScreen());
      case weeklyPlanner:
        return _createSlideRoute(const WeeklyMealPlannerScreen());
      case nutritionDashboard:
        return _createSlideRoute(const NutritionDashboardScreen());
      case aiDietitian:
        return _createSlideRoute(const AIDietitianChatScreen());
      case paywall:
        return _createModalRoute(const PaywallScreen());

      // Core features
      case discovery:
        return _createSlideRoute(const DiscoveryScreen());
      case profile:
        return _createSlideRoute(const ProfileScreen());
      case pantry:
        return _createSlideRoute(const PantryScreen());
      case grocery:
        return _createSlideRoute(const GroceryScreen());
      case addRecipe:
        return _createSlideRoute(const AddRecipeScreen());
      case cookbookUpload:
        return _createSlideRoute(const CookbookUploadScreen());
      case addRecipeOptions:
        return _createSlideRoute(const AddRecipeOptionsScreen());
      case favorites:
        return _createSlideRoute(const FavoritesScreen());

      // Recipe detail with arguments
      case recipeDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        final recipe = args?['recipe'] as Recipe?;
        if (recipe != null) {
          return _createSlideRoute(RecipeDetailScreen(recipe: recipe));
        }
        return _createErrorRoute('Recipe required');

      default:
        return _createErrorRoute('Route not found: ${settings.name}');
    }
  }

  /// Create slide transition route (iOS-style)
  static PageRouteBuilder _createSlideRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  /// Create modal transition route (bottom-up)
  static PageRouteBuilder _createModalRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  /// Create error route
  static MaterialPageRoute _createErrorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(_).pushReplacementNamed(main),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
