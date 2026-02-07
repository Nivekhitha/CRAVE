import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';
import '../../services/journal_service.dart';
import '../../models/journal_entry.dart';
import '../../widgets/premium/premium_gate.dart';
import '../../providers/user_provider.dart';
import '../../models/recipe.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DailyFoodJournalScreen extends StatefulWidget {
  const DailyFoodJournalScreen({super.key});

  @override
  State<DailyFoodJournalScreen> createState() => _DailyFoodJournalScreenState();
}

class _DailyFoodJournalScreenState extends State<DailyFoodJournalScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return JournalGate(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: Text(
            'Food Journal',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            IconButton(
              onPressed: _showDatePicker,
              icon: const Icon(Icons.calendar_today),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            tabs: const [
              Tab(text: 'Breakfast'),
              Tab(text: 'Lunch'),
              Tab(text: 'Dinner'),
              Tab(text: 'Snacks'),
            ],
          ),
        ),
        body: Column(
          children: [
            _buildDateHeader(),
            _buildCaloriesSummary(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildMealTab(JournalMealType.breakfast),
                  _buildMealTab(JournalMealType.lunch),
                  _buildMealTab(JournalMealType.dinner),
                  _buildMealTab(JournalMealType.snack),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _showAddMealDialog,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text('Log Meal'),
        ),
      ),
    );
  }

  Widget _buildDateHeader() {
    final isToday = _selectedDate.day == DateTime.now().day &&
                   _selectedDate.month == DateTime.now().month &&
                   _selectedDate.year == DateTime.now().year;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.primary.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isToday ? 'Today' : _formatDate(_selectedDate),
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                _formatFullDate(_selectedDate),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                onPressed: _previousDay,
                icon: const Icon(Icons.chevron_left),
              ),
              IconButton(
                onPressed: _nextDay,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCaloriesSummary() {
    return Consumer<JournalService>(
      builder: (context, journalService, _) {
        final todayCalories = journalService.todayCalories;
        final todayProtein = journalService.todayProtein;
        final todayCarbs = journalService.todayCarbs;
        final todayFats = journalService.todayFats;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.1),
                AppColors.accent.withOpacity(0.05),
              ],
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNutrientCard('Calories', '$todayCalories', 'kcal', AppColors.primary),
              _buildNutrientCard('Protein', '$todayProtein', 'g', Colors.red),
              _buildNutrientCard('Carbs', '$todayCarbs', 'g', Colors.orange),
              _buildNutrientCard('Fats', '$todayFats', 'g', Colors.green),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNutrientCard(String label, String value, String unit, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          unit,
          style: AppTextStyles.bodySmall.copyWith(
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildMealTab(JournalMealType mealType) {
    return Consumer<JournalService>(
      builder: (context, journalService, _) {
        // For now, we'll show today's entries
        // In a full implementation, we'd filter by _selectedDate
        final entries = journalService.todayEntries
            .where((entry) => entry.mealType == mealType)
            .toList();

        if (entries.isEmpty) {
          return _buildEmptyMealState(mealType);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            return _buildMealEntryCard(entry);
          },
        );
      },
    );
  }

  Widget _buildEmptyMealState(JournalMealType mealType) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getMealTypeIcon(mealType),
            size: 64,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No ${_getMealTypeName(mealType).toLowerCase()} logged',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add your first meal',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealEntryCard(JournalEntry entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  entry.name,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'delete') {
                    _deleteEntry(entry);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _formatTime(entry.timestamp),
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          if (entry.notes != null && entry.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              entry.notes!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNutrientChip('${entry.calories} cal', AppColors.primary),
              _buildNutrientChip('${entry.protein}g protein', Colors.red),
              _buildNutrientChip('${entry.carbs}g carbs', Colors.orange),
              _buildNutrientChip('${entry.fats}g fats', Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: AppTextStyles.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showAddMealDialog() {
    final currentMealType = JournalMealType.values[_tabController.index];
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddMealBottomSheet(
        mealType: currentMealType,
        onMealAdded: (entry) {
          final journalService = Provider.of<JournalService>(context, listen: false);
          journalService.addEntry(entry);
        },
      ),
    );
  }

  void _deleteEntry(JournalEntry entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Meal'),
        content: Text('Are you sure you want to delete "${entry.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final journalService = Provider.of<JournalService>(context, listen: false);
              journalService.deleteEntry(entry.id);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showDatePicker() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  void _previousDay() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
    });
  }

  void _nextDay() {
    if (_selectedDate.isBefore(DateTime.now())) {
      setState(() {
        _selectedDate = _selectedDate.add(const Duration(days: 1));
      });
    }
  }

  // Helper methods
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    
    if (date.day == now.day && date.month == now.month && date.year == now.year) {
      return 'Today';
    } else if (date.day == yesterday.day && date.month == yesterday.month && date.year == yesterday.year) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatFullDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    const weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    
    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  IconData _getMealTypeIcon(JournalMealType mealType) {
    switch (mealType) {
      case JournalMealType.breakfast:
        return Icons.free_breakfast;
      case JournalMealType.lunch:
        return Icons.lunch_dining;
      case JournalMealType.dinner:
        return Icons.dinner_dining;
      case JournalMealType.snack:
        return Icons.cookie;
    }
  }

  String _getMealTypeName(JournalMealType mealType) {
    switch (mealType) {
      case JournalMealType.breakfast:
        return 'Breakfast';
      case JournalMealType.lunch:
        return 'Lunch';
      case JournalMealType.dinner:
        return 'Dinner';
      case JournalMealType.snack:
        return 'Snack';
    }
  }
}

class _AddMealBottomSheet extends StatefulWidget {
  final JournalMealType mealType;
  final Function(JournalEntry) onMealAdded;

  const _AddMealBottomSheet({
    required this.mealType,
    required this.onMealAdded,
  });

  @override
  State<_AddMealBottomSheet> createState() => _AddMealBottomSheetState();
}

class _AddMealBottomSheetState extends State<_AddMealBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatsController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add ${_getMealTypeName(widget.mealType)}',
                    style: AppTextStyles.titleLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  return RawAutocomplete<String>(
                    textEditingController: _nameController,

                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return const Iterable<String>.empty();
                      }
                      
                      final query = textEditingValue.text.toLowerCase();
                      
                      // Filter Pantry Items
                      final pantryMatches = userProvider.pantryList.where((item) {
                        final name = (item['name'] as String? ?? '').toLowerCase();
                        return name.contains(query);
                      }).map((item) => item['name'] as String).toList();

                      // Filter Recipes
                      final recipeMatches = userProvider.allRecipes.where((recipe) {
                        return recipe.title.toLowerCase().contains(query);
                      }).map((recipe) => recipe.title).toList();

                      return [...pantryMatches, ...recipeMatches];
                    },
                    onSelected: (String selection) {
                      _nameController.text = selection;
                    },
                    fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                      return TextFormField(
                        controller: textEditingController,
                        focusNode: focusNode,
                        decoration: const InputDecoration(
                          labelText: 'Meal Name',
                          hintText: 'Type to search pantry or recipes...',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.search),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a meal name';
                          }
                          return null;
                        },
                      );
                    },
                    optionsViewBuilder: (context, onSelected, options) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          elevation: 4.0,
                          borderRadius: BorderRadius.circular(8),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 250, maxWidth: 340), // Adjust width as needed or use LayoutBuilder
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: options.length,
                              itemBuilder: (BuildContext context, int index) {
                                final option = options.elementAt(index);
                                
                                return ListTile(
                                  leading: Icon(Icons.fastfood, color: AppColors.primary),
                                  title: Text(option),
                                  onTap: () => onSelected(option),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
                                      height: 40,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(color: Colors.grey[200]),
                                      errorWidget: (context, url, error) => Icon(icon, color: color, size: 20),
                                    ),
                                  );
                                } else {
                                  leadingWidget = Icon(icon, color: color, size: 20);
                                }

                                return ListTile(
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _caloriesController,
                      decoration: const InputDecoration(
                        labelText: 'Calories',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Invalid';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _proteinController,
                      decoration: const InputDecoration(
                        labelText: 'Protein (g)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _carbsController,
                      decoration: const InputDecoration(
                        labelText: 'Carbs (g)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _fatsController,
                      decoration: const InputDecoration(
                        labelText: 'Fats (g)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  hintText: 'How did it taste? Any modifications?',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _saveMeal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Add Meal'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveMeal() {
    if (_formKey.currentState!.validate()) {
      final entry = JournalEntry(
        id: const Uuid().v4(),
        mealType: widget.mealType,
        name: _nameController.text.trim(),
        calories: int.tryParse(_caloriesController.text) ?? 0,
        protein: int.tryParse(_proteinController.text) ?? 0,
        carbs: int.tryParse(_carbsController.text) ?? 0,
        fats: int.tryParse(_fatsController.text) ?? 0,
        timestamp: DateTime.now(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );
      
      widget.onMealAdded(entry);
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Meal added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  String _getMealTypeName(JournalMealType mealType) {
    switch (mealType) {
      case JournalMealType.breakfast:
        return 'Breakfast';
      case JournalMealType.lunch:
        return 'Lunch';
      case JournalMealType.dinner:
        return 'Dinner';
      case JournalMealType.snack:
        return 'Snack';
    }
  }
}