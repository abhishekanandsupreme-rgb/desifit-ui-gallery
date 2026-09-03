import 'package:flutter/material.dart';

class MealLog {
  final String id;
  final String title;
  final String slot;
  final double cost;
  final double protein;
  final double calories;
  final double carbs;
  final double fat;
  final DateTime timestamp;
  bool isSynced;

  MealLog({
    required this.id,
    required this.title,
    required this.slot,
    required this.cost,
    required this.protein,
    this.calories = 0.0,
    this.carbs = 0.0,
    this.fat = 0.0,
    DateTime? timestamp,
    this.isSynced = false,
  }) : timestamp = timestamp ?? DateTime.now();
}

class FoodNutrition {
  final String name;
  final String servingSize;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final String category;

  const FoodNutrition({
    required this.name,
    required this.servingSize,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.fiber = 0.0,
    this.category = 'Meal',
  });
}

class RecipeItem {
  final String title;
  final String desc;
  final double cost;
  final double protein;
  final int timeMins;
  final String tag;
  final bool isKettle;
  final List<String> steps;

  RecipeItem({
    required this.title,
    required this.desc,
    required this.cost,
    required this.protein,
    required this.timeMins,
    required this.tag,
    required this.isKettle,
    required this.steps,
  });
}

class ChatMessage {
  final bool isUser;
  final String message;
  final DateTime timestamp;
  final String senderName;

  ChatMessage({
    required this.isUser,
    required this.message,
    required this.timestamp,
    this.senderName = 'Expert',
  });
}

class FitnessStory {
  final String id;
  final String title;
  final String avatarText;
  final List<Color> gradient;
  final String tipTitle;
  final String tipContent;
  bool isRead;

  FitnessStory({
    required this.id,
    required this.title,
    required this.avatarText,
    required this.gradient,
    required this.tipTitle,
    required this.tipContent,
    this.isRead = false,
  });
}

class HealthFlashcard {
  final String id;
  final String myth;
  final String fact;
  final String category;
  bool isFlipped;

  HealthFlashcard({
    required this.id,
    required this.myth,
    required this.fact,
    required this.category,
    this.isFlipped = false,
  });
}

class HealthArticle {
  final String id;
  final String title;
  final String category;
  final String content;
  final int readTimeMins;
  bool isRead;

  HealthArticle({
    required this.id,
    required this.title,
    required this.category,
    required this.content,
    required this.readTimeMins,
    this.isRead = false,
  });
}

class WorkoutItem {
  final String id;
  final String name;
  final String desc;
  final int targetReps;
  final int targetSets;
  final String difficulty;
  final IconData icon;
  final String intensity;
  final String tempo;
  final String targetHeartRateZone;
  final bool isGym;
  final String bodyPart;
  final List<String> splits;
  final String category;
  final double estimatedCalories;

  WorkoutItem({
    required this.id,
    required this.name,
    required this.desc,
    required this.targetReps,
    required this.targetSets,
    required this.difficulty,
    required this.icon,
    required this.intensity,
    required this.tempo,
    required this.targetHeartRateZone,
    required this.isGym,
    required this.bodyPart,
    required this.splits,
    this.category = 'Calisthenics',
    this.estimatedCalories = 45.0,
  });
}

class ProgressPhoto {
  final String id;
  final String imagePath;
  final String dateStr;
  final double bodyFat;
  final int symmetryScore;
  final int vascularity;
  final int postureScore;
  final String feedback;

  ProgressPhoto({
    required this.id,
    required this.imagePath,
    required this.dateStr,
    required this.bodyFat,
    required this.symmetryScore,
    required this.vascularity,
    required this.postureScore,
    required this.feedback,
  });
}

class WorkoutLog {
  final String id;
  final String name;
  final int setsCompleted;
  final int repsCompleted;
  final String difficulty;
  final DateTime timestamp;
  bool isSynced;

  WorkoutLog({
    required this.id,
    required this.name,
    required this.setsCompleted,
    required this.repsCompleted,
    required this.difficulty,
    DateTime? timestamp,
    this.isSynced = false,
  }) : timestamp = timestamp ?? DateTime.now();
}

class ProgressPoint {
  final String dayName;
  final double proteinGrams;
  final double budgetSpent;
  final int workoutsCompleted;

  ProgressPoint({
    required this.dayName,
    required this.proteinGrams,
    required this.budgetSpent,
    required this.workoutsCompleted,
  });
}
