import 'package:flutter/material.dart';
import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';

import 'add_recipe_screen.dart';
import '../../models/recipe.dart';

class CookbookResultsScreen extends StatefulWidget {
  final List<Map<String, dynamic>>? extractedRecipes;

  const CookbookResultsScreen({super.key, this.extractedRecipes});

  @override
  State<CookbookResultsScreen> createState() => _CookbookResultsScreenState();
}

class _CookbookResultsScreenState extends State<CookbookResultsScreen> {
  late List<Map<String, dynamic>> _extractedRecipes;

  @override
  void initState() {
    super.initState();
    _extractedRecipes = widget.extractedRecipes ?? [
      {
        'title': 'Classic Pancakes',
        'duration': '20 min',
        'difficulty': 'Easy',
        'selected': true,
      },
      {
        'title': 'Blueberry Muffin',
        'duration': '35 min',
        'difficulty': 'Medium',
        'selected': true,
      },
    ];
  }

  int get _selectedCount => _extractedRecipes.where((r) => r['selected']).length;

  void _saveSelected() {
    final selected = _extractedRecipes.where((r) => r['selected']).toList();
    if (selected.isEmpty) return;

    if (selected.length == 1) {
      // Powerful Demo Moment: Go to editor to show fields matched
      final item = selected.first;
      Map<String, dynamic> initialData = {};
      
      if (item['fullRecipe'] != null) {
        final Recipe r = item['fullRecipe'];
        initialData = {
          'title': r.title,
          'description': r.description,
          'servings': 2,
          'duration': 20,
          'difficulty': 'Medium',
          'ingredients': r.ingredients,
          'steps': r.instructions?.split('\n\n') ?? [],
        };
      } else {
        // Fallback or legacy dummy data
        initialData = {'title': item['title']};
      }

      Navigator.push(
        context, 
        MaterialPageRoute(builder: (_) => AddRecipeScreen(initialData: initialData))
      );
    } else {
      // Bulk save (simulated)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved $_selectedCount recipes to your collection!')),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Extracted Recipes'),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.titleLarge,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'Found ${_extractedRecipes.length} recipes from your cookbook.',
              style: AppTextStyles.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),
          
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: _extractedRecipes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final recipe = _extractedRecipes[index];
                final isSelected = recipe['selected'];
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      recipe['selected'] = !isSelected;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: isSelected ? Border.all(color: AppColors.primary, width: 2) : null,
                      boxShadow: [
                         BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.restaurant_menu, color: Colors.grey),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(recipe['title'], style: AppTextStyles.titleMedium),
                              const SizedBox(height: 4),
                              Text(
                                '${recipe['duration']} • ${recipe['difficulty']}', 
                                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle, color: AppColors.primary),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedCount > 0 ? _saveSelected : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text('Save Selected ($_selectedCount)', style: AppTextStyles.labelLarge),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
