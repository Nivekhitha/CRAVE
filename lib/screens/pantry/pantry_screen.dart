import 'package:flutter/material.dart';
import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';

class PantryScreen extends StatefulWidget {
  const PantryScreen({super.key});

  @override
  State<PantryScreen> createState() => _PantryScreenState();
}

class _PantryScreenState extends State<PantryScreen> {
  final List<String> _filters = ['All', 'Vegetables', 'Proteins', 'Dairy'];
  int _selectedFilterIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  // Mock Data
  final List<Map<String, dynamic>> _allIngredients = [
    {'name': 'Tomato', 'icon': Icons.local_pizza, 'category': 'Vegetables', 'has': true},
    {'name': 'Onion', 'icon': Icons.radio_button_checked, 'category': 'Vegetables', 'has': true},
    {'name': 'Milk', 'icon': Icons.water_drop, 'category': 'Dairy', 'has': false},
    {'name': 'Chicken', 'icon': Icons.restaurant, 'category': 'Proteins', 'has': true},
    {'name': 'Cheese', 'icon': Icons.breakfast_dining, 'category': 'Dairy', 'has': false},
    {'name': 'Spinach', 'icon': Icons.grass, 'category': 'Vegetables', 'has': false},
    {'name': 'Eggs', 'icon': Icons.egg, 'category': 'Proteins', 'has': false},
  ];

  late List<Map<String, dynamic>> _filteredIngredients;

  @override
  void initState() {
    super.initState();
    _filteredIngredients = List.from(_allIngredients);
  }

  bool _showAddButton = false;

  void _filterIngredients() {
    setState(() {
      String query = _searchController.text.toLowerCase();
      String category = _filters[_selectedFilterIndex];

      _filteredIngredients = _allIngredients.where((item) {
        bool matchesQuery = item['name'].toString().toLowerCase().contains(query);
        bool matchesCategory = category == 'All' || item['category'] == category;
        return matchesQuery && matchesCategory;
      }).toList();

      // Show add button if query is not empty and no exact match found
      if (query.isNotEmpty) {
         bool exactMatch = _allIngredients.any((item) => item['name'].toString().toLowerCase() == query);
         _showAddButton = !exactMatch;
      } else {
        _showAddButton = false;
      }
    });
  }

  void _addNewIngredient() {
    if (_searchController.text.isEmpty) return;
    
    setState(() {
      final newIngredient = {
        'name': _searchController.text, // Simple capitalization could be added
        'icon': Icons.kitchen, // Default icon
        'category': _filters[_selectedFilterIndex] == 'All' ? 'Others' : _filters[_selectedFilterIndex],
        'has': true,
      };
      _allIngredients.add(newIngredient);
      _searchController.clear();
      _filterIngredients(); // Reset filter
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${newIngredient['name']} added!')));
    });
  }

  void _onFilterSelected(int index) {
    setState(() {
      _selectedFilterIndex = index;
      _filterIngredients();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Your Fridge'),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.titleLarge,
        leading: Navigator.canPop(context) 
          ? IconButton(
              icon: const Icon(Icons.chevron_left, color: AppColors.textPrimary),
              onPressed: () => Navigator.pop(context),
            )
          : null,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => _filterIngredients(),
              onSubmitted: (_) => _addNewIngredient(),
              decoration: InputDecoration(
                hintText: 'Add an ingredient...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                suffixIcon: _showAddButton 
                  ? IconButton(
                      icon: const Icon(Icons.add_circle, color: AppColors.primary),
                      onPressed: _addNewIngredient,
                    )
                  : null,
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              children: List.generate(_filters.length, (index) {
                final isSelected = _selectedFilterIndex == index;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(_filters[index]),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) _onFilterSelected(index);
                    },
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.surface,
                    labelStyle: AppTextStyles.labelMedium.copyWith(
                      color: isSelected ? AppColors.onPrimary : AppColors.textSecondary,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    side: BorderSide.none,
                    showCheckmark: false,
                  ),
                );
              }),
            ),
          ),
          
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'CURRENT INVENTORY', 
                style: AppTextStyles.labelSmall.copyWith(letterSpacing: 1.2, color: AppColors.textSecondary)
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Ingredient List
          Expanded(
            child: _filteredIngredients.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.kitchen_outlined, size: 60, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        'No ingredients found', 
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)
                      ),
                      if (_showAddButton)
                         TextButton(
                           onPressed: _addNewIngredient,
                           child: Text('Add "${_searchController.text}"?', style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary)),
                         )
                    ],
                  ),
                )
              : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              itemCount: _filteredIngredients.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = _filteredIngredients[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(item['icon'], color: AppColors.textPrimary.withOpacity(0.7)),
                  ),
                  title: Text(item['name'], style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary)),
                  trailing: Transform.scale(
                    scale: 1.2,
                    child: Checkbox(
                      value: item['has'],
                      activeColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      onChanged: (bool? value) {
                        setState(() {
                          item['has'] = value;
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          ),

          // Save Button
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                   // Navigate back or show success
                   if (Navigator.canPop(context)) {
                     Navigator.pop(context);
                   } else {
                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ingredients Saved!')));
                   }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text('Save Ingredients', style: AppTextStyles.labelLarge.copyWith(color: AppColors.onPrimary)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
