import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';
import '../../models/meal_plan.dart';
import '../../models/recipe.dart';
import '../../services/meal_planning_service.dart';
import '../../providers/user_provider.dart';
import '../../widgets/images/smart_recipe_image.dart';
import '../../services/image_service.dart';

class AddMealScreen extends StatefulWidget {
  final DateTime selectedDate;
  final MealPlanningService mealPlanningService;
  final MealType? preselectedMealType;

  const AddMealScreen({
    super.key,
    required this.selectedDate,
    required this.mealPlanningService,
    this.preselectedMealType,
  });

  @override
  State<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  MealType _selectedMealType = MealType.breakfast;
  final TextEditingController _customMealController = TextEditingController();
  List<Recipe> _suggestedRecipes = [];
  bool _isLoadingSuggestions = false;

  @override
  void initState() {
    super.initState();
    _selectedMealType = widget.preselectedMealType ?? MealType.breakfast;
    _tabController = TabController(length: 2, vsync: this);
    _loadSuggestions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _customMealController.dispose();
    super.dispose();
  }

  Future<void> _loadSuggestions() async {
    setState(() {
      _isLoadingSuggestions = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final pantryItems = userProvider.pantryList;
      
      final suggestions = await widget.mealPlanningService.getSuggestionsForMealType(
        _selectedMealType,
        pantryItems,
      );
      
      setState(() {
        _suggestedRecipes = suggestions;
        _isLoadingSuggestions = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingSuggestions = false;
      });
      debugPrint('Error loading suggestions: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Add Meal - ${DateFormat('MMM d').format(widget.selectedDate)}'),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.titleLarge,
      ),
      body: Column(
        children: [
          _buildMealTypeSelector(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSuggestionsTab(),
                _buildCustomMealTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Meal Type',
            style: AppTextStyles.titleMedium,
          ),
          const SizedBox(height: 12),
          Row(
            children: MealType.values.map((mealType) {
              final isSelected = _selectedMealType == mealType;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedMealType = mealType;
                    });
                    _loadSuggestions();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : Colors.transparent,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          mealType.emoji,
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          mealType.displayName,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: isSelected ? AppColors.onPrimary : AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: AppColors.onPrimary,
        unselectedLabelColor: AppColors.textSecondary,
        tabs: const [
          Tab(text: 'Recipe Suggestions'),
          Tab(text: 'Custom Meal'),
        ],
      ),
    );
  }

  Widget _buildSuggestionsTab() {
    if (_isLoadingSuggestions) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Finding perfect recipes...'),
          ],
        ),
      );
    }

    if (_suggestedRecipes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No ${_selectedMealType.displayName.toLowerCase()} recipes found',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adding more ingredients to your pantry',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _suggestedRecipes.length,
      itemBuilder: (context, index) {
        final recipe = _suggestedRecipes[index];
        return _buildRecipeCard(recipe);
      },
    );
  }

  Widget _buildRecipeCard(Recipe recipe) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFC0392B).withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recipe image
          SizedBox(
            height: 150,
            width: double.infinity,
            child: SmartRecipeImage(
              recipe: recipe,
              size: ImageSize.card,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              fit: BoxFit.cover,
            ),
          ),
          
          // Recipe info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe.title,
                  style: AppTextStyles.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                
                Row(
                  children: [
                    if (recipe.cookTime != null) ...[
                      const Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        '${recipe.cookTime} min',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                    
                    if (recipe.difficulty != null) ...[
                      const Icon(Icons.bar_chart, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        recipe.difficulty!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Add button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _addRecipeToMealPlan(recipe),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text('Add to ${_selectedMealType.displayName}'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomMealTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add Custom Meal',
            style: AppTextStyles.titleMedium,
          ),
          const SizedBox(height: 16),
          
          TextField(
            controller: _customMealController,
            decoration: InputDecoration(
              hintText: 'Enter meal name (e.g., "Leftover Pizza")',
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          
          const SizedBox(height: 24),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _customMealController.text.trim().isNotEmpty
                  ? _addCustomMeal
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text('Add to ${_selectedMealType.displayName}'),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Custom meals are great for:\n• Leftovers\n• Takeout orders\n• Simple snacks\n• Meals without recipes',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addRecipeToMealPlan(Recipe recipe) async {
    try {
      await widget.mealPlanningService.addMealToPlan(
        widget.selectedDate,
        _selectedMealType,
        recipe,
      );
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added ${recipe.title} to ${_selectedMealType.displayName}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding meal: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _addCustomMeal() async {
    final mealName = _customMealController.text.trim();
    if (mealName.isEmpty) return;

    try {
      await widget.mealPlanningService.addCustomMealToPlan(
        widget.selectedDate,
        _selectedMealType,
        mealName,
      );
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added $mealName to ${_selectedMealType.displayName}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding meal: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}