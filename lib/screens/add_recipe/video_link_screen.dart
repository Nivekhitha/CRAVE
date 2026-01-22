import 'dart:async';
import 'package:flutter/material.dart';
import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';
import 'add_recipe_screen.dart';

class VideoLinkScreen extends StatefulWidget {
  const VideoLinkScreen({super.key});

  @override
  State<VideoLinkScreen> createState() => _VideoLinkScreenState();
}

class _VideoLinkScreenState extends State<VideoLinkScreen> {
  final TextEditingController _linkController = TextEditingController();
  bool _isLoading = false;

  void _extractRecipe() {
    if (_linkController.text.isEmpty) return;

    setState(() => _isLoading = true);

    // Simulate Network Request
    Timer(const Duration(seconds: 2), () {
      setState(() => _isLoading = false);
      
      // Mock Extracted Data
      final mockData = {
        'title': 'Creamy Pesto Pasta',
        'description': 'A quick and delicious pasta dish with homemade basil pesto sauce.',
        'servings': 2,
        'duration': 15,
        'difficulty': 'Easy',
        'ingredients': ['200g Pasta', '1 cup Basil Leaves', '1/2 cup Parmesan Cheese', '2 cloves Garlic', '1/4 cup Olive Oil'],
        'steps': ['Boil pasta until al dente.', 'Blend basil, cheese, garlic, and oil.', 'Mix pesto with hot pasta.', 'Serve immediately.']
      };

      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (_) => AddRecipeScreen(initialData: mockData))
      );
    });
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
