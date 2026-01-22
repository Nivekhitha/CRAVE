import 'package:flutter/material.dart';
import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';

class AddRecipeScreen extends StatefulWidget {
  final Map<String, dynamic>? initialData;

  const AddRecipeScreen({super.key, this.initialData});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  // Form Controllers
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _servingsController;
  late TextEditingController _durationController;

  // State Variables
  String _selectedDifficulty = 'Medium';
  String _selectedCategory = 'Dinner';
  
  // Dynamic Lists
  late List<TextEditingController> _ingredientControllers;
  late List<TextEditingController> _stepControllers;

  final List<String> _difficulties = ['Easy', 'Medium', 'Hard'];
  final List<String> _categories = ['Breakfast', 'Lunch', 'Dinner', 'Snack', 'Dessert'];

  @override
  void initState() {
    super.initState();
    final data = widget.initialData ?? {};
    
    _titleController = TextEditingController(text: data['title'] ?? '');
    _descriptionController = TextEditingController(text: data['description'] ?? '');
    _servingsController = TextEditingController(text: data['servings']?.toString() ?? '');
    _durationController = TextEditingController(text: data['duration']?.toString() ?? '');
    
    if (data['difficulty'] != null && _difficulties.contains(data['difficulty'])) {
      _selectedDifficulty = data['difficulty'];
    }
    
    if (data['ingredients'] != null) {
      _ingredientControllers = (data['ingredients'] as List)
          .map((e) => TextEditingController(text: e.toString()))
          .toList();
    } else {
      _ingredientControllers = [TextEditingController()];
    }

    if (data['steps'] != null) {
      _stepControllers = (data['steps'] as List)
          .map((e) => TextEditingController(text: e.toString()))
          .toList();
    } else {
      _stepControllers = [TextEditingController()];
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _servingsController.dispose();
    _durationController.dispose();
    for (var c in _ingredientControllers) c.dispose();
    for (var c in _stepControllers) c.dispose();
    super.dispose();
  }

  void _addIngredientField() {
    setState(() {
      _ingredientControllers.add(TextEditingController());
    });
  }

  void _removeIngredientField(int index) {
    if (_ingredientControllers.length > 1) {
      setState(() {
        _ingredientControllers[index].dispose();
        _ingredientControllers.removeAt(index);
      });
    }
  }

  void _addStepField() {
    setState(() {
      _stepControllers.add(TextEditingController());
    });
  }

  void _removeStepField(int index) {
    if (_stepControllers.length > 1) {
      setState(() {
        _stepControllers[index].dispose();
        _stepControllers.removeAt(index);
      });
    }
  }

  void _saveRecipe() {
    // Basic Validation
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a recipe title')),
      );
      return;
    }

    // Mock Save
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recipe Published Successfully!')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Create Recipe'),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.titleLarge,
        leading: Navigator.canPop(context) 
          ? IconButton(
              icon: const Icon(Icons.close, color: AppColors.textPrimary),
              onPressed: () => Navigator.pop(context),
            )
          : null,
        actions: [
          TextButton(
            onPressed: _saveRecipe,
            child: Text('Post', style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary)),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Upload Placeholder
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid), // Dashed border ideal but simplified
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo, size: 40, color: AppColors.primary.withOpacity(0.5)),
                  const SizedBox(height: 12),
                  Text(
                    'Add Cover Photo', 
                    style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Basic Info
            Text('Basic Info', style: AppTextStyles.titleMedium),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _titleController,
              label: 'Recipe Title',
              hint: 'e.g. Grandma\'s Apple Pie',
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _descriptionController,
              label: 'Description',
              hint: 'Tell us a bit about this dish...',
              maxLines: 3,
            ),
            const SizedBox(height: 24),

             // Metadata Row
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _durationController,
                    label: 'Time (min)',
                    hint: '45',
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _servingsController,
                    label: 'Servings',
                    hint: '2',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Dropdowns
            Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    label: 'Difficulty',
                    value: _selectedDifficulty,
                    items: _difficulties,
                    onChanged: (val) => setState(() => _selectedDifficulty = val!),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDropdown(
                    label: 'Category',
                    value: _selectedCategory,
                    items: _categories,
                    onChanged: (val) => setState(() => _selectedCategory = val!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Ingredients Section
            _buildSectionHeader('Ingredients', onAdd: _addIngredientField),
            const SizedBox(height: 8),
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: _ingredientControllers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return Row(
                  children: [
                    const Icon(Icons.drag_indicator, color: Colors.grey, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        controller: _ingredientControllers[index],
                        hint: 'e.g. 2 cups of flour',
                      ),
                    ),
                    if (_ingredientControllers.length > 1) 
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                        onPressed: () => _removeIngredientField(index),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),

            // Instructions Section
            _buildSectionHeader('Instructions', onAdd: _addStepField),
            const SizedBox(height: 8),
             ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: _stepControllers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 12, right: 12),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}', 
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ),
                    Expanded(
                      child: _buildTextField(
                        controller: _stepControllers[index],
                        hint: 'Describe this step...',
                        maxLines: 3,
                      ),
                    ),
                    if (_stepControllers.length > 1) 
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                        onPressed: () => _removeStepField(index),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 48),

            // Save Button (Bottom)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveRecipe,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text('Save Recipe', style: AppTextStyles.labelLarge.copyWith(color: AppColors.onPrimary)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {required VoidCallback onAdd}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.titleMedium),
        TextButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add'),
          style: TextButton.styleFrom(foregroundColor: AppColors.primary),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    String? label,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label, style: AppTextStyles.labelMedium),
          const SizedBox(height: 8),
        ],
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelMedium),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
