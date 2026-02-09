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
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('Your Fridge'),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                  fillColor: Theme.of(context).cardColor,
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
                            color: Theme.of(context).colorScheme.onSurfaceVariant)),
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
                            onPressed: () async {
                              // Quick Add Action
                              final Map<String, dynamic> newItem = {
                                'name': item,
                                'category': _inferCategory(item),
                                'quantity': '1',
                              };
                              try {
                                await userProvider.addPantryItem(newItem);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('$item added!'),
                                        behavior: SnackBarBehavior.floating,
                                        margin: const EdgeInsets.only(top: 80, left: 16, right: 16),
                                      ));
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Error adding $item: $e'),
                                        backgroundColor: Colors.red,
                                        behavior: SnackBarBehavior.floating,
                                        margin: const EdgeInsets.only(top: 80, left: 16, right: 16),
                                      ));
                                }
                              }
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
                        letterSpacing: 1.2, color: Theme.of(context).colorScheme.onSurfaceVariant)),
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
                                  .copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
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
                                    .copyWith(color: Theme.of(context).colorScheme.onSurface)),
                            subtitle: Text(
                              item['category'] ?? 'Other',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Quantity controls
                                Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: AppColors.primary.withValues(alpha: 0.2),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Decrease button
                                      IconButton(
                                        icon: const Icon(Icons.remove, size: 18),
                                        onPressed: () => _updateQuantity(
                                          context,
                                          userProvider,
                                          id,
                                          item,
                                          -1,
                                        ),
                                        padding: const EdgeInsets.all(4),
                                        constraints: const BoxConstraints(
                                          minWidth: 32,
                                          minHeight: 32,
                                        ),
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                      // Quantity display
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8),
                                        child: Text(
                                          item['quantity']?.toString() ?? '1',
                                          style: AppTextStyles.labelMedium.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      // Increase button
                                      IconButton(
                                        icon: const Icon(Icons.add, size: 18),
                                        onPressed: () => _updateQuantity(
                                          context,
                                          userProvider,
                                          id,
                                          item,
                                          1,
                                        ),
                                        padding: const EdgeInsets.all(4),
                                        constraints: const BoxConstraints(
                                          minWidth: 32,
                                          minHeight: 32,
                                        ),
                                        color: AppColors.primary,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Delete button
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () => _deleteIngredient(
                                    context,
                                    userProvider,
                                    id,
                                    name,
                                  ),
                                  color: Colors.red.shade400,
                                ),
                              ],
                            ),
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

  Future<void> _addNewIngredient(BuildContext context, UserProvider provider) async {
    if (_searchController.text.isEmpty) return;

    final category = _filters[_selectedFilterIndex] == 'All'
        ? 'Produce'
        : _filters[_selectedFilterIndex];

    final Map<String, dynamic> newIngredient = {
      'name': _searchController.text.trim(),
      'category': category,
      'quantity': '1', // Default quantity
    };

    try {
      await provider.addPantryItem(newIngredient);
      
      _searchController.clear();
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${newIngredient['name']} added!'),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.only(top: 80, left: 16, right: 16),
            ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error adding item: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.only(top: 80, left: 16, right: 16),
            ));
      }
    }
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

  Future<void> _updateQuantity(
    BuildContext context,
    UserProvider provider,
    String id,
    Map<String, dynamic> item,
    int change,
  ) async {
    try {
      final currentQty = int.tryParse(item['quantity']?.toString() ?? '1') ?? 1;
      final newQty = (currentQty + change).clamp(1, 99);
      
      if (newQty != currentQty) {
        // Update in Firestore via provider
        await provider.addPantryItem({
          ...item,
          'quantity': newQty.toString(),
        });
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating quantity: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(top: 80, left: 16, right: 16),
          ),
        );
      }
    }
  }

  Future<void> _deleteIngredient(
    BuildContext context,
    UserProvider provider,
    String id,
    String name,
  ) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Ingredient'),
        content: Text('Remove $name from your fridge?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await provider.deletePantryItem(id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$name removed'),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.only(top: 80, left: 16, right: 16),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error removing $name: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.only(top: 80, left: 16, right: 16),
            ),
          );
        }
      }
    }
  }
}
