import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';
import '../../widgets/premium/premium_gate.dart';
import '../recipe_detail/recipe_detail_screen.dart';
import '../../providers/user_provider.dart';
import '../../services/recipe_ai_service.dart';
import '../../models/recipe.dart';

class EmotionalCookingScreen extends StatefulWidget {
  const EmotionalCookingScreen({super.key});

  @override
  State<EmotionalCookingScreen> createState() => _EmotionalCookingScreenState();
}

class _EmotionalCookingScreenState extends State<EmotionalCookingScreen> {
  String _selectedMood = 'Tired'; 
  bool _isLoading = false;
  List<Recipe> _aiRecipes = [];
  final RecipeAiService _aiService = RecipeAiService();
  String? _errorMessage;

  final List<Map<String, dynamic>> _moods = [
    {'name': 'Tired', 'subtitle': 'Quick & Easy', 'icon': Icons.battery_charging_full, 'color': Colors.blueAccent},
    {'name': 'Sad', 'subtitle': 'Comfort Food', 'icon': Icons.home, 'color': Colors.orangeAccent}, // Changed Homesick to Sad to match prompt
    {'name': 'Happy', 'subtitle': 'Fun & Light', 'icon': Icons.sentiment_very_satisfied, 'color': Colors.amber},
    {'name': 'Romantic', 'subtitle': 'Cozy & Date Night', 'icon': Icons.favorite, 'color': Colors.pinkAccent},
     // Kept Motivated but mapped to Happy/Healthy logic if needed, or user can expand
  ];

  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    // Fetch initial suggestions after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchRecipesForMood();
    });
  }

  String get _sectionTitle {
    switch (_selectedMood) {
      case 'Tired': return 'Low Effort, High Reward';
      case 'Sad': return 'Comfort Food for You';
      case 'Happy': return 'Treat Yourself';
      case 'Romantic': return 'Date Night Ideas';
      default: return 'Suggestions';
    }
  }

  Future<void> _fetchRecipesForMood() async {
    // Prevent double taps
    if (_isGenerating) return;

    final provider = Provider.of<UserProvider>(context, listen: false);
    final ingredients = provider.pantryList.map((e) => e['name'].toString()).toList();

    if (ingredients.isEmpty) {
      if (mounted) {
        setState(() {
          _aiRecipes = [];
          _errorMessage = "Your fridge is empty! Add some items first.";
        });
      }
      return;
    }

    setState(() {
      _isLoading = true;
      _isGenerating = true; // Set lock
      _errorMessage = null;
    });

    try {
      final recipes = await _aiService.suggestRecipesByMood(_selectedMood, ingredients);
      if (mounted) {
        setState(() {
          _aiRecipes = recipes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Could not fetch recipes. Check your connection.";
          debugPrint("Error fetching mood recipes: $e");
        });
      }
    } finally {
      if (mounted) {
        setState(() {
           _isGenerating = false; // Release lock
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PremiumGate(
      featureId: 'emotional_cooking',
      child: Scaffold(
        backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'How are you\nfeeling today?',
                  style: AppTextStyles.headlineLarge.copyWith(height: 1.1),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose a mood, and we\'ll suggest recipes based on your fridge.',
                  style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 32),

                // Mood Grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.4,
                  ),
                  itemCount: _moods.length,
                  itemBuilder: (context, index) {
                    final mood = _moods[index];
                    final isSelected = _selectedMood == mood['name'];
                    
                    return GestureDetector(
                      onTap: _isGenerating ? null : () { // Disable tap if generating
                        setState(() {
                          _selectedMood = mood['name'];
                        });
                        _fetchRecipesForMood();
                      },
                      child: Opacity( // Visually indicate disabled state
                        opacity: _isGenerating && !isSelected ? 0.5 : 1.0, 
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(20),
                            border: isSelected ? null : Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              if (isSelected)
                                BoxShadow(
                                  color: (mood['color'] as Color).withOpacity(0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                )
                              else
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                mood['icon'], 
                                color: isSelected ? Colors.white : mood['color'],
                                size: 32,
                              ),
                              const Spacer(),
                              Text(
                                mood['name'],
                                style: AppTextStyles.titleMedium.copyWith(
                                  color: isSelected ? Colors.white : AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                mood['subtitle'],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: isSelected ? Colors.white.withOpacity(0.9) : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 40),

                // Suggestions Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        _sectionTitle,
                        style: AppTextStyles.titleLarge,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                if (_isLoading)
                  const Center(child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ))
                else if (_errorMessage != null)
                   Container(
                        padding: const EdgeInsets.all(32),
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            Icon(Icons.error_outline, size: 48, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            Text(
                              _errorMessage!,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      )
                else if (_aiRecipes.isEmpty)
                    Container(
                        padding: const EdgeInsets.all(32),
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            Icon(Icons.soup_kitchen_outlined, size: 48, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            Text(
                              "No matching recipes found for this mood.",
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      )
                else
                    SizedBox(
                        height: 250,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _aiRecipes.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 16),
                          itemBuilder: (context, index) {
                            final recipe = _aiRecipes[index];
                    
                            return GestureDetector(
                              onTap: () {
                                // Since these are AI-generated dynamic recipes, 
                                // they are complete objects. We can pass them directly.
                                Navigator.push(context, MaterialPageRoute(builder: (_) => RecipeDetailScreen(
                                  recipe: recipe
                                )));
                              },
                              child: Container(
                                width: 200,
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                          color: Colors.grey.shade200,
                                        ),
                                        child: Center(
                                          child: Icon(Icons.restaurant, size: 40, color: Colors.grey.shade400),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 4, // More space for description
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              recipe.title,
                                              style: AppTextStyles.titleMedium.copyWith(fontSize: 15),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            if (recipe.description != null)
                                              Text(
                                                recipe.description!,
                                                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 11),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            const Spacer(),
                                            Row(
                                              children: [
                                                Icon(Icons.schedule, size: 14, color: AppColors.textSecondary),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${recipe.totalTime ?? 25} min',
                                                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
                                                ),
                                                const SizedBox(width: 8),
                                                Icon(Icons.speed, size: 14, color: AppColors.textSecondary),
                                                 const SizedBox(width: 4),
                                                Text(
                                                  recipe.difficulty ?? 'Easy',
                                                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ],
            ),
          );
        },
      ),
      ),
    );
  }
}
