import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';
import '../../providers/user_provider.dart';

class GroceryScreen extends StatefulWidget {
  const GroceryScreen({super.key});

  @override
  State<GroceryScreen> createState() => _GroceryScreenState();
}

class _GroceryScreenState extends State<GroceryScreen> {
  void _addItem() {
    TextEditingController nameController = TextEditingController();
    TextEditingController quantityController = TextEditingController();
    TextEditingController priceController = TextEditingController();
    String selectedCategory = 'Produce';
    final categories = ['Produce', 'Dairy & Eggs', 'Meat & Protein', 'Pantry', 'Others'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Item'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Item Name')),
                TextField(controller: quantityController, decoration: const InputDecoration(labelText: 'Quantity (e.g. 2, 500g)')),
                TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Price'), keyboardType: TextInputType.number),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) => selectedCategory = v!,
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary))
            ),
            ElevatedButton(
              onPressed: () {
                final newItem = {
                  'name': nameController.text,
                  'quantity': quantityController.text,
                  'price': double.tryParse(priceController.text) ?? 0.0,
                  'category': selectedCategory,
                  'checked': false,
                };
                
                // Use Provider
                Provider.of<UserProvider>(context, listen: false).addGroceryItem(newItem);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Produce': return Icons.eco_outlined;
      case 'Dairy & Eggs': return Icons.egg_outlined;
      case 'Meat & Protein': return Icons.restaurant_menu;
      case 'Pantry': return Icons.kitchen;
      default: return Icons.local_grocery_store_outlined;
    }
  }
  
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Produce': return Colors.green.shade50;
      case 'Dairy & Eggs': return Colors.orange.shade50;
      case 'Meat & Protein': return Colors.red.shade50;
      default: return Colors.grey.shade50;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final groceryItems = userProvider.groceryList;
        
        // Group items
        final Map<String, List<Map<String, dynamic>>> groupedItems = {};
        for (var item in groceryItems) {
          if (!groupedItems.containsKey(item['category'])) {
            groupedItems[item['category']] = [];
          }
          groupedItems[item['category']]!.add(item);
        }

        // Calcs
        double totalSum = groceryItems.fold(0.0, (sum, item) => sum + (item['price'] as double));
        int itemsLeftCount = groceryItems.where((item) => !(item['checked'] ?? false)).length;
        int totalItems = groceryItems.length;
        double progress = totalItems == 0 ? 0 : (totalItems - itemsLeftCount) / totalItems;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Column(
              children: [
                Text('Grocery List', style: AppTextStyles.titleLarge),
                const SizedBox(height: 4),
                SizedBox(
                  width: 120,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                  color: Theme.of(context).cardColor,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$itemsLeftCount ITEMS LEFT', 
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary, fontSize: 10, letterSpacing: 1.2, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            centerTitle: true,
            backgroundColor: AppColors.background,
            elevation: 0,
            leading: Navigator.canPop(context) 
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textPrimary),
                  onPressed: () => Navigator.pop(context),
                )
              : null,
            actions: [
              IconButton(
                icon: const Icon(Icons.add, color: AppColors.textPrimary), 
                onPressed: _addItem,
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                  children: groupedItems.entries.map((entry) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 24.0),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(entry.key),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category Header
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                            child: Row(
                              children: [
                                Icon(_getCategoryIcon(entry.key), size: 20, color: AppColors.textSecondary),
                                const SizedBox(width: 8),
                                Text(entry.key, style: AppTextStyles.titleMedium),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${entry.value.length}', 
                                    style: AppTextStyles.labelSmall.copyWith(fontSize: 10, color: AppColors.textSecondary)
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Items List
                          ...entry.value.map((item) {
final bool isChecked = item['checked'] ?? false;
                            return Dismissible(
                              key: UniqueKey(), // Use unique key for Hive items
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
                                 userProvider.deleteGroceryItemByValue(item);
                                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item deleted')));
                              },
                              child: InkWell(
                                onTap: () {
                                  // Use Provider (Index lookup is tricky if filtered, using value match logic in provider is safer or finding index)
                                  // For simplicity in this view, we find index in master list
                                  final index = groceryItems.indexOf(item);
                                  userProvider.toggleGroceryItem(index);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  child: Row(
                                    children: [
                                      // Custom Checkbox
                                      AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: isChecked ? AppColors.primary : Colors.white,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: isChecked ? AppColors.primary : Colors.grey.shade400,
                                            width: 2,
                                          ),
                                        ),
                                        child: isChecked 
                                          ? const Icon(Icons.check, size: 16, color: Colors.white) 
                                          : null,
                                      ),
                                      const SizedBox(width: 16),
                                      
                                      // Ingredient Icon
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Icon(Icons.fastfood, size: 20, color: Colors.orange.shade200), 
                                      ),
                                      const SizedBox(width: 16),
      
                                      // Text Details
                                      Expanded(
                                        child: Opacity(
                                          opacity: isChecked ? 0.5 : 1.0,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item['name'],
                                                style: AppTextStyles.bodyLarge.copyWith(
                                                  decoration: isChecked ? TextDecoration.lineThrough : null,
                                                  decorationColor: AppColors.textSecondary,
                                                  fontWeight: FontWeight.w500,
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),
                                              if (item['quantity'] != null && item['quantity'].isNotEmpty)
                                                Text(
                                                  item['quantity'],
                                                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      
                                      // Price
                                      Opacity(
                                        opacity: isChecked ? 0.5 : 1.0,
                                        child: Text(
                                          '\$${(item['price'] as double).toStringAsFixed(2)}',
                                          style: AppTextStyles.labelLarge.copyWith(color: AppColors.textPrimary),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                          const SizedBox(height: 8),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              
              // Fixed Bottom Summary Card
              Container(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Estimated Total', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        Text(
                          '\$${totalSum.toStringAsFixed(2)}', 
                          style: AppTextStyles.headlineSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Shopping Started!')));
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
                        child: Text('Start Shopping', style: AppTextStyles.labelLarge.copyWith(color: AppColors.onPrimary, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}
