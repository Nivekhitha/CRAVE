import 'dart:async';
import 'package:flutter/material.dart';
import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';
import '../../services/recipe_extraction_service.dart';
import '../../models/recipe.dart';
import 'add_recipe_screen.dart';

class VideoLinkScreen extends StatefulWidget {
  const VideoLinkScreen({super.key});

  @override
  State<VideoLinkScreen> createState() => _VideoLinkScreenState();
}

class _VideoLinkScreenState extends State<VideoLinkScreen> {
  final TextEditingController _linkController = TextEditingController();
  bool _isLoading = false;

  Future<void> _extractRecipe() async {
    final url = _linkController.text.trim();
    if (url.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      // Call the REAL backend (Deterministic Demo)
      final Recipe? recipe = await RecipeExtractionService().extractRecipe(url: url);

      if (recipe != null) {
        if (!mounted) return;
        
        // Map Recipe object to the Map format AddRecipeScreen expects
        final initialData = {
          'title': recipe.title,
          'description': recipe.description,
          'servings': 2, // Backend doesn't return servings yet in simple model, defaulting
          'duration': 20, // Backend sends string "45 mins", UI expects int. keeping simple.
          'difficulty': 'Medium',
          'ingredients': recipe.ingredients,
          'steps': recipe.instructions?.split('\n\n') ?? [],
        };

        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (_) => AddRecipeScreen(initialData: initialData))
        );
      } else {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not extract recipe. Try another link.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Add via Link'),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.titleLarge,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
             Text(
              'Paste a link to extract the recipe',
              style: AppTextStyles.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Supports YouTube and Instagram Reels',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
             const SizedBox(height: 32),

            TextField(
              controller: _linkController,
              decoration: InputDecoration(
                hintText: 'https://youtube.com/watch?v=...',
                prefixIcon: const Icon(Icons.link, color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const Spacer(),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _extractRecipe,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text('Extract Recipe', style: AppTextStyles.labelLarge),
              ),
            ),
             const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
