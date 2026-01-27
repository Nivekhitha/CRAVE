import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';
import '../../providers/user_provider.dart';
import '../../utils/error_handler.dart';
import '../../widgets/offline_banner.dart';

class PantryScreenExample extends StatefulWidget {
  const PantryScreenExample({super.key});

  @override
  State<PantryScreenExample> createState() => _PantryScreenExampleState();
}

class _PantryScreenExampleState extends State<PantryScreenExample>
    with ErrorHandlingMixin {
  final _nameController = TextEditingController();
  bool _isOffline = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _addPantryItem() async {
    if (_nameController.text.trim().isEmpty) return;

    setState(() => _isLoading = true);

    await safeAction(
      () async {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.addPantryItem({
          'name': _nameController.text.trim(),
          'category': 'Pantry',
        });
        _nameController.clear();
      },
      successMessage: 'Item added to pantry!',
      onRetry: () => _addPantryItem(),
    );

    setState(() => _isLoading = false);
  }

  Future<void> _deletePantryItem(String id, String name) async {
    await safeAction(
      () async {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.deletePantryItem(id);
      },
      successMessage: '$name removed from pantry',
      onRetry: () => _deletePantryItem(id, name),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Offline banner
          OfflineBanner(
            isOffline: _isOffline,
            onRetry: () {
              setState(() => _isOffline = false);
              // Trigger data refresh
            },
          ),

          // App bar
          AppBar(
            title: Text('My Pantry', style: AppTextStyles.titleLarge),
            backgroundColor: AppColors.background,
            elevation: 0,
          ),

          // Add item section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Add pantry item...',
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.kitchen),
                    ),
                    onSubmitted: (_) => _addPantryItem(),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isLoading ? null : _addPantryItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.add),
                ),
              ],
            ),
          ),

          // Pantry list
          Expanded(
            child: Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                final pantryItems = userProvider.pantryList;

                if (pantryItems.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: pantryItems.length,
                  itemBuilder: (context, index) {
                    final item = pantryItems[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              AppColors.primary.withValues(alpha: 0.1),
                          child: Icon(
                            Icons.kitchen,
                            color: AppColors.primary,
                          ),
                        ),
                        title: Text(
                          item['name'] ?? 'Unknown Item',
                          style: AppTextStyles.bodyLarge,
                        ),
                        subtitle: Text(
                          item['category'] ?? 'Pantry',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.red),
                          onPressed: () => _deletePantryItem(
                            item['id'] ?? '',
                            item['name'] ?? 'Item',
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.kitchen_outlined,
            size: 80,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Your pantry is empty',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add ingredients to start finding recipe matches',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Focus on the text field
              FocusScope.of(context).requestFocus();
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Your First Item'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
