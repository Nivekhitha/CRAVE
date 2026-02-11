import 'package:flutter/material.dart';
import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';
import '../../models/recipe.dart';
import '../../services/cookbook_extraction_service.dart';
import '../../services/auth_service.dart';
import '../recipe_detail/recipe_detail_screen.dart';

class CookbookResultsScreen extends StatefulWidget {
  final List<Recipe> recipes;
  final String sourceFileName;

  const CookbookResultsScreen({
    super.key,
    required this.recipes,
    required this.sourceFileName,
  });

  @override
  State<CookbookResultsScreen> createState() => _CookbookResultsScreenState();
}

class _CookbookResultsScreenState extends State<CookbookResultsScreen> {
  final CookbookExtractionService _extractionService = CookbookExtractionService();
  final AuthService _auth = AuthService();
  bool _isSaving = false;
  List<Recipe> _recipes = [];

  @override
  void initState() {
    super.initState();
    _recipes = widget.recipes;
  }

  Future<void> _handleSaveAll() async {
    setState(() => _isSaving = true);
    
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _extractionService.saveExtractedRecipes(user.uid, _recipes, widget.sourceFileName);
        
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('Saved ${_recipes.length} recipes to your cookbook!'))
           );
           // Pop back to Add Recipe main screen
           Navigator.pop(context); 
        }
      } else {
        throw Exception('User not logged in');
      }
    } catch (e) {
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('Error saving: $e'), backgroundColor: Colors.red)
           );
         setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Extraction Results'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_recipes.isNotEmpty)
            TextButton(
              onPressed: _isSaving ? null : _handleSaveAll,
              child: _isSaving 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text('Save All', style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary)),
            )
        ],
      ),
      body: _recipes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.remove_circle_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No recipes found.'),
                ],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Found ${_recipes.length} recipes in "${widget.sourceFileName}"',
                    style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey[700]),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _recipes.length,
                    itemBuilder: (context, index) {
                      final recipe = _recipes[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.restaurant, color: AppColors.primary),
                          ),
                          title: Text(recipe.title, style: AppTextStyles.titleMedium),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text('${recipe.ingredients.length} ingredients • ${recipe.totalTime ?? "?"} mins'),
                              if (recipe.description != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  recipe.description!, 
                                  maxLines: 2, 
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.bodySmall,
                                ),
                              ]
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context, 
                              MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe))
                            );
                          },
                          trailing: const Icon(Icons.chevron_right),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
