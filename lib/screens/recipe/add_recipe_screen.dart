import 'package:flutter/material.dart';
import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';

class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({super.key});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _cookTimeController = TextEditingController();
  
  // Lists for dynamic fields
  final List<TextEditingController> _ingredientControllers = [TextEditingController()];
  final List<TextEditingController> _stepControllers = [TextEditingController()];

  void _addIngredientField() {
    setState(() {
      _ingredientControllers.add(TextEditingController());
    });
  }

  void _addStepField() {
    setState(() {
      _stepControllers.add(TextEditingController());
    });
  }

  void _saveRecipe() {
    if (_formKey.currentState!.validate()) {
      // Mock Save Logic
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recipe Saved Successfully!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('New Recipe'),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
        titleTextStyle: AppTextStyles.titleLarge,
        leading: IconButton(
          icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _saveRecipe,
            child: Text('Save', style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary)),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Placeholder
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
        fillColor: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo, size: 40, color: AppColors.primary.withOpacity(0.5)),
                      const SizedBox(height: 8),
                      Text('Add Cover Photo', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Basic Info
                Text('Details', style: AppTextStyles.titleMedium),
                const SizedBox(height: 16),
                _buildTextField(controller: _titleController, label: 'Recipe Title', hint: 'e.g. Grandma\'s Apple Pie'),
                const SizedBox(height: 16),
                _buildTextField(controller: _descriptionController, label: 'Description', hint: 'Short story about this dish...', maxLines: 3),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildTextField(controller: _cookTimeController, label: 'Cook Time (min)', hint: '30', keyboardType: TextInputType.number)),
                    const SizedBox(width: 16),
                     // Difficulty dropdown could go here
                     Expanded(child: Container()), 
                  ],
                ),
                const SizedBox(height: 32),

                // Ingredients
                _buildSectionHeader('Ingredients', _addIngredientField),
                ..._ingredientControllers.asMap().entries.map((entry) {
                   return Padding(
                     padding: const EdgeInsets.only(bottom: 12.0),
                     child: _buildTextField(
                       controller: entry.value, 
                       hint: 'e.g. 2 cups Flour', 
                       prefixIcon: Icons.circle, 
                       prefixIconSize: 8
                     ),
                   );
                }),
                
                const SizedBox(height: 32),

                // Steps
                _buildSectionHeader('Instructions', _addStepField),
                 ..._stepControllers.asMap().entries.map((entry) {
                   return Padding(
                     padding: const EdgeInsets.only(bottom: 12.0),
                     child: Row(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Container(
                           margin: const EdgeInsets.only(top: 12, right: 12),
                           width: 24,
                           alignment: Alignment.center,
                           decoration: const BoxDecoration(
                             color: AppColors.primary,
                             shape: BoxShape.circle,
                           ),
                           child: Text('${entry.key + 1}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                         ),
                         Expanded(
                           child: _buildTextField(controller: entry.value, hint: 'Describe this step...', maxLines: 2),
                         ),
                       ],
                     ),
                   );
                }),
                
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onAdd) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.titleMedium),
        IconButton(
          onPressed: onAdd, 
          icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
          tooltip: 'Add Item',
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
    IconData? prefixIcon,
    double? prefixIconSize,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: (value) => (value == null || value.isEmpty) && label != null ? 'Required' : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        alignLabelWithHint: true,
        filled: true,
        fillColor: AppColors.surface,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: prefixIconSize ?? 16, color: AppColors.primary) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }
}
