import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/journal_entry.dart';
import 'auth_service.dart';

class JournalService extends ChangeNotifier {
  static const String _boxName = 'journal_v1';
  final AuthService _auth = AuthService();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  Box? _box;
  bool _isInitialized = false;

  // Cache of today's entries for UI
  List<JournalEntry> _todayEntries = [];
  List<JournalEntry> get todayEntries => _todayEntries;

  // Computed totals
  int get todayCalories => _todayEntries.fold(0, (sum, e) => sum + e.calories);
  int get todayProtein => _todayEntries.fold(0, (sum, e) => sum + e.protein);
  int get todayCarbs => _todayEntries.fold(0, (sum, e) => sum + e.carbs);
  int get todayFats => _todayEntries.fold(0, (sum, e) => sum + e.fats);

  // Statistics
  int _currentStreak = 0;
  int get currentStreak => _currentStreak;

  int _totalMealsLogged = 0;
  int get totalMealsLogged => _totalMealsLogged;

  int _totalRecipesCooked = 0;
  int get totalRecipesCooked => _totalRecipesCooked;

  /// Initialize Hive box and load initial data
  Future<void> init() async {
    if (_isInitialized) return;
    
    try {
      _box = await Hive.openBox(_boxName);
      _isInitialized = true;
      _loadTodayEntries();
      
      // Trigger background sync if user is logged in
      if (_auth.userId != null) {
        syncPendingEntries();
      }
    } catch (e) {
      debugPrint("❌ JournalService Init Error: $e");
    }
  }

  /// Adds a new entry locally, then attempts sync
  Future<void> addEntry(JournalEntry entry) async {
    if (!_isInitialized) await init();

    // 1. Save to Hive (marked as isSynced=false by default in model if needed, strictly we rely on the object passed)
    // Ensure the entry passed has isSynced=false
    final localEntry = entry.copyWithSynced(false);
    await _box?.put(localEntry.id, localEntry.toMap());
    
    // 2. Update local state immediately
    _loadTodayEntries();
    notifyListeners();

    // 3. Background Sync
    _syncEntryToFirestore(localEntry);
  }

  /// Load entries for the current day from Hive
  void _loadTodayEntries() {
    if (_box == null) return;

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final allMaps = _box!.values.cast<Map<dynamic, dynamic>>();
    
    _todayEntries = allMaps
        .map((m) => JournalEntry.fromMap(m))
        .where((e) => e.timestamp.isAfter(startOfDay) && e.timestamp.isBefore(endOfDay))
        .toList();
        
    // Sort by time descending
    _todayEntries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    // No notifyListeners here to avoid build loops if called during build, 
    // but typically this is called from methods that will notify.
    _calculateStats();
  }

