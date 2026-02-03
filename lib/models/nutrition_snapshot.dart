import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'nutrition_snapshot.g.dart';

@HiveType(typeId: 3)
class NutritionSnapshot extends HiveObject {
  @HiveField(0)
  late DateTime date;

  @HiveField(1)
  late Map<String, double> macros; // calories, protein, carbs, fats, fiber

  @HiveField(2)
  late Map<String, double> vitamins; // A, C, D, E, K, B-complex

  @HiveField(3)
  late Map<String, double> minerals; // Iron, Calcium, Zinc, etc.

  @HiveField(4)
  late Map<String, double> goals; // personalized daily targets

  @HiveField(5)
  late Map<String, double> progress; // percentage of goals achieved

  @HiveField(6)
  late int nutritionScore; // 0-100 overall score

  @HiveField(7)
  late List<String> insights; // AI-generated recommendations

  @HiveField(8)
  late int waterGlasses; // hydration tracking

  @HiveField(9)
  late double averageGlycemicIndex; // blood sugar impact

  @HiveField(10)
  DateTime? lastUpdated;

  NutritionSnapshot({
    required this.date,
    required this.macros,
    required this.vitamins,
    required this.minerals,
    required this.goals,
    required this.progress,
    required this.nutritionScore,
    required this.insights,
    required this.waterGlasses,
    required this.averageGlycemicIndex,
    this.lastUpdated,
  });

  // Calculate nutrition score based on goal achievement
  static int calculateNutritionScore(Map<String, double> progress) {
    double totalScore = 0;
    int count = 0;
    
    for (final key in ['calories', 'protein', 'carbs', 'fats', 'fiber']) {
      final progressValue = progress[key] ?? 0;
      // Perfect score at 100%, decreasing as you go over or under
      final score = progressValue <= 100 
        ? progressValue 
        : 100 - (progressValue - 100).clamp(0, 50);
      
      totalScore += score;
      count++;
    }
    
    return count > 0 ? (totalScore / count).round() : 0;
  }
  // Generate AI insights based on nutrition data
  static List<String> generateInsights(
    Map<String, double> progress,
    Map<String, double> macros,
    int waterGlasses,
  ) {
    final insights = <String>[];
    
    // Protein insights
    final proteinProgress = progress['protein'] ?? 0;
    if (proteinProgress >= 95) {
      insights.add('🎯 Excellent protein intake! You\'re building strong muscles.');
    } else if (proteinProgress < 70) {
      insights.add('💪 Try adding Greek yogurt or lean meat to boost protein.');
    }
    
    // Hydration insights
    if (waterGlasses >= 8) {
      insights.add('💧 Great hydration! Your body is well-hydrated.');
    } else if (waterGlasses < 6) {
      insights.add('💧 Drink ${8 - waterGlasses} more glasses of water today.');
    }
    
    // Fiber insights
    final fiberProgress = progress['fiber'] ?? 0;
    if (fiberProgress < 60) {
      insights.add('🥬 Add more vegetables and fruits for better fiber intake.');
    }
    
    // Calorie insights
    final calorieProgress = progress['calories'] ?? 0;
    if (calorieProgress > 120) {
      insights.add('⚠️ You\'re over your calorie goal. Consider lighter meals.');
    } else if (calorieProgress < 80) {
      insights.add('🍽️ You might need more calories to meet your energy needs.');
    }
    
    return insights;
  }

  // Convert to Firestore format
  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'macros': macros,
      'vitamins': vitamins,
      'minerals': minerals,
      'goals': goals,
      'progress': progress,
      'nutritionScore': nutritionScore,
      'insights': insights,
      'waterGlasses': waterGlasses,
      'averageGlycemicIndex': averageGlycemicIndex,
      'lastUpdated': lastUpdated != null ? Timestamp.fromDate(lastUpdated!) : null,
    };
  }

  // Create from Firestore data
  factory NutritionSnapshot.fromMap(Map<String, dynamic> map) {
    return NutritionSnapshot(
      date: (map['date'] as Timestamp).toDate(),
      macros: Map<String, double>.from(map['macros'] ?? {}),
      vitamins: Map<String, double>.from(map['vitamins'] ?? {}),
      minerals: Map<String, double>.from(map['minerals'] ?? {}),
      goals: Map<String, double>.from(map['goals'] ?? {}),
      progress: Map<String, double>.from(map['progress'] ?? {}),
      nutritionScore: map['nutritionScore'] ?? 0,
      insights: List<String>.from(map['insights'] ?? []),
      waterGlasses: map['waterGlasses'] ?? 0,
      averageGlycemicIndex: map['averageGlycemicIndex']?.toDouble() ?? 0.0,
      lastUpdated: map['lastUpdated'] != null 
        ? (map['lastUpdated'] as Timestamp).toDate() 
        : null,
    );
  }

  @override
  String toString() => 'NutritionSnapshot(date: $date, score: $nutritionScore)';
}