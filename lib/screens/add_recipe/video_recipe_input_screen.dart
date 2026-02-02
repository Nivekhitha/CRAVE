import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';
import '../../services/video_recipe_service.dart';
import '../../services/url_recipe_extraction_service.dart';
import '../../services/firestore_service.dart';
import '../../services/auth_service.dart';
import '../../services/premium_service.dart';
import '../../models/recipe.dart';
import '../premium/paywall_screen.dart';

enum VideoExtractionState {
  idle,
  extracting,
  preview,
  error,
}

class VideoRecipeInputScreen extends StatefulWidget {
  const VideoRecipeInputScreen({super.key});

  @override
  State<VideoRecipeInputScreen> createState() => _VideoRecipeInputScreenState();
}

class _VideoRecipeInputScreenState extends State<VideoRecipeInputScreen> {
  final TextEditingController _urlController = TextEditingController();
  final VideoRecipeService _videoService = VideoRecipeService();
  final UrlRecipeExtractionService _instagramService = UrlRecipeExtractionService();
  final FirestoreService _firestore = FirestoreService();
  final AuthService _auth = AuthService();

  VideoExtractionState _state = VideoExtractionState.idle;
  String _errorMessage = '';
  
  // Editable fields for preview
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _servingsController = TextEditingController();
  final TextEditingController _prepTimeController = TextEditingController();
  final TextEditingController _cookTimeController = TextEditingController();
  final List<TextEditingController> _ingredientControllers = [];
  final List<TextEditingController> _instructionControllers = [];
  String _selectedDifficulty = 'Medium';
  bool _isSaving = false;