  /// Calculate statistics from all local entries
  void _calculateStats() {
    if (_box == null) return;

    final allMaps = _box!.values.cast<Map<dynamic, dynamic>>();
    final allEntries = allMaps.map((m) => JournalEntry.fromMap(m)).toList();

    // 1. Total Meals
    _totalMealsLogged = allEntries.length;

    // 2. Recipes Cooked
    _totalRecipesCooked = allEntries.where((e) => e.recipeId != null).length;

    // 3. Current Streak
    if (allEntries.isEmpty) {
      _currentStreak = 0;
      return;
    }

    final uniqueDates = allEntries
        .map((e) => DateTime(e.timestamp.year, e.timestamp.month, e.timestamp.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a)); // Descending

    if (uniqueDates.isEmpty) {
      _currentStreak = 0;
      return;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    int streak = 0;
    
    // Check if streak starts today or yesterday
    // If the latest log is before yesterday, streak is broken -> 0
    if (uniqueDates.first.isBefore(yesterday)) {
      _currentStreak = 0;
      return;
    }

    // Start counting
    // We strictly check consecutive days backwards
    DateTime expectedDate = uniqueDates.first;
    
    // If the latest date is Today, we start checking from Today backwards.
    // If the latest date is Yesterday, we start from Yesterday backwards.
    // The previous check ensures we haven't missed more than 1 day.
    
    for (final date in uniqueDates) {
      if (date.year == expectedDate.year && date.month == expectedDate.month && date.day == expectedDate.day) {
        streak++;
        expectedDate = expectedDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    
    _currentStreak = streak;
  }
  
  /// Sync all pending entries
  Future<void> syncPendingEntries() async {
    if (_box == null || _auth.userId == null) return;

    final allMaps = _box!.values.cast<Map<dynamic, dynamic>>();
    final pending = allMaps
        .map((m) => JournalEntry.fromMap(m))
        .where((e) => !e.isSynced)
        .toList();

    if (pending.isEmpty) return;

    debugPrint("🔄 Syncing ${pending.length} pending journal entries...");
    
    for (var entry in pending) {
      await _syncEntryToFirestore(entry);
    }
  }

  /// Sync a single entry to Firestore
  Future<void> _syncEntryToFirestore(JournalEntry entry) async {
    final userId = _auth.userId;
    if (userId == null) return;

    try {
      await _db
          .collection('users')
          .doc(userId)
          .collection('journal')
          .doc(entry.id)
          .set(entry.toFirestoreMap(), SetOptions(merge: true));

      // Mark as synced in Hive
      final syncedEntry = entry.copyWithSynced(true);
      await _box?.put(entry.id, syncedEntry.toMap());
      
      // Update local cache if this entry is in it
      final index = _todayEntries.indexWhere((e) => e.id == entry.id);
      if (index != -1) {
        _todayEntries[index] = syncedEntry;
        notifyListeners(); // Notify that sync status changed
      }
      
      debugPrint("✅ Synced journal entry: ${entry.name}");
    } catch (e) {
      debugPrint("⚠️ Sync failed for ${entry.id}: $e");
      // Will remain unsynced in Hive and retried next time syncPendingEntries is called
    }
  }

  /// Delete entry
  Future<void> deleteEntry(String id) async {
    if (!_isInitialized) await init();
    
    // 1. Delete from Hive
    await _box?.delete(id);
    _loadTodayEntries();
    notifyListeners();

    // 2. Delete from Firestore (Background)
    final userId = _auth.userId;
    if (userId != null) {
      _db.collection('users').doc(userId).collection('journal').doc(id).delete()
         .catchError((e) => debugPrint("❌ Firestore delete failed: $e"));
    }
  }
  
  /// Get entries for specific date (for history view)
  /// This might need to fetch from Firestore if not in Hive
  Future<List<JournalEntry>> getEntriesForDate(DateTime date) async {
    if (!_isInitialized) await init();
    
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    // Valid check: If date is today, return local cache
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return _todayEntries;
    }

    // Try Hive first
    final allMaps = _box!.values.cast<Map<dynamic, dynamic>>();
    final localEntries = allMaps
        .map((m) => JournalEntry.fromMap(m))
        .where((e) => e.timestamp.isAfter(startOfDay) && e.timestamp.isBefore(endOfDay))
        .toList();
        
    if (localEntries.isNotEmpty) {
      return localEntries..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    }

    // Fallback to Firestore
    final userId = _auth.userId;
    if (userId == null) return [];

    try {
      final snapshot = await _db
          .collection('users')
          .doc(userId)
          .collection('journal')
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('timestamp', isLessThan: Timestamp.fromDate(endOfDay))
          .get();

      // We should technically cache these back to Hive if we want true "offline-first" for history,
      // but for MVP we might just return them.
      // Let's cache them to Hive so next time it's fast.
      final fetchedEntries = <JournalEntry>[];
      for (var doc in snapshot.docs) {
        // Map Firestore data back to JournalEntry
        final data = doc.data();
        // Convert Timestamp to map format expected by fromMap (which expects int)
        // Actually fromMap expects a Map, but we need to reconstruct it carefully or add a fromFirestore factory.
        // Let's manually construct for safety.
        final timestamp = (data['timestamp'] as Timestamp).toDate();
        
        final entry = JournalEntry(
          id: doc.id,
          mealType: JournalMealType.values.firstWhere(
             (e) => e.name == data['mealType'], 
             orElse: () => JournalMealType.snack
          ),
          name: data['name'] ?? '',
          calories: data['calories'] ?? 0,
          protein: data['protein'] ?? 0,
          carbs: data['carbs'] ?? 0,
          fats: data['fats'] ?? 0,
          timestamp: timestamp,
          recipeId: data['recipeId'],
          notes: data['notes'],
          isSynced: true,
        );
        
        // Save to Hive
        await _box?.put(entry.id, entry.toMap());
        fetchedEntries.add(entry);
      }
      
      return fetchedEntries..sort((a,b) => b.timestamp.compareTo(a.timestamp));
      
    } catch (e) {
      debugPrint("❌ Error fetching history: $e");
      return [];
    }
  }
}
