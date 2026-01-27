import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';
import '../../services/firestore_service.dart';
import '../../services/premium_service.dart';
import '../../providers/user_provider.dart';
import '../../utils/error_handler.dart';
import '../premium/paywall_screen.dart';

class AddRecipeScreen extends StatefulWidget {
  final Map<String, dynamic>? initialData;

  const AddRecipeScreen({super.key, this.initialData});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen>
    with ErrorHandlingMixin {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _cookTimeController = TextEditingController();
  final _instructionsController = TextEditingController();

  // State
  List<String> _ingredients = [];
  final _ingredientController = TextEditingController();
  String _selectedDifficulty = 'Medium';
  bool _isLoading = false;

  final List<String> _difficultyOptions = ['Easy', 'Medium', 'Hard'];

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _titleController.text = widget.initialData!['title'] ?? '';
      _descriptionController.text = widget.initialData!['description'] ?? '';
      _imageUrlController.text = widget.initialData!['imageUrl'] ?? '';
      _cookTimeController.text =
          (widget.initialData!['cookTime'] ?? '').toString();
      _instructionsController.text = widget.initialData!['instructions'] ?? '';
      if (widget.initialData!['ingredients'] != null) {
        _ingredients = List<String>.from(widget.initialData!['ingredients']);
      }
      _selectedDifficulty = widget.initialData!['difficulty'] ?? 'Medium';
    }
  }

  void _addIngredient() {
    if (_ingredientController.text.isNotEmpty) {
      setState(() {
        _ingredients.add(_ingredientController.text.trim());
        _ingredientController.clear();
      });
    }
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredients.removeAt(index);
    });
  }

  Future<void> _saveRecipe() async {
    if (!_formKey.currentState!.validate()) return;
    if (_ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one ingredient')),
      );
      return;
    }

    // Premium gate: Check recipe limit
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final premiumService = Provider.of<PremiumService>(context, listen: false);

    // Get current recipe count (this would need to be implemented in UserProvider)
    // For now, we'll simulate it
    final currentRecipeCount = 5; // TODO: Get actual count from userProvider

    if (currentRecipeCount >= premiumService.maxRecipes &&
        !premiumService.isPremium) {
      // Show paywall
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => const PaywallScreen(source: 'recipe_limit'),
        ),
      );

      if (result != true) {
        // User didn't purchase, show limit message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'Recipe limit reached! Upgrade to Premium for unlimited recipes.'),
            backgroundColor: AppColors.primary,
            action: SnackBarAction(
              label: 'Upgrade',
              textColor: Colors.white,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const PaywallScreen(source: 'recipe_limit_snackbar'),
                  ),
                );
              },
            ),
          ),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    // Use error handling wrapper
    await safeAction(
      () async {
        final recipeData = {
          'title': _titleController.text.trim(),
          'description': _descriptionController.text.trim(),
          'imageUrl': _imageUrlController.text.trim().isEmpty
              ? null
              : _imageUrlController.text.trim(),
          'cookTime': int.tryParse(_cookTimeController.text) ?? 15,
          'ingredients': _ingredients,
          'instructions': _instructionsController.text.trim(),
          'difficulty': _selectedDifficulty,
          'source': 'manual',
          'isPremium': false,
          'cookCount': 0,
        };

        await FirestoreService().saveRecipe(recipeData);

        if (mounted) {
          Navigator.pop(context);
          Navigator.pop(context);
        }
      },
      successMessage: 'Recipe Saved Successfully! 👨‍🍳',
      onRetry: () => _saveRecipe(),
    );

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('New Recipe', style: AppTextStyles.titleLarge),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveRecipe,
            child: Text('Save',
                style: AppTextStyles.labelLarge.copyWith(
                    color: _isLoading ? Colors.grey : AppColors.primary)),
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  // Image URL Input
                  _buildSectionTitle('Recipe Image URL'),
                  TextFormField(
                    controller: _imageUrlController,
                    decoration: InputDecoration(
                      hintText: 'Results in a better looking recipe card',
                      hintStyle: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textSecondary),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
                      prefixIcon: const Icon(Icons.link, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  _buildSectionTitle('Recipe Title'),
                  TextFormField(
                    controller: _titleController,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Title is required' : null,
                    style: AppTextStyles.headlineSmall,
                    decoration: InputDecoration(
                      hintText: 'e.g. Grandma\'s Apple Pie',
                      border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade300)),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Description
                  _buildSectionTitle('Description'),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Short and sweet description...',
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Stats Row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('Cook Time (mins)'),
                            TextFormField(
                              controller: _cookTimeController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: '15',
                                filled: true,
                                fillColor: AppColors.surface,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none),
                                suffixText: 'min',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('Difficulty'),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedDifficulty,
                                  isExpanded: true,
                                  items: _difficultyOptions.map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value,
                                          style: AppTextStyles.bodyMedium),
                                    );
                                  }).toList(),
                                  onChanged: (newValue) {
                                    setState(() {
                                      _selectedDifficulty = newValue!;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Ingredients
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionTitle('Ingredients'),
                      TextButton.icon(
                          onPressed: _addIngredient,
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Add'))
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _ingredientController,
                          decoration: InputDecoration(
                            hintText: 'e.g. 2 cups Flour',
                            filled: true,
                            fillColor: AppColors.surface,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none),
                          ),
                          onFieldSubmitted: (_) => _addIngredient(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _ingredients.asMap().entries.map((entry) {
                      return Chip(
                        label: Text(entry.value),
                        backgroundColor:
                            AppColors.primary.withValues(alpha: 0.1),
                        deleteIcon: const Icon(Icons.close, size: 14),
                        onDeleted: () => _removeIngredient(entry.key),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Instructions
                  _buildSectionTitle('Preparation Steps'),
                  TextFormField(
                    controller: _instructionsController,
                    maxLines: 8,
                    validator: (v) => v == null || v.isEmpty
                        ? 'Instructions are required'
                        : null,
                    decoration: InputDecoration(
                      hintText:
                          '1. Preheat oven...\n2. Mix ingredients...\n(One step per line)',
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(title,
          style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
    );
  }
}
