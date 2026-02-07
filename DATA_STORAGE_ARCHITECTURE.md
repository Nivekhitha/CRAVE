# Crave App - Data Storage Architecture

## 🏗️ Storage Methodology: Hybrid Cloud-Local Architecture

### **Primary Storage Strategy: Firebase + Hive Hybrid**

```
┌─────────────────────────────────────────────────────────────┐
│                    CRAVE DATA ARCHITECTURE                  │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────┐    ┌─────────────────┐                │
│  │   CLOUD LAYER   │    │   LOCAL LAYER   │                │
│  │   (Firebase)    │◄──►│     (Hive)      │                │
│  └─────────────────┘    └─────────────────┘                │
│                                                             │
│  • Real-time sync       • Offline access                   │
│  • Multi-device         • Fast queries                     │
│  • Backup & restore     • Local caching                    │
│  • Collaboration        • Performance                      │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## 📊 **Data Storage Breakdown**

### **1. CLOUD STORAGE (Firebase Firestore)**
**Purpose**: Primary source of truth, real-time sync, multi-device access

#### **Collections Structure:**
```
firestore/
├── users/
│   └── {userId}/
│       ├── profile: {username, country, email, isPremium, createdAt}
│       ├── pantry/
│       │   └── {itemId}: {name, category, quantity, addedDate}
│       ├── grocery_list/
│       │   └── {itemId}: {name, category, quantity, isChecked, addedDate}
│       └── recipes/ (user-created)
│           └── {recipeId}: {title, ingredients, instructions, ...}
│
├── recipes/ (global/public recipes)
│   └── {recipeId}: {
│       title, ingredients, instructions, cookTime, 
│       difficulty, tags, source, isPremium, createdAt
│   }
│
├── cookbook_cache/ (PDF extraction cache)
│   └── {sha256Hash}: {
│       hash, recipes[], extractedAt, fileSize
│   }
│
└── analytics/ (usage tracking)
    └── {userId}: {
        videoExtractions: {month: count},
        recipesCooked, lastActive, features_used
    }
```

#### **Why Firebase Firestore?**
- ✅ **Real-time synchronization** across devices
- ✅ **Offline persistence** built-in
- ✅ **Scalable** (handles millions of users)
- ✅ **Security rules** for data protection
- ✅ **Automatic backups**
- ✅ **Multi-platform** (iOS, Android, Web)

### **2. LOCAL STORAGE (Hive)**
**Purpose**: Fast local access, offline functionality, caching

#### **Hive Boxes Structure:**
```
hive_boxes/
├── recipes.hive          # Recipe objects with TypeAdapter
├── user_profile.hive     # User settings and preferences
├── pantry_cache.hive     # Local pantry for offline access
├── grocery_cache.hive    # Local grocery list cache
├── recipe_matches.hive   # Cached recipe matches
└── app_settings.hive     # App preferences, theme, etc.
```

#### **Why Hive?**
- ✅ **Lightning fast** (NoSQL key-value store)
- ✅ **Type-safe** with code generation
- ✅ **Minimal storage** (efficient binary format)
- ✅ **Offline-first** capability
- ✅ **Flutter optimized**

## 🔄 **Data Synchronization Strategy**

### **Sync Flow:**
```
User Action → Local Update → Cloud Sync → Other Devices
     ↓              ↓            ↓            ↓
  Instant UI    Hive Cache   Firestore    Real-time
   Response      Update       Update       Updates
```

### **Implementation:**
```dart
// 1. Optimistic Updates (UI responds instantly)
await _updateLocalCache(data);
notifyListeners(); // UI updates immediately