  @override
  void dispose() {
    _urlController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _servingsController.dispose();
    _prepTimeController.dispose();
    _cookTimeController.dispose();
    for (var controller in _ingredientControllers) {
      controller.dispose();
    }
    for (var controller in _instructionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _checkAndExtract() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      _showError('Please enter a URL');
      return;
    }

    // Check premium status and extraction limit
    final premiumService = Provider.of<PremiumService>(context, listen: false);
    final isPremium = premiumService.isPremium;

    if (!isPremium) {
      // Check monthly extraction count
      try {
        final monthlyCount = await _firestore.getMonthlyVideoExtractionCount();
        if (monthlyCount >= 3) {
          // Show paywall
          if (!mounted) return;
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => const PaywallScreen(source: 'video_extraction_limit'),
            ),
          );

          if (!mounted) return;
          if (result != true) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Free users can extract 3 recipes per month. Upgrade to Premium for unlimited extractions.'),
                duration: Duration(seconds: 4),
              ),
            );
            return;
          }
          // User purchased premium, reload status
          await premiumService.initialize();
        }
      } catch (e) {
        debugPrint('Error checking extraction count: $e');
        // Continue anyway - don't block user
      }
    }

    // Proceed with extraction
    await _extractRecipe(url);
  }

  Future<void> _extractRecipe(String url) async {
    setState(() {
      _state = VideoExtractionState.extracting;
      _errorMessage = '';
    });

    try {
      Map<String, dynamic> recipeData;

      if (url.contains('instagram.com')) {
         // Instagram Extraction
         final recipes = await _instagramService.extractFromInstagram(url);
         if (recipes.isEmpty) {
           throw Exception('No recipes found in this post.');
         }
         // For MVP, just take the first one
         // TODO: Show selection dialog if > 1
         recipeData = recipes.first.toMap();
      } else {
         // YouTube Extraction (Default)
         final result = await _videoService.extractFromYouTube(url);
         if (result == null) throw Exception('Failed to extract from YouTube.');
         recipeData = result;
      }

      // Populate editable fields
      _titleController.text = recipeData['title'] ?? '';
      _descriptionController.text = recipeData['description'] ?? '';
      
      // Handle int/string flexible parsing
      _servingsController.text = recipeData['servings']?.toString() ?? '';
      _prepTimeController.text = recipeData['prepTime']?.toString() ?? '';
      _cookTimeController.text = recipeData['cookTime']?.toString() ?? '';
      
      _selectedDifficulty = recipeData['difficulty'] ?? 'Medium';
      if (!['Easy', 'Medium', 'Hard'].contains(_selectedDifficulty)) {
        _selectedDifficulty = 'Medium';
      }

      // Clear existing controllers
      for (var controller in _ingredientControllers) {
        controller.dispose();
      }
      for (var controller in _instructionControllers) {
        controller.dispose();
      }
      _ingredientControllers.clear();
      _instructionControllers.clear();

      // Populate ingredients
      final ingredients = recipeData['ingredients'];
      if (ingredients is List) {
        for (var ingredient in ingredients) {
          final controller = TextEditingController(text: ingredient.toString());
          _ingredientControllers.add(controller);
        }
      } else if (ingredients is String) {
         // Handle string case just in case
         _ingredientControllers.add(TextEditingController(text: ingredients));
      }

      // Populate instructions
      final instructions = recipeData['instructions'];
      if (instructions is List) {
        for (var instruction in instructions) {
          final controller = TextEditingController(text: instruction.toString());
          _instructionControllers.add(controller);
        }
      } else if (instructions is String) {
         // Handle newline separated string
         final split = instructions.split('\n');
         for (var s in split) {
           if (s.trim().isNotEmpty) {
             _instructionControllers.add(TextEditingController(text: s.trim()));
           }
         }
      }

      if (!mounted) return;
      setState(() {
        _state = VideoExtractionState.preview;
      });
    } catch (e) {
      setState(() {
        _state = VideoExtractionState.error;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _showError(String message) {
    setState(() {
      _state = VideoExtractionState.error;
      _errorMessage = message;
    });
  }

  Future<void> _saveRecipe() async {
    // Validate
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a recipe title')),
      );
      return;
    }

    if (_ingredientControllers.isEmpty || 
        _ingredientControllers.any((c) => c.text.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one ingredient')),
      );
      return;
    }

    if (_instructionControllers.isEmpty ||
        _instructionControllers.any((c) => c.text.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one instruction step')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Please sign in to save recipes');
      }

      // Build recipe data
      final recipe = Recipe(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        source: 'video',
        sourceUrl: _urlController.text.trim(),
        ingredients: _ingredientControllers
            .map((c) => c.text.trim())
            .where((text) => text.isNotEmpty)
            .toList(),
        instructions: _instructionControllers
            .map((c) => c.text.trim())
            .where((text) => text.isNotEmpty)
            .join('\n\n'),
        servings: int.tryParse(_servingsController.text),
        prepTime: int.tryParse(_prepTimeController.text),
        cookTime: int.tryParse(_cookTimeController.text),
        difficulty: _selectedDifficulty,
      );

      // Save to Firestore
      await _firestore.saveRecipe(recipe.toMap());

      // Increment extraction counter
      await _firestore.incrementVideoExtractionCount();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recipe saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving recipe: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _addIngredient() {
    setState(() {
      _ingredientControllers.add(TextEditingController());
    });
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredientControllers[index].dispose();
      _ingredientControllers.removeAt(index);
    });
  }

  void _addInstruction() {
    setState(() {
      _instructionControllers.add(TextEditingController());
    });
  }

  void _removeInstruction(int index) {
    setState(() {
      _instructionControllers[index].dispose();
      _instructionControllers.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Extract from Video'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (_state) {
      case VideoExtractionState.idle:
        return _buildIdleState();
      case VideoExtractionState.extracting:
        return _buildExtractingState();
      case VideoExtractionState.preview:
        return _buildPreviewState();
      case VideoExtractionState.error:
        return _buildErrorState();
    }
  }

  Widget _buildIdleState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 32),
          Center(
            child: Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.play_circle_outline,
                size: 80,
                color: AppColors.primary.withOpacity(0.8),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Extract Recipe from Video',
            style: AppTextStyles.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Paste a YouTube video or Instagram Reel link and our AI will extract the recipe for you.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _urlController,
            decoration: InputDecoration(
              hintText: 'https://youtube.com/... or https://instagram.com/...',
              prefixIcon: const Icon(Icons.link, color: AppColors.textSecondary),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            onSubmitted: (_) => _checkAndExtract(),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _checkAndExtract,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text('Extract Recipe', style: AppTextStyles.labelLarge),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 20, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Free users: 3 extractions/month. Premium: Unlimited.',
                    style: AppTextStyles.labelSmall.copyWith(color: Colors.blue[800]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExtractingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                )
              ],
            ),
            child: const CircularProgressIndicator(strokeWidth: 3),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  'Analyzing video...',
                  style: AppTextStyles.bodyLarge.copyWith(color: AppColors.primary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'This may take 30-60 seconds',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewState() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Review & Edit Recipe',
                  style: AppTextStyles.titleLarge,
                ),
                const SizedBox(height: 24),
                // Title
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Recipe Title *',
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Description
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                // Times and servings row
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _prepTimeController,
                        decoration: InputDecoration(
                          labelText: 'Prep (min)',
                          filled: true,
                          fillColor: AppColors.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _cookTimeController,
                        decoration: InputDecoration(
                          labelText: 'Cook (min)',
                          filled: true,
                          fillColor: AppColors.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _servingsController,
                        decoration: InputDecoration(
                          labelText: 'Servings',
                          filled: true,
                          fillColor: AppColors.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Difficulty
                DropdownButtonFormField<String>(
                  initialValue: _selectedDifficulty,
                  decoration: InputDecoration(
                    labelText: 'Difficulty',
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: ['Easy', 'Medium', 'Hard']
                      .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedDifficulty = value);
                    }
                  },
                ),
                const SizedBox(height: 24),
                // Ingredients
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Ingredients *', style: AppTextStyles.titleMedium),
                    TextButton.icon(
                      onPressed: _addIngredient,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add'),
                    ),
                  ],
                ),
                ...List.generate(_ingredientControllers.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _ingredientControllers[index],
                            decoration: InputDecoration(
                              hintText: 'Ingredient ${index + 1}',
                              filled: true,
                              fillColor: AppColors.surface,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () => _removeIngredient(index),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 24),
                // Instructions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Instructions *', style: AppTextStyles.titleMedium),
                    TextButton.icon(
                      onPressed: _addInstruction,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add'),
                    ),
                  ],
                ),
                ...List.generate(_instructionControllers.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 12, right: 8),
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _instructionControllers[index],
                            decoration: InputDecoration(
                              hintText: 'Step ${index + 1}',
                              filled: true,
                              fillColor: AppColors.surface,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            maxLines: 2,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () => _removeInstruction(index),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 100), // Space for bottom button
              ],
            ),
          ),
        ),
        // Save button
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveRecipe,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text('Save Recipe', style: AppTextStyles.labelLarge),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Extraction Failed',
            style: AppTextStyles.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _errorMessage,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _state = VideoExtractionState.idle;
                  _errorMessage = '';
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text('Try Again', style: AppTextStyles.labelLarge),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                // Navigate to manual entry
                Navigator.pop(context);
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text('Enter Manually Instead', style: AppTextStyles.labelLarge),
            ),
          ),
        ],
      ),
    );
  }
}
