# 🍳 How Recipe Matching & Suggestions Work

## Overview
The Crave app uses an intelligent matching system to suggest recipes based on ingredients you have in your fridge.

---

## 📊 The Matching Algorithm

### Step-by-Step Process:

```
1. USER ADDS INGREDIENTS
   ↓
2. STORED IN FIRESTORE
   ↓
3. SYSTEM LOADS ALL RECIPES
   ↓
4. MATCHING SERVICE COMPARES
   ↓
5. CALCULATES MATCH %
   ↓
6. DISPLAYS SUGGESTIONS
```

### Match Percentage Formula:

```
Match % = (Ingredients You Have / Total Recipe Ingredients) × 100
```

### Example:

**Recipe: Tomato Omelette**
- Needs: Eggs, Tomatoes, Salt, Pepper (4 ingredients)
- You have: Eggs, Tomatoes, Salt (3 ingredients)
- **Match = 3/4 × 100 = 75%**

---

## 🎯 Match Categories

| Match % | Badge Color | Meaning |
|---------|-------------|---------|
| 80-100% | 🟢 Green | You can make this now! |
| 60-79% | 🟠 Orange | Need 1-2 more ingredients |
| 0-59% | 🔴 Red | Need several ingredients |

---

## 🔄 How It Works in Real-Time

### 1. **Adding Ingredients**
```
You add "Eggs" to pantry
   ↓
Saved to Firestore
   ↓
UserProvider updates pantryList
   ↓
RecipeMatchingService recalculates
   ↓
Suggestions update automatically
```

### 2. **Removing Ingredients**
```
You remove "Milk" from pantry
   ↓
Deleted from Firestore
   ↓
UserProvider updates pantryList
   ↓
Match percentages recalculate
   ↓
Suggestions update (some may disappear)
```

### 3. **Quantity Changes**
```
You change Eggs from 1 → 6
   ↓
Updated in Firestore
   ↓
Quantity tracked but doesn't affect matching
   ↓
(Future: Could enable "batch cooking" suggestions)
```

---

## 🏗️ System Architecture

### Data Flow:

```
┌─────────────────┐
│  Pantry Screen  │ ← User adds/removes ingredients
└────────┬────────┘
         │
         ↓
┌─────────────────┐
│  UserProvider   │ ← State management
└────────┬────────┘
         │
         ↓
┌─────────────────┐
│   Firestore     │ ← Cloud storage
└────────┬────────┘
         │
         ↓
┌─────────────────┐
│ Recipe Matching │ ← Algorithm runs
│    Service      │
└────────┬────────┘
         │
         ↓
┌─────────────────┐
│   Home Screen   │ ← Shows "Today's Picks"
│ Discovery Screen│ ← Shows suggestions
└─────────────────┘
```

---

## 📱 Enhanced Pantry Features

### ✅ What You Can Do Now:

1. **Add Ingredients**
   - Type in search bar
   - Press Enter or tap + icon
   - Or use Quick Add chips

2. **Adjust Quantity**
   - Tap - button to decrease
   - Tap + button to increase
   - Range: 1-99 items

3. **Delete Ingredients**
   - Tap delete icon (with confirmation)
   - Or swipe left to delete

4. **Filter by Category**
   - All, Vegetables, Proteins, Dairy, Other
   - Quick access to specific types

5. **Search**
   - Type to filter existing items
   - Type new item to add it

---

## 🧠 Smart Features

### 1. **Category Auto-Detection**
When you add an ingredient, the system automatically assigns a category:

```dart
"Milk" → Dairy
"Chicken" → Proteins
"Tomato" → Vegetables
"Rice" → Other
```

### 2. **Duplicate Prevention**
- Can't add the same ingredient twice
- System checks before adding

### 3. **Real-Time Sync**
- Changes sync to Firestore immediately
- Works offline (syncs when back online)
- Multiple devices stay in sync

### 4. **Quick Add Suggestions**
Common ingredients appear as chips:
- Milk, Eggs, Bread, Butter, Cheese
- Onion, Tomato, Potato
- Chicken, Rice

