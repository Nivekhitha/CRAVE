import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'nutrition_service.dart';
import '../models/nutrition_snapshot.dart';

class NutritionExportService {
  static final NutritionExportService _instance = NutritionExportService._internal();
  factory NutritionExportService() => _instance;
  NutritionExportService._internal();

  /// Export nutrition data as JSON for healthcare providers
  Future<String> exportAsJSON({
    required NutritionService nutritionService,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final reportData = await nutritionService.exportNutritionReport(
      startDate: startDate,
      endDate: endDate,
    );
    
    return const JsonEncoder.withIndent('  ').convert(reportData);
  }

  /// Generate comprehensive nutrition report for PDF export
  Future<Map<String, dynamic>> generateComprehensiveReport({
    required NutritionService nutritionService,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    startDate ??= DateTime.now().subtract(const Duration(days: 30));
    endDate ??= DateTime.now();
    
    final baseReport = await nutritionService.exportNutritionReport(
      startDate: startDate,
      endDate: endDate,
    );
    
    // Add additional analysis
    final snapshots = baseReport['snapshots'] as List<dynamic>;
    final analysis = _generateNutritionAnalysis(snapshots);
    
    return {
      ...baseReport,
      'analysis': analysis,
      'recommendations': _generateRecommendations(analysis),
      'chartData': _generateChartData(snapshots),
    };
  }

  /// Generate shareable nutrition summary
  String generateShareableSummary(NutritionSnapshot snapshot) {
    final score = snapshot.nutritionScore;
    final calories = snapshot.macros['calories']?.toInt() ?? 0;
    final protein = snapshot.macros['protein']?.toInt() ?? 0;
    final water = snapshot.waterGlasses;
    
    final scoreEmoji = score >= 80 ? '🎯' : score >= 60 ? '⚠️' : '❌';
    
    return '''
🍎 My Nutrition Summary - ${_formatDate(snapshot.date)}

$scoreEmoji Nutrition Score: $score/100
🔥 Calories: $calories
💪 Protein: ${protein}g
💧 Water: $water glasses

${snapshot.insights.isNotEmpty ? '💡 ' + snapshot.insights.first : ''}

#NutritionTracking #HealthyEating #CraveApp
    '''.trim();
  }

  /// Generate nutrition analysis from snapshots
  Map<String, dynamic> _generateNutritionAnalysis(List<dynamic> snapshots) {
    if (snapshots.isEmpty) {
      return {
        'totalDays': 0,
        'averageScore': 0,
        'trends': {},
        'consistency': 0,
      };
    }
    
    final scores = snapshots.map((s) => s['nutritionScore'] as int).toList();
    final calories = snapshots.map((s) => (s['macros']['calories'] as num).toDouble()).toList();
    final protein = snapshots.map((s) => (s['macros']['protein'] as num).toDouble()).toList();
    final water = snapshots.map((s) => s['waterGlasses'] as int).toList();
    
    return {
      'totalDays': snapshots.length,
      'averageScore': scores.reduce((a, b) => a + b) / scores.length,
      'scoreRange': {
        'min': scores.reduce((a, b) => a < b ? a : b),
        'max': scores.reduce((a, b) => a > b ? a : b),
      },
      'trends': {
        'calories': {
          'average': calories.reduce((a, b) => a + b) / calories.length,
          'trend': _calculateTrend(calories),
        },
        'protein': {
          'average': protein.reduce((a, b) => a + b) / protein.length,
          'trend': _calculateTrend(protein),
        },
        'hydration': {
          'average': water.reduce((a, b) => a + b) / water.length,
          'trend': _calculateTrend(water.map((w) => w.toDouble()).toList()),
        },
      },
      'consistency': _calculateConsistency(scores),
      'bestDay': _findBestDay(snapshots),
      'improvementAreas': _identifyImprovementAreas(snapshots),
    };
  }

  /// Generate personalized recommendations
  List<String> _generateRecommendations(Map<String, dynamic> analysis) {
    final recommendations = <String>[];
    final avgScore = analysis['averageScore'] as double;
    final trends = analysis['trends'] as Map<String, dynamic>;
    
    // Score-based recommendations
    if (avgScore < 60) {
      recommendations.add('Focus on meeting your daily nutrition goals consistently');
    } else if (avgScore < 80) {
      recommendations.add('You\'re doing well! Fine-tune your nutrition for optimal health');
    } else {
      recommendations.add('Excellent nutrition habits! Maintain this consistency');
    }
    
    // Trend-based recommendations
    final caloriesTrend = trends['calories']['trend'] as String;
    if (caloriesTrend == 'increasing') {
      recommendations.add('Monitor portion sizes to maintain calorie balance');
    } else if (caloriesTrend == 'decreasing') {
      recommendations.add('Ensure you\'re eating enough to meet your energy needs');
    }
    
    final proteinTrend = trends['protein']['trend'] as String;
    if (proteinTrend == 'decreasing') {
      recommendations.add('Include more protein-rich foods like lean meats, eggs, or legumes');
    }
    
    final hydrationTrend = trends['hydration']['trend'] as String;
    if (hydrationTrend == 'decreasing') {
      recommendations.add('Set reminders to drink water throughout the day');
    }
    
    return recommendations;
  }

  /// Generate chart data for visualization
  Map<String, dynamic> _generateChartData(List<dynamic> snapshots) {
    final dates = <String>[];
    final scores = <int>[];
    final calories = <double>[];
    final protein = <double>[];
    final water = <int>[];
    
    for (final snapshot in snapshots) {
      dates.add(snapshot['date'] as String);
      scores.add(snapshot['nutritionScore'] as int);
      calories.add((snapshot['macros']['calories'] as num).toDouble());
      protein.add((snapshot['macros']['protein'] as num).toDouble());
      water.add(snapshot['waterGlasses'] as int);
    }
    
    return {
      'dates': dates,
      'nutritionScores': scores,
      'calories': calories,
      'protein': protein,
      'hydration': water,
    };
  }

  /// Calculate trend direction
  String _calculateTrend(List<double> values) {
    if (values.length < 2) return 'stable';
    
    final firstHalf = values.take(values.length ~/ 2).toList();
    final secondHalf = values.skip(values.length ~/ 2).toList();
    
    final firstAvg = firstHalf.reduce((a, b) => a + b) / firstHalf.length;
    final secondAvg = secondHalf.reduce((a, b) => a + b) / secondHalf.length;
    
    final difference = secondAvg - firstAvg;
    
    if (difference > firstAvg * 0.05) return 'increasing';
    if (difference < -firstAvg * 0.05) return 'decreasing';
    return 'stable';
  }

  /// Calculate consistency score
  double _calculateConsistency(List<int> scores) {
    if (scores.length < 2) return 100.0;
    
    final mean = scores.reduce((a, b) => a + b) / scores.length;
    final variance = scores.map((s) => (s - mean) * (s - mean)).reduce((a, b) => a + b) / scores.length;
    final standardDeviation = math.sqrt(variance);
    
    // Lower standard deviation = higher consistency
    return (100 - (standardDeviation / mean * 100)).clamp(0, 100);
  }

  /// Find the best performing day
  Map<String, dynamic> _findBestDay(List<dynamic> snapshots) {
    if (snapshots.isEmpty) return {};
    
    final bestSnapshot = snapshots.reduce((a, b) => 
      (a['nutritionScore'] as int) > (b['nutritionScore'] as int) ? a : b
    );
    
    return {
      'date': bestSnapshot['date'],
      'score': bestSnapshot['nutritionScore'],
      'insights': bestSnapshot['insights'],
    };
  }

  /// Identify areas for improvement
  List<String> _identifyImprovementAreas(List<dynamic> snapshots) {
    final areas = <String>[];
    
    // Analyze average progress across all snapshots
    final avgProgress = <String, double>{};
    
    for (final snapshot in snapshots) {
      final progress = snapshot['progress'] as Map<String, dynamic>;
      progress.forEach((key, value) {
        avgProgress[key] = (avgProgress[key] ?? 0) + (value as num).toDouble();
      });
    }
    
    avgProgress.updateAll((key, value) => value / snapshots.length);
    
    // Identify consistently low areas
    avgProgress.forEach((nutrient, avgValue) {
      if (avgValue < 70) {
        switch (nutrient) {
          case 'fiber':
            areas.add('Increase fiber intake with more fruits and vegetables');
            break;
          case 'water':
            areas.add('Improve hydration by drinking more water');
            break;
          case 'protein':
            areas.add('Add more protein-rich foods to your meals');
            break;
          case 'vitaminC':
            areas.add('Include more citrus fruits and leafy greens');
            break;
          case 'iron':
            areas.add('Consider iron-rich foods like spinach and lean meats');
            break;
        }
      }
    });
    
    return areas;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// Add missing import
import 'dart:math' as math;