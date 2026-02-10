import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _cookingReminders = true;
  bool _mealPlanningNotifications = true;
  bool _recipeSuggestions = true;
  bool _premiumOffers = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _cookingReminders = prefs.getBool('notif_cooking_reminders') ?? true;
      _mealPlanningNotifications = prefs.getBool('notif_meal_planning') ?? true;
      _recipeSuggestions = prefs.getBool('notif_recipe_suggestions') ?? true;
      _premiumOffers = prefs.getBool('notif_premium_offers') ?? false;
      _isLoading = false;
    });
  }

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notification Preferences',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose what notifications you want to receive',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  _buildNotificationTile(
                    icon: Icons.alarm,
                    title: 'Cooking Reminders',
                    subtitle: 'Get reminded when it\'s time to cook',
                    value: _cookingReminders,
                    onChanged: (value) {
                      setState(() => _cookingReminders = value);
                      _saveSetting('notif_cooking_reminders', value);
                    },
                  ),
                  
                  _buildNotificationTile(
                    icon: Icons.calendar_today,
                    title: 'Meal Planning',
                    subtitle: 'Weekly meal plan reminders',
                    value: _mealPlanningNotifications,
                    onChanged: (value) {
                      setState(() => _mealPlanningNotifications = value);
                      _saveSetting('notif_meal_planning', value);
                    },
                  ),
                  
                  _buildNotificationTile(
                    icon: Icons.lightbulb,
                    title: 'Recipe Suggestions',
                    subtitle: 'New recipe ideas based on your pantry',
                    value: _recipeSuggestions,
                    onChanged: (value) {
                      setState(() => _recipeSuggestions = value);
                      _saveSetting('notif_recipe_suggestions', value);
                    },
                  ),
                  
                  _buildNotificationTile(
                    icon: Icons.star,
                    title: 'Premium Offers',
                    subtitle: 'Special deals and premium features',
                    value: _premiumOffers,
                    onChanged: (value) {
                      setState(() => _premiumOffers = value);
                      _saveSetting('notif_premium_offers', value);
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildNotificationTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: AppTextStyles.titleSmall.copyWith(
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.bodySmall.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.accent,
      ),
    );
  }
}
