import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';
import '../recipe_detail/recipe_detail_screen.dart';
import '../../providers/user_provider.dart';
import '../../services/recipe_matching_service.dart';

class EmotionalCookingScreen extends StatefulWidget {
  const EmotionalCookingScreen({super.key});

  @override
  State<EmotionalCookingScreen> createState() => _EmotionalCookingScreenState();
}

class _EmotionalCookingScreenState extends State<EmotionalCookingScreen> {
  String _selectedMood = 'Tired'; 

  final List<Map<String, dynamic>> _moods = [
    {'name': 'Tired', 'subtitle': 'Quick & Easy', 'icon': Icons.battery_charging_full, 'color': Colors.blueAccent},
    {'name': 'Homesick', 'subtitle': 'Comfort Food', 'icon': Icons.home, 'color': Colors.orangeAccent},
    {'name': 'Motivated', 'subtitle': 'Healthy & Fresh', 'icon': Icons.fitness_center, 'color': Colors.green},
    {'name': 'Happy', 'subtitle': 'Sweet & fun', 'icon': Icons.sentiment_very_satisfied, 'color': Colors.amber},
  ];

  String get _sectionTitle {
    switch (_selectedMood) {
      case 'Tired': return 'Low Effort, High Reward';
      case 'Homesick': return 'Comfort Food for You';
      case 'Motivated': return 'Fuel Your Body';
      case 'Happy': return 'Treat Yourself';
      default: return 'Suggestions';
    }
  }

  // Filter Logic
  List<RecipeMatch> _getFilteredMatches(UserProvider provider) {
    // 1. Get all matches (already sorted by availability)
    final allMatches = provider.recipeMatches;
    
    // 2. Filter by Mood
    return allMatches.where((match) {
      final r = match.recipe;
      final tags = r.tags?.map((e) => e.toLowerCase()).toList() ?? [];
      final title = r.title.toLowerCase();

      switch (_selectedMood) {
        case 'Tired':
          // Quick, Easy, < 25 mins
          return (r.totalTime != null && r.totalTime! <= 25) || 
                 tags.contains('quick') || 
                 tags.contains('easy');
        case 'Homesick':
          // Comfort, Soup, Warm
          return tags.contains('comfort food') || 
                 tags.contains('soup') || 
                 title.contains('soup') || 
                 title.contains('stew') ||
                 tags.contains('warm');
        case 'Motivated':
          // Healthy, Vegetarian, maybe harder ones?
          return tags.contains('healthy') || 
                 tags.contains('salad') || 
                 tags.contains('vegan') ||
                 tags.contains('vegetarian') ||
                 title.contains('salad');
        case 'Happy':
          // Dessert, Fun, Party
          return tags.contains('dessert') || 
                 tags.contains('sweet') || 
                 tags.contains('party') ||
                 title.contains('cake') ||
                 title.contains('cookie');
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          final suggestions = _getFilteredMatches(userProvider);

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
                  'Choose a mood, and we\'ll suggest recipes based on what you have.',
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
                      onTap: () => setState(() => _selectedMood = mood['name']),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected ? mood['color'] : AppColors.surface,
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
                              style: AppTextStyles.labelSmall.copyWith(
                                color: isSelected ? Colors.white.withOpacity(0.9) : AppColors.textSecondary,
                              ),
                            ),
                          ],
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
                    if (suggestions.isNotEmpty)
                      Text(
                        '${suggestions.length} matches', 
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                suggestions.isEmpty
                    ? Container(
                        padding: const EdgeInsets.all(32),
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            Icon(Icons.soup_kitchen_outlined, size: 48, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            Text(
                              "No recipes found for this mood with your current ingredients.",
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      )
                    : SizedBox(
                        height: 250,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: suggestions.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 16),
                          itemBuilder: (context, index) {
                            final match = suggestions[index];
                            final recipe = match.recipe;
                            final hasIngredients = match.matchPercentage > 0;

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => RecipeDetailScreen(
                                  recipe: recipe
                                )));
                              },
                              child: Container(
                                width: 180,
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
                                      child: Hero(
                                        tag: 'mood_${recipe.id}',
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                            image: DecorationImage(
                                              image: recipe.imageUrl != null && recipe.imageUrl!.startsWith('http')
                                                ? NetworkImage(recipe.imageUrl!)
                                                : AssetImage(recipe.imageUrl ?? 'assets/images/placeholder_food.png') as ImageProvider,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          child: hasIngredients 
                                            ? Align(
                                                alignment: Alignment.topRight,
                                                child: Container(
                                                  margin: const EdgeInsets.all(8),
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: Colors.green,
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Text(
                                                    '${match.matchPercentage.toInt()}% Match',
                                                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                              ) 
                                            : null,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              recipe.title,
                                              style: AppTextStyles.titleMedium.copyWith(fontSize: 15),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Row(
                                              children: [
                                                Icon(Icons.schedule, size: 14, color: AppColors.textSecondary),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${recipe.totalTime ?? 25} min',
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
    );
  }
}
