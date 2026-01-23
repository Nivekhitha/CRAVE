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
  final List<String> _filters = ['All', 'Vegetables', 'Proteins', 'Dairy'];
  int _selectedFilterIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  // Don't store local list, derive from Provider
  bool _showAddButton = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final allIngredients = userProvider.pantryList;

        // Filtering Logic
        String query = _searchController.text.toLowerCase();
        String category = _filters[_selectedFilterIndex];

        final filteredIngredients = allIngredients.where((item) {
          bool matchesQuery = item['name'].toString().toLowerCase().contains(query);
          bool matchesCategory = category == 'All' || item['category'] == category;
          return matchesQuery && matchesCategory;
        }).toList();
        
        // Add Button Logic
        bool showAdd = false;
        if (query.isNotEmpty) {
           bool exactMatch = allIngredients.any((item) => item['name'].toString().toLowerCase() == query);
           showAdd = !exactMatch;
        }

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
                  onChanged: (_) => setState(() {}), // Trigger rebuild to filter
                  onSubmitted: (_) => _addNewIngredient(context, userProvider),
                  decoration: InputDecoration(
                    hintText: 'Add an ingredient...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                    suffixIcon: showAdd 
                      ? IconButton(
                          icon: const Icon(Icons.add_circle, color: AppColors.primary),
                          onPressed: () => _addNewIngredient(context, userProvider),
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
                          if (selected) {
                            setState(() {
                              _selectedFilterIndex = index;
                            });
                          }
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
                child: filteredIngredients.isEmpty
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
                          if (showAdd)
                             TextButton(
                               onPressed: () => _addNewIngredient(context, userProvider),
                               child: Text('Add "${_searchController.text}"?', style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary)),
                             )
                        ],
                      ),
                    )
                  : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  itemCount: filteredIngredients.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = filteredIngredients[index];
                    return Dismissible(
                      key: Key(item['name']), // Hive key logic
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20.0),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.delete_outline, color: Colors.red.shade700),
                      ),
                      onDismissed: (direction) {
                        // Use Provider
                        userProvider.deletePantryItemByValue(item);
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${item['name']} removed'),
                            action: SnackBarAction(
                              label: 'UNDO',
                              onPressed: () {
                                userProvider.addPantryItem(item); // Simple undo
                              },
                            ),
                          ),
                        );
                      },
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(IconData(item['iconCode'] ?? 0xe350, fontFamily: 'MaterialIcons'), color: AppColors.textPrimary.withOpacity(0.7)),
                        ),
                        title: Text(item['name'], style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary)),
                        trailing: Transform.scale(
                          scale: 1.2,
                          child: Checkbox(
                            value: item['has'],
                            activeColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            onChanged: (bool? value) {
                              // Update Logic
                              final newItem = Map<String, dynamic>.from(item);
                              newItem['has'] = value;
                              // Find index in master list
                              final masterIndex = allIngredients.indexOf(item);
                              if (masterIndex != -1) {
                                userProvider.updatePantryItem(masterIndex, newItem);
                              }
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
    
              // Save Button (Optional now since auto-save, but keeping for UX)
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
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
                    child: Text('Done', style: AppTextStyles.labelLarge.copyWith(color: AppColors.onPrimary)),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  void _addNewIngredient(BuildContext context, UserProvider provider) {
    if (_searchController.text.isEmpty) return;
    
    final newIngredient = {
      'name': _searchController.text,
      'iconCode': Icons.kitchen.codePoint, // Store codePoint for Hive
      'category': _filters[_selectedFilterIndex] == 'All' ? 'Others' : _filters[_selectedFilterIndex],
      'has': true,
    };
    
    provider.addPantryItem(newIngredient);
    
    _searchController.clear();
    setState(() {}); // Clear query
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${newIngredient['name']} added!')));
  }
}