// 2. Cloud Sync (background)
try {
  await _firestore.updateData(data);
} catch (e) {
  // Rollback local changes if cloud sync fails
  await _rollbackLocalCache(data);
  _showErrorToUser(e);
}
```

## 📱 **Offline-First Architecture**

### **Offline Capabilities:**
- ✅ **Browse recipes** (cached locally)
- ✅ **Add/remove pantry items** (syncs when online)
- ✅ **View recipe matches** (uses local data)
- ✅ **Create grocery lists** (local storage)
- ❌ **AI recipe extraction** (requires internet)
- ❌ **Video recipe parsing** (requires internet)

### **Offline Strategy:**
```dart
class OfflineFirstService {
  // Always try local first
  Future<List<Recipe>> getRecipes() async {
    try {
      // 1. Return cached data immediately
      final localRecipes = await _hive.getRecipes();
      
      // 2. Fetch fresh data in background
      _fetchFreshDataInBackground();
      
      return localRecipes;
    } catch (e) {
      // 3. Fallback to cloud if local fails
      return await _firestore.getRecipes();
    }
  }
}
```

## 🔐 **Data Security & Privacy**

### **Security Measures:**
```javascript
// Firestore Security Rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null 
                        && request.auth.uid == userId;
    }
    
    // Public recipes are read-only for all users
    match /recipes/{recipeId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    // Cache is protected
    match /cookbook_cache/{hash} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### **Data Encryption:**
- 🔒 **In-transit**: HTTPS/TLS encryption
- 🔒 **At-rest**: Firebase automatic encryption
- 🔒 **Local**: Hive encryption (optional)
- 🔒 **API Keys**: Environment variables (.env)

## 📈 **Performance Optimizations**

### **1. Caching Strategy:**
```dart
class CacheStrategy {
  // Recipe matching results cached for 5 minutes
  static const MATCH_CACHE_DURATION = Duration(minutes: 5);
  
  // PDF extraction cached permanently (by hash)
  static const PDF_CACHE_DURATION = Duration.infinity;
  
  // User data cached for 1 hour
  static const USER_CACHE_DURATION = Duration(hours: 1);
}
```

### **2. Query Optimization:**
```dart
// Efficient Firestore queries
Stream<QuerySnapshot> getRecipesOptimized() {
  return _firestore
    .collection('recipes')
    .where('isPublic', isEqualTo: true)
    .orderBy('createdAt', descending: true)
    .limit(50) // Limit for performance
    .snapshots();
}
```

### **3. Lazy Loading:**
```dart
// Load recipe details only when needed
class RecipeCard extends StatelessWidget {
  final String recipeId;
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Recipe>(
      future: _loadRecipeWhenVisible(recipeId),
      builder: (context, snapshot) {
        // Show placeholder until loaded
      },
    );
  }
}
```

## 🔄 **Data Migration Strategy**

### **Version Management:**
```dart
class MigrationService {
  static const CURRENT_VERSION = 3;
  
  Future<void> migrateIfNeeded() async {
    final currentVersion = await _getStoredVersion();
    
    if (currentVersion < CURRENT_VERSION) {
      await _runMigrations(currentVersion, CURRENT_VERSION);
    }
  }
  
  Future<void> _runMigrations(int from, int to) async {
    for (int version = from + 1; version <= to; version++) {
      switch (version) {
        case 2:
          await _migrateToV2(); // Add recipe categories
          break;
        case 3:
          await _migrateToV3(); // Add premium features
          break;
      }
    }
  }
}
```

## 📊 **Data Analytics & Monitoring**

### **Usage Tracking:**
```dart
class AnalyticsService {
  // Track user behavior for app improvement
  void trackRecipeMatch(String recipeId, double matchPercentage) {
    _firestore.collection('analytics').add({
      'userId': _auth.currentUser?.uid,
      'action': 'recipe_match',
      'recipeId': recipeId,
      'matchPercentage': matchPercentage,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
  
  void trackIngredientAdded(String ingredient) {
    // Track popular ingredients for better suggestions
  }
}
```

## 🚀 **Scalability Considerations**

### **Current Capacity:**
- **Users**: Unlimited (Firebase scales automatically)
- **Recipes**: 1M+ recipes (with pagination)
- **Pantry Items**: 1000 per user (reasonable limit)
- **Recipe Matches**: Calculated in real-time (no storage limit)

### **Future Scaling:**
```dart
// Implement sharding for large datasets
class ScalableRecipeService {
  // Shard recipes by cuisine type
  Stream<List<Recipe>> getRecipesByCuisine(String cuisine) {
    return _firestore
      .collection('recipes_${cuisine.toLowerCase()}')
      .snapshots();
  }
  
  // Use Cloud Functions for heavy computations
  Future<List<RecipeMatch>> getAIMatches(List<String> ingredients) {
    return _cloudFunctions.httpsCallable('calculateMatches')({
      'ingredients': ingredients,
      'userId': _auth.currentUser?.uid,
    });
  }
}
```

## 💰 **Cost Optimization**

### **Firebase Costs (Estimated for 10K users):**
- **Firestore Reads**: ~$1.50/month (cached locally)
- **Firestore Writes**: ~$3.00/month (user actions)
- **Storage**: ~$0.50/month (recipes + user data)
- **Bandwidth**: ~$2.00/month (image downloads)
- **Total**: ~$7/month for 10K active users

### **Cost Reduction Strategies:**
- ✅ **Local caching** reduces read operations
- ✅ **Batch writes** reduce write costs
- ✅ **Image optimization** reduces bandwidth
- ✅ **Query limits** prevent expensive operations

## 🔧 **Development & Testing**

### **Data Seeding:**
```dart
class SeedDataService {
  Future<void> seedForDevelopment() async {
    if (kDebugMode) {
      await _seedTestRecipes();
      await _seedTestUsers();
      await _seedTestPantryItems();
    }
  }
}
```

### **Testing Strategy:**
```dart
// Mock services for unit testing
class MockFirestoreService implements FirestoreService {
  final Map<String, dynamic> _mockData = {};
  
  @override
  Future<void> addPantryItem(Map<String, dynamic> item) async {
    _mockData['pantry'] ??= [];
    _mockData['pantry'].add(item);
  }
}
```

## 📋 **Data Backup & Recovery**

### **Automatic Backups:**
- ✅ **Firebase**: Automatic daily backups
- ✅ **User Export**: Users can export their data
- ✅ **Cloud Storage**: Recipe images backed up
- ✅ **Version History**: Firestore keeps change history

### **Recovery Strategy:**
```dart
class BackupService {
  Future<void> exportUserData(String userId) async {
    final userData = await _firestore.exportUserData(userId);
    final jsonData = jsonEncode(userData);
    
    // Save to device or cloud storage
    await _saveToFile('crave_backup_$userId.json', jsonData);
  }
  
  Future<void> importUserData(String jsonData) async {
    final userData = jsonDecode(jsonData);
    await _firestore.importUserData(userData);
  }
}
```

## 🎯 **Summary**

### **Storage Methodology Benefits:**
1. **🚀 Performance**: Local-first with cloud sync
2. **📱 Offline Support**: Works without internet
3. **🔄 Real-time**: Instant updates across devices
4. **🔐 Secure**: Enterprise-grade security
5. **💰 Cost-effective**: Optimized for scale
6. **🛠️ Maintainable**: Clean architecture
7. **📈 Scalable**: Handles growth automatically

This hybrid approach gives you the best of both worlds: the speed and reliability of local storage with the synchronization and backup benefits of cloud storage.