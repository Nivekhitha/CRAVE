# 🗓️ Meal Planning Feature - Crave App

## 📋 **Overview**

The Meal Planning feature allows users to plan their meals for future dates, helping them organize their cooking schedule, reduce food waste, and ensure they have all necessary ingredients.

## ✨ **Key Features**

### **1. Weekly Meal Planning**
- 📅 **Calendar View**: Visual week-by-week meal planning
- 🔄 **Navigation**: Easy navigation between weeks
- 📱 **Mobile-First**: Optimized for mobile screens
- 🎯 **Date Selection**: Tap any day to plan meals

### **2. Meal Types Support**
- 🌅 **Breakfast**: Morning meals and quick starts
- ☀️ **Lunch**: Midday meals and light options  
- 🌙 **Dinner**: Evening meals and hearty dishes
- 🍎 **Snacks**: Light bites and treats

### **3. Smart Recipe Suggestions**
- 🤖 **AI-Powered**: Suggests recipes based on meal type
- 🧺 **Pantry-Based**: Uses available ingredients
- ⏱️ **Time-Aware**: Considers cooking time for meal type
- 🏷️ **Tag-Based**: Filters by breakfast, lunch, dinner tags

### **4. Custom Meals**
- ✏️ **Custom Names**: Add meals without recipes
- 🍕 **Leftovers**: Plan for leftover meals
- 🥡 **Takeout**: Include restaurant orders
- 🍪 **Simple Snacks**: Quick non-recipe items

### **5. Auto-Generation**
- 🎯 **Weekly Plans**: Generate entire week automatically
- 🧠 **Smart Distribution**: Balances meal types across days
- 🔄 **Variety**: Ensures recipe diversity
- 📊 **Pantry-Optimized**: Uses available ingredients

### **6. Shopping List Integration**
- 🛒 **Auto-Generate**: Creates shopping lists from meal plans
- 📝 **Missing Ingredients**: Identifies what you need to buy
- ➕ **One-Click Add**: Adds ingredients to grocery list
- 📅 **Date Range**: Generate lists for specific periods

## 🏗️ **Technical Architecture**

### **Data Models**

```dart
// Main meal plan for a specific date
class MealPlan {
  String id;
  DateTime date;
  List<PlannedMeal> meals;
  String? notes;
  bool isCompleted;
  List<String>? shoppingList;
}

// Individual meal within a plan
class PlannedMeal {
  String id;
  MealType mealType;
  Recipe? recipe;           // For recipe-based meals
  String? customMealName;   // For custom meals
  DateTime? scheduledTime;
  bool isCooked;
  int? servings;
}

// Meal type enumeration
enum MealType {
  breakfast, lunch, dinner, snack
}
```

### **Service Architecture**

```dart
class MealPlanningService {
  // Core functionality
  Future<void> createMealPlan(DateTime date);
  Future<void> addMealToPlan(DateTime date, MealType type, Recipe recipe);
  Future<void> addCustomMealToPlan(DateTime date, MealType type, String name);
  
  // Smart features
  Future<List<Recipe>> getSuggestionsForMealType(MealType type, List pantry);
  Future<void> generateWeeklyMealPlan(DateTime weekStart, List pantry);
  Future<List<String>> generateShoppingList(DateTime start, DateTime end);
  
  // Management
  Future<void> markMealAsCooked(DateTime date, String mealId);
  Future<void> removeMealFromPlan(DateTime date, String mealId);
}
```

## 📱 **User Interface**

### **Main Planning Screen**
```
┌─────────────────────────────────────┐
│  ← Jan 15 - Jan 21, 2024 →         │
├─────────────────────────────────────┤
│ [Mon] [Tue] [Wed] [Thu] [Fri] [Sat] │
│  15    16    17    18    19    20   │
│  ●●●   ●●○   ●○○   ○○○   ●●●   ●●○  │
├─────────────────────────────────────┤
│           Wednesday, Jan 17          │
│                                     │
│ 🌅 Breakfast                    [+] │
│   • Scrambled Eggs (15 min)     ✓  │
│                                     │
│ ☀️ Lunch                        [+] │
│   • Caesar Salad (10 min)       ○  │
│                                     │
│ 🌙 Dinner                       [+] │
│   (No meals planned)                │
│                                     │
└─────────────────────────────────────┘
```

### **Add Meal Screen**
```
┌─────────────────────────────────────┐
│        Add Meal - Jan 17            │
├─────────────────────────────────────┤
│ [🌅] [☀️] [🌙] [🍎]                │
│ Breakfast  Lunch  Dinner  Snack    │
├─────────────────────────────────────┤
│ [Recipe Suggestions] [Custom Meal]  │
├─────────────────────────────────────┤
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ [Image] Pancakes                │ │
│ │         15 min • Easy           │ │
│ │         [Add to Breakfast]      │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ [Image] French Toast            │ │
│ │         20 min • Medium         │ │
│ │         [Add to Breakfast]      │ │
│ └─────────────────────────────────┘ │
│                                     │
└─────────────────────────────────────┘
```

## 🔄 **User Flow**

### **Planning a Meal**
1. **Open Meal Planning** → Navigate to meal planning screen
2. **Select Date** → Tap on desired day in week view
3. **Choose Meal Type** → Select breakfast, lunch, dinner, or snack
4. **Add Meal** → Choose from suggestions or add custom meal
5. **Confirm** → Meal added to plan with visual confirmation

### **Auto-Generate Weekly Plan**
1. **Tap Auto-Generate** → Access auto-generation feature
2. **Confirm Generation** → System analyzes pantry ingredients
3. **Smart Distribution** → AI distributes recipes across week
4. **Review & Adjust** → User can modify generated plan
5. **Shopping List** → Generate shopping list for missing ingredients

