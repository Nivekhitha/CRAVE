import 'package:flutter/material.dart';
import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';
import '../recipe_detail/recipe_detail_screen.dart';

class EmotionalCookingScreen extends StatefulWidget {
  const EmotionalCookingScreen({super.key});

  @override
  State<EmotionalCookingScreen> createState() => _EmotionalCookingScreenState();
}

class _EmotionalCookingScreenState extends State<EmotionalCookingScreen> {
  String _selectedMood = 'Tired'; // Default selection

  final List<Map<String, dynamic>> _moods = [
    {'name': 'Tired', 'subtitle': 'Quick & Easy', 'icon': Icons.battery_charging_full, 'color': Colors.blueAccent},
    {'name': 'Homesick', 'subtitle': 'Comfort Food', 'icon': Icons.home, 'color': Colors.orangeAccent},
    {'name': 'Motivated', 'subtitle': 'Challenge Me', 'icon': Icons.fitness_center, 'color': Colors.redAccent},
    {'name': 'Happy', 'subtitle': 'Something Fun', 'icon': Icons.sentiment_very_satisfied, 'color': Colors.amber},
  ];

  // Mock data for suggestions based on mood
  List<Map<String, dynamic>> get _suggestions {
    switch (_selectedMood) {
      case 'Tired':
        return [
          {'title': '10-Min Noodle Soup', 'image': 'https://images.unsplash.com/photo-1547592166-23acbe32b97b?auto=format&fit=crop&q=80', 'tag': 'Best for Energy'},
          {'title': 'Grilled Cheese', 'image': 'https://images.unsplash.com/photo-1528735602780-2552fd46c7af?auto=format&fit=crop&q=80', 'tag': 'Low Effort'},
        ];
      case 'Homesick':
        return [
          {'title': 'Chicken Pot Pie', 'image': 'https://images.unsplash.com/photo-1626645738196-c2a7c87a8f58?auto=format&fit=crop&q=80', 'tag': 'Warm Hug'},
          {'title': 'Mom’s Stew', 'image': 'https://images.unsplash.com/photo-1547592180-85f173990554?auto=format&fit=crop&q=80', 'tag': 'Nostalgic'},
        ];
      case 'Motivated':
        return [
          {'title': 'Beef Wellington', 'image': 'https://images.unsplash.com/photo-1600891964092-4316c288032e?auto=format&fit=crop&q=80', 'tag': 'Chef Level'},
          {'title': 'Homemade Pasta', 'image': 'https://images.unsplash.com/photo-1551183053-bf91a1d81141?auto=format&fit=crop&q=80', 'tag': 'From Scratch'},
        ];
      case 'Happy':
      default:
        return [
          {'title': 'Rainbow Cake', 'image': 'https://images.unsplash.com/photo-1535141192574-5d4897c12636?auto=format&fit=crop&q=80', 'tag': 'Party Time'},
          {'title': 'DIY Pizza Night', 'image': 'https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&q=80', 'tag': 'Fun'},
        ];
    }
  }

  String get _sectionTitle {
    switch (_selectedMood) {
      case 'Tired': return 'Low Effort, High Reward';
      case 'Homesick': return 'Comfort Food for You';
      case 'Motivated': return 'Masterchef Mode';
      case 'Happy': return 'Celebrate with Food';
      default: return 'Suggestions';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Light Theme
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
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
              'Choose a mood, and we\'ll handle the menu.',
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
                      color: isSelected ? mood['color'] : AppColors.surface, // Light surface
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
              children: [
                Text(
                  _sectionTitle,
                  style: AppTextStyles.titleLarge,
                ),
                TextButton(
                  onPressed: () {},
                  child: Text('See all', style: TextStyle(color: AppColors.primary)),
                ),
              ],
            ),
            const SizedBox(height: 16),

            SizedBox(
              height: 230, // Slightly taller for shadow
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _suggestions.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final recipe = _suggestions[index];
                  return GestureDetector(
                    onTap: () {
                      // Navigate directly to Detail Screen with this mock data
                      Navigator.push(context, MaterialPageRoute(builder: (_) => RecipeDetailScreen(
                        recipeData: {
                          'title': recipe['title'],
                          'description': 'A perfect recipe for when you are feeling $_selectedMood.', // Dynamic description
                          'duration': '30 mins',
                          'difficulty': 'Medium',
                          'ingredients': [
                            {'name': 'Secret Ingredient', 'amount': '1 pinch', 'has': true},
                            {'name': 'Love', 'amount': 'Lots', 'has': true},
                          ],
                          'isTrending': false,
                          'steps': ['Smile.', 'Cook.', 'Enjoy!'],
                        },
                      )));
                    },
                    child: Container(
                      width: 160,
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
                            child: Hero(
                              tag: recipe['title'], // Simple unique tag
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                  image: DecorationImage(
                                    image: NetworkImage(recipe['image']),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    recipe['tag'],
                                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary, fontSize: 10),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  recipe['title'],
                                  style: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimary, fontSize: 16),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
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
      ),
    );
  }
}