---

## 🎨 UI/UX Features

### Visual Feedback:
- ✅ Green badges for high matches
- 🟠 Orange badges for medium matches
- 🔴 Red badges for low matches
- 📊 Match percentage displayed
- 🔢 Quantity controls visible
- 🗑️ Delete with confirmation

### Notifications:
- All alerts appear at **TOP** of screen
- Success messages in green
- Error messages in red
- Auto-dismiss after 2 seconds

---

## 📈 Future Enhancements

### Planned Features:
1. **Expiry Date Tracking**
   - Add expiry dates to ingredients
   - Get alerts before items expire
   - Prioritize recipes using expiring items

2. **Shopping List Integration**
   - Missing ingredients → Add to grocery list
   - One-tap add from recipe detail

3. **Batch Cooking**
   - Suggest recipes based on quantity
   - "You have 6 eggs → Make a cake!"

4. **Nutrition-Based Matching**
   - Filter by dietary preferences
   - Match based on nutrition goals

5. **AI Suggestions**
   - "You often cook Italian → Try this pasta!"
   - Learn from your cooking history

---

## 🔧 Technical Details

### Files Involved:

| File | Purpose |
|------|---------|
| `pantry_screen.dart` | UI for managing ingredients |
| `user_provider.dart` | State management |
| `firestore_service.dart` | Database operations |
| `recipe_matching_service.dart` | Matching algorithm |
| `home_screen.dart` | Displays "Today's Picks" |
| `discovery_screen.dart` | Shows all suggestions |

### Key Methods:

```dart
// Add ingredient
userProvider.addPantryItem({
  'name': 'Eggs',
  'category': 'Proteins',
  'quantity': '6',
});

// Update quantity
userProvider.addPantryItem({
  ...existingItem,
  'quantity': newQuantity,
});

// Delete ingredient
userProvider.deletePantryItem(itemId);

// Get matches
final matches = userProvider.recipeMatches;
```

---

## 💡 Tips for Best Results

### 1. **Be Specific**
- ✅ "Cherry Tomatoes" (better)
- ❌ "Tomatoes" (generic)

### 2. **Keep Updated**
- Remove ingredients when used
- Update quantities regularly

### 3. **Use Categories**
- Helps with filtering
- Better organization

### 4. **Add Common Staples**
- Salt, Pepper, Oil
- These appear in many recipes

### 5. **Check Suggestions Daily**
- New recipes added regularly
- Matches update in real-time

---

## 🐛 Troubleshooting

### No Suggestions Showing?
1. Check if you have ingredients added
2. Try adding more common ingredients
3. Check if recipes exist in database

### Match Percentage Seems Wrong?
- System matches by ingredient name
- "Tomato" ≠ "Cherry Tomatoes"
- Be consistent with naming

### Quantity Not Updating?
- Check internet connection
- Wait a moment for Firestore sync
- Pull to refresh

---

## 📊 Example Scenarios

### Scenario 1: Morning Breakfast
```
You have: Eggs, Milk, Bread
Suggestions:
- French Toast (100% match)
- Scrambled Eggs (100% match)
- Omelette (75% match - needs cheese)
```

### Scenario 2: Quick Lunch
```
You have: Chicken, Rice, Onion, Tomato
Suggestions:
- Chicken Fried Rice (100% match)
- Chicken Curry (80% match - needs spices)
- Tomato Rice (75% match)
```

### Scenario 3: Dinner Planning
```
You have: Pasta, Tomatoes, Garlic, Olive Oil
Suggestions:
- Aglio e Olio (100% match)
- Tomato Pasta (100% match)
- Carbonara (60% match - needs eggs, bacon)
```

---

## 🎯 Success Metrics

The system is working well when:
- ✅ You see 3-5 high-match recipes daily
- ✅ Suggestions update when you add/remove items
- ✅ Match percentages are accurate
- ✅ You can make at least 1 recipe without shopping

---

**Last Updated:** February 6, 2026
**Version:** 1.0
**Status:** Production Ready ✅