### **Daily Cooking Flow**
1. **View Today's Plan** → See planned meals for current day
2. **Start Cooking** → Tap meal to view recipe details
3. **Mark as Cooked** → Check off completed meals
4. **Track Progress** → Visual indicators show completion

## 💾 **Data Storage**

### **Firestore Structure**
```
users/{userId}/meal_plans/{planId}
├── id: "plan_2024_1_17"
├── date: Timestamp
├── meals: [
│   {
│     id: "meal_1705123456789",
│     mealType: 0, // breakfast
│     recipe: { ... },
│     isCooked: false,
│     servings: 2
│   }
├── ]
├── notes: "Family dinner tonight"
├── isCompleted: false
└── createdAt: Timestamp
```

### **Local Caching (Hive)**
```
meal_plans.hive
├── MealPlan objects with HiveType(typeId: 4)
├── PlannedMeal objects with HiveType(typeId: 5)
└── MealType enum with HiveType(typeId: 6)
```

## 🎯 **Smart Features**

### **Recipe Suggestion Algorithm**
```dart
bool _isRecipeSuitableForMealType(Recipe recipe, MealType mealType) {
  switch (mealType) {
    case MealType.breakfast:
      return tags.contains('breakfast') || 
             title.contains('pancake') ||
             title.contains('omelette');
    
    case MealType.lunch:
      return tags.contains('lunch') ||
             title.contains('salad') ||
             (cookTime <= 30); // Quick meals
    
    case MealType.dinner:
      return tags.contains('dinner') ||
             (cookTime > 20); // Substantial meals
  }
}
```

### **Auto-Generation Logic**
1. **Analyze Pantry** → Get available ingredients
2. **Get Recipe Matches** → Find suitable recipes
3. **Filter by Meal Type** → Separate breakfast, lunch, dinner recipes
4. **Distribute Across Week** → Ensure variety and balance
5. **Avoid Duplicates** → Don't repeat recipes in same week

### **Shopping List Generation**
```dart
Future<List<String>> generateShoppingList(DateTime start, DateTime end) {
  final ingredients = <String>[];
  
  // Collect all ingredients from meal plans in date range
  for (final mealPlan in mealPlansInRange) {
    ingredients.addAll(mealPlan.allIngredients);
  }
  
  // Remove duplicates and return
  return ingredients.toSet().toList();
}
```

## 📊 **Analytics & Insights**

### **Planning Statistics**
- **Completion Rate**: Percentage of planned meals actually cooked
- **Planning Consistency**: How regularly user plans meals
- **Meal Type Distribution**: Breakfast vs lunch vs dinner planning
- **Recipe Variety**: How diverse are planned meals

### **Cooking Insights**
- **Most Planned Recipes**: Which recipes get planned most often
- **Cooking Success Rate**: Planned vs actually cooked
- **Time Preferences**: When user prefers to cook different meal types
- **Ingredient Efficiency**: How well pantry ingredients are utilized

## 🚀 **Future Enhancements**

### **Phase 2 Features**
- **📱 Notifications**: Remind users about planned meals
- **⏰ Cooking Timers**: Set reminders for meal prep times
- **👥 Family Planning**: Share meal plans with family members
- **📈 Nutrition Tracking**: Track calories and nutrients

### **Phase 3 Features**
- **🛒 Grocery Integration**: Connect with grocery delivery services
- **📱 Smart Home**: Integration with smart kitchen appliances
- **🤖 AI Optimization**: Learn user preferences for better suggestions
- **📊 Advanced Analytics**: Detailed cooking and planning insights

## 💰 **Business Value**

### **User Engagement**
- **Increased App Usage**: Daily meal planning drives regular engagement
- **Reduced Churn**: Planning creates commitment to cooking
- **Premium Features**: Advanced planning features for paid users

### **Monetization Opportunities**
- **Premium Planning**: Unlimited meal plans for premium users
- **Smart Suggestions**: AI-powered suggestions for premium
- **Grocery Integration**: Commission from grocery partnerships
- **Meal Kit Integration**: Partner with meal kit services

## 🧪 **Testing Strategy**

### **Unit Tests**
```dart
// Test meal plan creation
test('should create meal plan for specific date', () async {
  final service = MealPlanningService();
  final date = DateTime(2024, 1, 17);
  
  final mealPlan = await service.createMealPlan(date);
  
  expect(mealPlan.date, equals(date));
  expect(mealPlan.meals, isEmpty);
});

// Test recipe suggestions
test('should suggest breakfast recipes for breakfast meal type', () async {
  final suggestions = await service.getSuggestionsForMealType(
    MealType.breakfast, 
    mockPantryItems
  );
  
  expect(suggestions.every((recipe) => 
    recipe.tags?.contains('breakfast') ?? false), isTrue);
});
```

### **Integration Tests**
- **End-to-End Planning**: Complete meal planning flow
- **Auto-Generation**: Weekly plan generation with real data
- **Shopping List**: Generate and verify shopping lists
- **Offline Sync**: Plan meals offline and sync when online

## 📈 **Success Metrics**

### **Adoption Metrics**
- **Planning Rate**: % of users who create meal plans
- **Weekly Planners**: % of users who plan full weeks
- **Plan Completion**: % of planned meals actually cooked

### **Engagement Metrics**
- **Daily Active Users**: Users who check meal plans daily
- **Planning Frequency**: How often users create new plans
- **Feature Usage**: Auto-generation vs manual planning

### **Business Metrics**
- **Premium Conversion**: Planning features driving premium upgrades
- **Retention**: Meal planning impact on user retention
- **Recipe Discovery**: Planning driving recipe exploration

This comprehensive meal planning feature transforms Crave from a simple recipe app into a complete cooking companion that helps users organize their entire culinary week! 🍳📅