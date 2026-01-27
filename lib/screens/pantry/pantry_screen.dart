import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';
import '../../providers/user_provider.dart';

class PantryScreen extends StatefulWidget {
  const PantryScreen({super.key});

  @override
  State<PantryScreen> createState() => _PantryScreenState();
}

class _PantryScreenState extends State<PantryScreen> {
  final List<String> _filters = [
    'All',
    'Vegetables',
    'Proteins',
    'Dairy',
    'Other'
  ];
  int _selectedFilterIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(builder: (context, userProvider, child) {
      final allIngredients = userProvider.pantryList;

      // Filtering Logic
      String query = _searchController.text.toLowerCase();
      String category = _filters[_selectedFilterIndex];

      final filteredIngredients = allIngredients.where((item) {
        bool matchesQuery =
            (item['name'] ?? '').toString().toLowerCase().contains(query);
        // Simple category matching - ensure backend names match these or map them
        bool matchesCategory =
            category == 'All' || (item['category'] ?? 'Other') == category;
        // Handle 'Protein' vs 'Proteins' mismatch potentially
        if (category == 'Proteins' && item['category'] == 'Protein')
          matchesCategory = true;

        return matchesQuery && matchesCategory;
      }).toList();

      bool showAdd = query.isNotEmpty &&
          !allIngredients.any(
              (item) => (item['name'] ?? '').toString().toLowerCase() == query);

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
                  icon: const Icon(Icons.chevron_left,
                      color: AppColors.textPrimary),
                  onPressed: () => Navigator.pop(context),
                )
              : null,
        ),
        body: Column(
          children: [
            // Search Bar
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _addNewIngredient(context, userProvider),
                decoration: InputDecoration(
                  hintText: 'Add an ingredient...',
                  prefixIcon:
                      const Icon(Icons.search, color: AppColors.textSecondary),
                  suffixIcon: showAdd
                      ? IconButton(
                          icon: const Icon(Icons.add_circle,
                              color: AppColors.primary),
                          onPressed: () =>
                              _addNewIngredient(context, userProvider),
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                        if (selected) {
                          setState(() {
                            _selectedFilterIndex = index;
                          });
                        }
                      },
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.surface,
                      labelStyle: AppTextStyles.labelMedium.copyWith(
                        color: isSelected
                            ? AppColors.onPrimary
                            : AppColors.textSecondary,
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      side: BorderSide.none,
                      showCheckmark: false,
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 16),

            // Quick Add Chips (Common Items)
            if (_searchController.text.isEmpty &&
                _filters[_selectedFilterIndex] == 'All')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text('QUICK ADD',
                        style: AppTextStyles.labelSmall.copyWith(
                            letterSpacing: 1.2,
                            color: AppColors.textSecondary)),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      children: [
                        'Milk',
                        'Eggs',
                        'Bread',
                        'Butter',
                        'Cheese',
                        'Onion',
                        'Tomato',
                        'Potato',
                        'Chicken',
                        'Rice'
                      ]
                          .where((item) => !userProvider.pantryList.any((p) =>
                              (p['name'] as String).toLowerCase() ==
                              item.toLowerCase()))
                          .map((item) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ActionChip(
                            label: Text(item),
                            avatar: const Icon(Icons.add,
                                size: 16, color: AppColors.primary),
                            backgroundColor: AppColors.surface,
                            side: BorderSide(
                                color: Colors.grey.withValues(alpha: 0.2)),
                            labelStyle: AppTextStyles.bodyMedium
                                .copyWith(color: AppColors.textPrimary),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            onPressed: () {
                              // Quick Add Action
                              final newItem = {
                                'name': item,
                                'category': _inferCategory(item),
                                'quantity': '1',
                              };
                              userProvider.addPantryItem(newItem);
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('$item added!')));
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),

            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('CURRENT INVENTORY',
                    style: AppTextStyles.labelSmall.copyWith(
                        letterSpacing: 1.2, color: AppColors.textSecondary)),
              ),
            ),
            const SizedBox(height: 8),

            // Ingredient List
            Expanded(
              child: filteredIngredients.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.kitchen_outlined,
                              size: 60, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text('No ingredients found',
                              style: AppTextStyles.bodyMedium
                                  .copyWith(color: AppColors.textSecondary)),
                          if (showAdd)
                            TextButton(
                              onPressed: () =>
                                  _addNewIngredient(context, userProvider),
                              child: Text('Add "${_searchController.text}"?',
                                  style: AppTextStyles.labelLarge
                                      .copyWith(color: AppColors.primary)),
                            )
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 8),
                      itemCount: filteredIngredients.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = filteredIngredients[index];
                        final String name = item['name'] ?? 'Unknown';
                        final String id =
                            item['id']; // Must exist from Firestore

                        return Dismissible(
                          key: Key(id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20.0),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.delete_outline,
                                color: Colors.red),
                          ),
                          onDismissed: (direction) {
                            userProvider.deletePantryItem(id);
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('$name removed')));
                          },
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Icon(
                                _getIconForCategory(item['category']),
                                color: AppColors.primary,
                                size: 24,
                              ),
                            ),
                            title: Text(name,
                                style: AppTextStyles.bodyLarge
                                    .copyWith(color: AppColors.textPrimary)),
                            subtitle: item['quantity'] != null
                                ? Text(item['quantity'])
                                : null,
                          ),
                        );
                      },
                    ),
            ),

            // Done Button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text('Done',
                      style: AppTextStyles.labelLarge
                          .copyWith(color: AppColors.onPrimary)),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  void _addNewIngredient(BuildContext context, UserProvider provider) {
    if (_searchController.text.isEmpty) return;

    final category = _filters[_selectedFilterIndex] == 'All'
        ? 'Produce'
        : _filters[_selectedFilterIndex];

    final newIngredient = {
      'name': _searchController.text.trim(),
      'category': category,
      'quantity': '1', // Default quantity
    };

    provider.addPantryItem(newIngredient);

    _searchController.clear();
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${newIngredient['name']} added!')));
  }

  IconData _getIconForCategory(String? category) {
    switch (category) {
      case 'Vegetables':
      case 'Produce':
        return Icons.eco;
      case 'Proteins':
      case 'Protein':
        return Icons.restaurant;
      case 'Dairy':
        return Icons.egg; // Closest to dairy
      default:
        return Icons.kitchen;
    }
  }

  String _inferCategory(String name) {
    final lower = name.toLowerCase();
    if (['milk', 'cheese', 'butter', 'yogurt', 'cream'].contains(lower))
      return 'Dairy';
    if ([
      'chicken',
      'beef',
      'pork',
      'fish',
      'salmon',
      'tuna',
      'steak',
      'egg',
      'eggs'
    ].contains(lower)) return 'Proteins';
    if (['onion', 'tomato', 'potato', 'carrot', 'spinach', 'lettuce', 'garlic']
        .contains(lower)) return 'Vegetables';
    return 'Other';
  }
}
