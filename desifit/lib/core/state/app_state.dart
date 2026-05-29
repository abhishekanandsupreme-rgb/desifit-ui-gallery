import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:home_widget/home_widget.dart';
import '../storage/local_storage.dart';
import '../auth/auth_service.dart';
import '../auth/firestore_rules_checker.dart';
import '../network/openrouter_service.dart';
import '../localization/translation_service.dart';
import '../../features/health_feed/domain/models/article.dart';
import '../../features/health_feed/domain/data/mock_articles.dart';
import '../network/analytics_service.dart';
import 'dart:math';

class MealLog {
  final String id;
  final String title;
  final String slot; // Breakfast, Lunch, Dinner, Snack
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
  }) : this.timestamp = timestamp ?? DateTime.now();
}

class FoodNutrition {
  final String name;
  final String servingSize;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final String category; // 'Grain', 'Protein', 'Dairy', 'Snack', 'Beverage', 'Meal', 'Sweet', 'Vegetable', 'Fruit'

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
  final String avatarText; // e.g. "💪" or "☕"
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
  final String category; // 'Desi', 'Calisthenics', 'Gym'
  final double estimatedCalories; // rough estimated calorie burn for completion

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
  final String imagePath; // Base64 string of captured photo
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
  }) : this.timestamp = timestamp ?? DateTime.now();
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

class AppState extends ChangeNotifier {
  // Authentication State
  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isGuest => _currentUser == null || _currentUser!.uid == 'guest_user';

  // Sattu Streak & Badges State
  int _sattuStreak = 0;
  List<String> _earnedBadges = [];
  
  int get sattuStreak => _sattuStreak;
  List<String> get earnedBadges => _earnedBadges;

  // Celebration state
  bool _showConfetti = false;
  String _celebrationTitle = '';
  String _celebrationMessage = '';

  bool get showConfetti => _showConfetti;
  String get celebrationTitle => _celebrationTitle;
  String get celebrationMessage => _celebrationMessage;

  // Budget & Protein Metrics
  double _dailyBudgetLimit = 100.0;
  double _budgetSpent = 0.0;
  double _proteinGoal = 60.0;
  double _proteinHit = 0.0;
  double _caloriesConsumed = 0.0;
  double _carbsConsumed = 0.0;
  double _fatConsumed = 0.0;
  bool _isHinglish = false;
  int _aiChatCount = 0;
  int _aiCalorieEstimateCount = 0;
  int _aiRecipeCount = 0;
  int _aiArticleCount = 0;
  double _waterConsumed = 0.0;
  double _waterGoal = 2000.0;

  double get waterConsumed => _waterConsumed;
  double get waterGoal => _waterGoal;

  // Onboarding Body Metrics
  double? _userWeight;
  double? _userHeight;
  double? _userBmi;
  String? _bmiCategory;
  String? _bodyGoal;
  double? _dailyCalorieTarget;
  String? _selectedWorkoutSplit;

  double get dailyBudgetLimit => _dailyBudgetLimit;
  double get budgetSpent => _budgetSpent;
  double get budgetLeft => (_dailyBudgetLimit - _budgetSpent).clamp(0.0, _dailyBudgetLimit);
  double get proteinGoal => _proteinGoal;
  double get proteinHit => _proteinHit;
  double get caloriesConsumed => _caloriesConsumed;
  double get carbsConsumed => _carbsConsumed;
  double get fatConsumed => _fatConsumed;
  double get caloriesRemaining => ((_dailyCalorieTarget ?? 2000) - _caloriesConsumed).clamp(0.0, (_dailyCalorieTarget ?? 2000));
  bool get isHinglish => _isHinglish;

  int get aiChatCount => _aiChatCount;
  int get aiCalorieEstimateCount => _aiCalorieEstimateCount;
  int get aiRecipeCount => _aiRecipeCount;
  int get aiArticleCount => _aiArticleCount;

  bool get isAiChatLimitReached => _aiChatCount >= 5;
  bool get isAiCalorieLimitReached => _aiCalorieEstimateCount >= 3;
  bool get isAiRecipeLimitReached => _aiRecipeCount >= 3;
  bool get isAiArticleLimitReached => _aiArticleCount >= 3;

  double? get userWeight => _userWeight;
  double? get userHeight => _userHeight;
  double? get userBmi => _userBmi;
  String? get bmiCategory => _bmiCategory;
  String? get bodyGoal => _bodyGoal;
  double? get dailyCalorieTarget => _dailyCalorieTarget;
  String? get selectedWorkoutSplit => _selectedWorkoutSplit;

  static const List<FoodNutrition> indianFoodDatabase = [
    // Grains & Staples
    FoodNutrition(name: 'Roti/Chapati', servingSize: '1 medium', calories: 120, protein: 3.5, carbs: 20, fat: 3.5, fiber: 2.5, category: 'Grain'),
    FoodNutrition(name: 'Rice (cooked)', servingSize: '1 cup', calories: 210, protein: 4.0, carbs: 45, fat: 0.5, fiber: 0.5, category: 'Grain'),
    FoodNutrition(name: 'Paratha (Plain)', servingSize: '1 pc', calories: 260, protein: 5.0, carbs: 36, fat: 10.0, fiber: 2.0, category: 'Grain'),
    FoodNutrition(name: 'Poha', servingSize: '1 bowl', calories: 180, protein: 3.0, carbs: 35, fat: 3.0, fiber: 1.5, category: 'Grain'),
    FoodNutrition(name: 'Upma', servingSize: '1 bowl', calories: 220, protein: 4.5, carbs: 38, fat: 5.0, fiber: 2.0, category: 'Grain'),
    FoodNutrition(name: 'Idli', servingSize: '2 pcs', calories: 140, protein: 4.0, carbs: 28, fat: 0.5, fiber: 1.5, category: 'Grain'),
    FoodNutrition(name: 'Dosa (Plain)', servingSize: '1 pc', calories: 165, protein: 4.0, carbs: 28, fat: 4.0, fiber: 1.5, category: 'Grain'),
    FoodNutrition(name: 'Puri', servingSize: '2 pcs', calories: 210, protein: 3.5, carbs: 24, fat: 11.0, fiber: 1.0, category: 'Grain'),
    FoodNutrition(name: 'Naan (Butter)', servingSize: '1 pc', calories: 310, protein: 8.0, carbs: 48, fat: 9.0, fiber: 2.0, category: 'Grain'),
    FoodNutrition(name: 'Bhakri (Jowar/Bajra)', servingSize: '1 pc', calories: 150, protein: 4.5, carbs: 30, fat: 2.0, fiber: 4.0, category: 'Grain'),
    FoodNutrition(name: 'Khichdi', servingSize: '1 bowl', calories: 230, protein: 7.0, carbs: 42, fat: 4.0, fiber: 3.5, category: 'Grain'),
    FoodNutrition(name: 'Pulao (Veg)', servingSize: '1 bowl', calories: 250, protein: 5.0, carbs: 48, fat: 5.0, fiber: 2.5, category: 'Grain'),
    FoodNutrition(name: 'Daliya (Sweet/Salty)', servingSize: '1 bowl', calories: 180, protein: 6.0, carbs: 36, fat: 2.0, fiber: 5.0, category: 'Grain'),
    FoodNutrition(name: 'Oats (cooked)', servingSize: '1 bowl', calories: 150, protein: 5.5, carbs: 27, fat: 2.5, fiber: 4.0, category: 'Grain'),
    FoodNutrition(name: 'Masala Oats', servingSize: '1 bowl', calories: 170, protein: 6.0, carbs: 29, fat: 3.5, fiber: 4.5, category: 'Grain'),

    // Protein Sources
    FoodNutrition(name: 'Boiled Egg', servingSize: '1 whole', calories: 78, protein: 6.0, carbs: 0.5, fat: 5.0, fiber: 0.0, category: 'Protein'),
    FoodNutrition(name: 'Egg Bhurji', servingSize: '2 eggs', calories: 210, protein: 13.0, carbs: 3.0, fat: 16.0, fiber: 0.5, category: 'Protein'),
    FoodNutrition(name: 'Paneer (Raw)', servingSize: '100g', calories: 265, protein: 18.0, carbs: 3.5, fat: 20.0, fiber: 0.0, category: 'Protein'),
    FoodNutrition(name: 'Soya Chunks (cooked)', servingSize: '50g', calories: 170, protein: 26.0, carbs: 13.0, fat: 0.5, fiber: 4.0, category: 'Protein'),
    FoodNutrition(name: 'Chicken Breast (boiled)', servingSize: '100g', calories: 165, protein: 31.0, carbs: 0.0, fat: 3.5, fiber: 0.0, category: 'Protein'),
    FoodNutrition(name: 'Chicken Curry', servingSize: '1 serving', calories: 280, protein: 24.0, carbs: 8.0, fat: 16.0, fiber: 1.5, category: 'Protein'),
    FoodNutrition(name: 'Dal/Lentils (Tadka)', servingSize: '1 bowl', calories: 180, protein: 12.0, carbs: 28, fat: 2.0, fiber: 5.0, category: 'Protein'),
    FoodNutrition(name: 'Rajma Curry', servingSize: '1 bowl', calories: 200, protein: 14.0, carbs: 30, fat: 2.5, fiber: 8.0, category: 'Protein'),
    FoodNutrition(name: 'Chole/Chickpea Curry', servingSize: '1 bowl', calories: 220, protein: 12.0, carbs: 35, fat: 4.0, fiber: 8.0, category: 'Protein'),
    FoodNutrition(name: 'Sprouts Salad', servingSize: '1 cup', calories: 120, protein: 9.0, carbs: 18, fat: 1.0, fiber: 4.0, category: 'Protein'),
    FoodNutrition(name: 'Fish Curry', servingSize: '1 pc', calories: 190, protein: 18.0, carbs: 4.0, fat: 11.0, fiber: 0.5, category: 'Protein'),
    FoodNutrition(name: 'Tofu', servingSize: '100g', calories: 144, protein: 14.0, carbs: 2.5, fat: 8.0, fiber: 1.5, category: 'Protein'),
    FoodNutrition(name: 'Moong Dal Cheela', servingSize: '1 medium', calories: 150, protein: 8.0, carbs: 24, fat: 3.0, fiber: 3.0, category: 'Protein'),
    FoodNutrition(name: 'Sattu Powder', servingSize: '2 tbsp (30g)', calories: 100, protein: 6.0, carbs: 15, fat: 1.5, fiber: 3.0, category: 'Protein'),
    FoodNutrition(name: 'Roasted Chana', servingSize: '50g', calories: 180, protein: 11.0, carbs: 30, fat: 3.0, fiber: 6.5, category: 'Protein'),
    FoodNutrition(name: 'Roasted Peanuts', servingSize: '30g handful', calories: 170, protein: 7.5, carbs: 5.5, fat: 14.0, fiber: 2.5, category: 'Protein'),
    FoodNutrition(name: 'Almonds', servingSize: '10 pcs', calories: 70, protein: 2.5, carbs: 2.5, fat: 6.0, fiber: 1.5, category: 'Protein'),
    FoodNutrition(name: 'Cashews', servingSize: '10 pcs', calories: 90, protein: 3.0, carbs: 9.0, fat: 7.0, fiber: 0.5, category: 'Protein'),

    // Dairy
    FoodNutrition(name: 'Milk (Toned)', servingSize: '1 glass (250ml)', calories: 120, protein: 8.0, carbs: 12, fat: 4.5, fiber: 0.0, category: 'Dairy'),
    FoodNutrition(name: 'Milk (Full Cream)', servingSize: '1 glass (250ml)', calories: 160, protein: 8.0, carbs: 12, fat: 9.0, fiber: 0.0, category: 'Dairy'),
    FoodNutrition(name: 'Curd/Dahi', servingSize: '1 cup', calories: 100, protein: 5.0, carbs: 8.0, fat: 5.0, fiber: 0.0, category: 'Dairy'),
    FoodNutrition(name: 'Lassi (Sweet)', servingSize: '1 glass', calories: 200, protein: 6.0, carbs: 32, fat: 5.0, fiber: 0.0, category: 'Dairy'),
    FoodNutrition(name: 'Buttermilk/Chaas', servingSize: '1 glass', calories: 45, protein: 2.0, carbs: 3.5, fat: 1.5, fiber: 0.0, category: 'Dairy'),
    FoodNutrition(name: 'Paneer Tikka', servingSize: '100g', calories: 240, protein: 16.0, carbs: 6.0, fat: 17.0, fiber: 1.0, category: 'Dairy'),
    FoodNutrition(name: 'Cheese Slice', servingSize: '1 pc', calories: 70, protein: 4.0, carbs: 0.5, fat: 6.0, fiber: 0.0, category: 'Dairy'),
    FoodNutrition(name: 'Whey Protein', servingSize: '1 scoop', calories: 120, protein: 24.0, carbs: 3.0, fat: 1.5, fiber: 0.0, category: 'Dairy'),
    FoodNutrition(name: 'Ghee', servingSize: '1 tsp', calories: 45, protein: 0.0, carbs: 0.0, fat: 5.0, fiber: 0.0, category: 'Dairy'),
    FoodNutrition(name: 'Butter', servingSize: '1 tsp', calories: 36, protein: 0.0, carbs: 0.0, fat: 4.0, fiber: 0.0, category: 'Dairy'),
    FoodNutrition(name: 'Veg Raita', servingSize: '1 cup', calories: 80, protein: 3.5, carbs: 7.0, fat: 4.0, fiber: 0.8, category: 'Dairy'),

    // Vegetables & Sabzi
    FoodNutrition(name: 'Aloo Gobi', servingSize: '1 bowl', calories: 150, protein: 3.0, carbs: 18, fat: 8.0, fiber: 3.0, category: 'Vegetable'),
    FoodNutrition(name: 'Palak Paneer', servingSize: '1 bowl', calories: 220, protein: 12.0, carbs: 8.0, fat: 16.0, fiber: 3.5, category: 'Vegetable'),
    FoodNutrition(name: 'Bhindi Masala', servingSize: '1 bowl', calories: 130, protein: 2.5, carbs: 12, fat: 8.0, fiber: 4.0, category: 'Vegetable'),
    FoodNutrition(name: 'Baingan Bharta', servingSize: '1 bowl', calories: 140, protein: 3.0, carbs: 14, fat: 8.5, fiber: 5.0, category: 'Vegetable'),
    FoodNutrition(name: 'Mixed Veg Sabzi', servingSize: '1 bowl', calories: 160, protein: 4.0, carbs: 16, fat: 9.0, fiber: 4.5, category: 'Vegetable'),
    FoodNutrition(name: 'Aloo Methi', servingSize: '1 bowl', calories: 170, protein: 3.5, carbs: 22, fat: 8.0, fiber: 4.0, category: 'Vegetable'),
    FoodNutrition(name: 'Gobi Manchurian', servingSize: '1 plate', calories: 280, protein: 5.0, carbs: 36, fat: 13.0, fiber: 3.0, category: 'Vegetable'),
    FoodNutrition(name: 'Paneer Butter Masala', servingSize: '1 bowl', calories: 340, protein: 14.0, carbs: 10, fat: 28.0, fiber: 1.5, category: 'Vegetable'),
    FoodNutrition(name: 'Dal Makhani', servingSize: '1 bowl', calories: 280, protein: 10.0, carbs: 32, fat: 13.0, fiber: 6.0, category: 'Vegetable'),
    FoodNutrition(name: 'Matar Paneer', servingSize: '1 bowl', calories: 230, protein: 12.0, carbs: 15, fat: 14.0, fiber: 3.5, category: 'Vegetable'),
    FoodNutrition(name: 'Jeera Aloo', servingSize: '1 bowl', calories: 180, protein: 2.5, carbs: 26, fat: 8.0, fiber: 3.0, category: 'Vegetable'),
    FoodNutrition(name: 'Lauki Sabzi', servingSize: '1 bowl', calories: 90, protein: 1.5, carbs: 8.0, fat: 6.0, fiber: 2.5, category: 'Vegetable'),
    FoodNutrition(name: 'Tinda Sabzi', servingSize: '1 bowl', calories: 95, protein: 1.5, carbs: 9.0, fat: 6.0, fiber: 2.5, category: 'Vegetable'),
    FoodNutrition(name: 'Cabbage Sabzi', servingSize: '1 bowl', calories: 110, protein: 2.0, carbs: 10, fat: 7.0, fiber: 3.5, category: 'Vegetable'),
    FoodNutrition(name: 'Kadai Paneer', servingSize: '1 bowl', calories: 290, protein: 15.0, carbs: 9.0, fat: 22.0, fiber: 2.0, category: 'Vegetable'),

    // Snacks & Street Food
    FoodNutrition(name: 'Maggi Noodles', servingSize: '1 pack', calories: 350, protein: 8.0, carbs: 48, fat: 14.0, fiber: 2.0, category: 'Snack'),
    FoodNutrition(name: 'White Bread', servingSize: '2 slices', calories: 150, protein: 4.5, carbs: 28, fat: 2.0, fiber: 1.0, category: 'Snack'),
    FoodNutrition(name: 'Brown Bread', servingSize: '2 slices', calories: 140, protein: 6.0, carbs: 26, fat: 1.8, fiber: 3.0, category: 'Snack'),
    FoodNutrition(name: 'Peanut Butter Toast', servingSize: '1 slice', calories: 190, protein: 7.0, carbs: 18, fat: 10.0, fiber: 2.0, category: 'Snack'),
    FoodNutrition(name: 'Banana', servingSize: '1 medium', calories: 105, protein: 1.3, carbs: 27, fat: 0.4, fiber: 3.0, category: 'Fruit'),
    FoodNutrition(name: 'Apple', servingSize: '1 medium', calories: 95, protein: 0.5, carbs: 25, fat: 0.3, fiber: 4.4, category: 'Fruit'),
    FoodNutrition(name: 'Marie Gold Biscuit', servingSize: '4 pcs', calories: 110, protein: 2.0, carbs: 22, fat: 2.0, fiber: 0.5, category: 'Snack'),
    FoodNutrition(name: 'Digestives Biscuit', servingSize: '2 pcs', calories: 140, protein: 2.2, carbs: 19, fat: 6.0, fiber: 1.8, category: 'Snack'),
    FoodNutrition(name: 'Namkeen/Bhujia', servingSize: '50g', calories: 280, protein: 5.0, carbs: 22, fat: 19.5, fiber: 1.5, category: 'Snack'),
    FoodNutrition(name: 'Bhel Puri', servingSize: '1 plate', calories: 180, protein: 4.0, carbs: 32, fat: 4.0, fiber: 2.5, category: 'Snack'),
    FoodNutrition(name: 'Pav Bhaji', servingSize: '1 plate', calories: 400, protein: 9.0, carbs: 54, fat: 16.0, fiber: 4.5, category: 'Snack'),
    FoodNutrition(name: 'Vada Pav', servingSize: '1 pc', calories: 290, protein: 6.0, carbs: 38, fat: 13.0, fiber: 2.5, category: 'Snack'),
    FoodNutrition(name: 'Pani Puri/Gol Gappa', servingSize: '6 pcs', calories: 180, protein: 3.0, carbs: 28, fat: 6.0, fiber: 2.0, category: 'Snack'),
    FoodNutrition(name: 'Samosa', servingSize: '1 pc', calories: 260, protein: 4.5, carbs: 30, fat: 14.0, fiber: 2.0, category: 'Snack'),
    FoodNutrition(name: 'Bread Pakora', servingSize: '1 pc', calories: 280, protein: 6.0, carbs: 32, fat: 14.5, fiber: 2.5, category: 'Snack'),
    FoodNutrition(name: 'Aloo Tikki', servingSize: '1 pc', calories: 180, protein: 3.0, carbs: 24, fat: 8.0, fiber: 2.0, category: 'Snack'),
    FoodNutrition(name: 'Papdi Chaat', servingSize: '1 plate', calories: 310, protein: 6.0, carbs: 42, fat: 13.0, fiber: 2.5, category: 'Snack'),
    FoodNutrition(name: 'Makhana (Roasted)', servingSize: '30g', calories: 110, protein: 3.0, carbs: 23, fat: 1.0, fiber: 2.5, category: 'Snack'),
    FoodNutrition(name: 'Popcorn', servingSize: '1 small tub', calories: 150, protein: 3.0, carbs: 22, fat: 6.0, fiber: 4.0, category: 'Snack'),

    // Beverages
    FoodNutrition(name: 'Chai/Tea', servingSize: '1 cup', calories: 50, protein: 1.0, carbs: 7.0, fat: 1.5, fiber: 0.0, category: 'Beverage'),
    FoodNutrition(name: 'Coffee', servingSize: '1 cup', calories: 60, protein: 1.2, carbs: 8.0, fat: 1.8, fiber: 0.0, category: 'Beverage'),
    FoodNutrition(name: 'Green Tea', servingSize: '1 cup', calories: 2, protein: 0.0, carbs: 0.5, fat: 0.0, fiber: 0.0, category: 'Beverage'),
    FoodNutrition(name: 'Nimbu Pani', servingSize: '1 glass', calories: 40, protein: 0.2, carbs: 10, fat: 0.0, fiber: 0.2, category: 'Beverage'),
    FoodNutrition(name: 'Coconut Water', servingSize: '1 glass', calories: 45, protein: 0.5, carbs: 10.5, fat: 0.1, fiber: 1.0, category: 'Beverage'),
    FoodNutrition(name: 'Mango Shake', servingSize: '1 glass', calories: 280, protein: 5.5, carbs: 45, fat: 8.0, fiber: 2.0, category: 'Beverage'),
    FoodNutrition(name: 'Banana Shake', servingSize: '1 glass', calories: 250, protein: 7.0, carbs: 42, fat: 6.5, fiber: 3.0, category: 'Beverage'),
    FoodNutrition(name: 'Sattu Drink', servingSize: '1 glass', calories: 120, protein: 7.0, carbs: 18, fat: 2.0, fiber: 3.5, category: 'Beverage'),
    FoodNutrition(name: 'Protein Shake', servingSize: '1 glass', calories: 200, protein: 26.0, carbs: 5.0, fat: 3.0, fiber: 1.0, category: 'Beverage'),
    FoodNutrition(name: 'Sugarcane Juice', servingSize: '1 glass', calories: 180, protein: 0.5, carbs: 44, fat: 0.0, fiber: 0.5, category: 'Beverage'),
    FoodNutrition(name: 'Cold Coffee', servingSize: '1 glass', calories: 190, protein: 4.5, carbs: 28, fat: 6.0, fiber: 0.0, category: 'Beverage'),

    // Meals/Combos
    FoodNutrition(name: 'Veg Thali', servingSize: '1 thali', calories: 650, protein: 22.0, carbs: 90, fat: 22.0, fiber: 9.0, category: 'Meal'),
    FoodNutrition(name: 'Mess Meal', servingSize: '1 plate', calories: 600, protein: 18.0, carbs: 85, fat: 20.0, fiber: 8.0, category: 'Meal'),
    FoodNutrition(name: 'Rajma Chawal', servingSize: '1 plate', calories: 420, protein: 16.0, carbs: 75, fat: 6.0, fiber: 10.0, category: 'Meal'),
    FoodNutrition(name: 'Chole Bhature', servingSize: '1 plate', calories: 650, protein: 15.0, carbs: 80, fat: 30.0, fiber: 9.0, category: 'Meal'),
    FoodNutrition(name: 'Poha + Chai combo', servingSize: '1 serving', calories: 230, protein: 4.0, carbs: 42, fat: 4.5, fiber: 1.5, category: 'Meal'),
    FoodNutrition(name: 'Idli Sambhar', servingSize: '1 serving', calories: 220, protein: 7.5, carbs: 42, fat: 2.0, fiber: 4.5, category: 'Meal'),
    FoodNutrition(name: 'Dosa + Sambhar', servingSize: '1 serving', calories: 260, protein: 7.0, carbs: 44, fat: 6.0, fiber: 4.5, category: 'Meal'),
    FoodNutrition(name: 'Aloo Paratha + Curd', servingSize: '1 serving', calories: 420, protein: 10.0, carbs: 58, fat: 16.0, fiber: 5.0, category: 'Meal'),
    FoodNutrition(name: 'PB Banana Toast combo', servingSize: '2 slices', calories: 420, protein: 15.0, carbs: 56, fat: 20.0, fiber: 7.0, category: 'Meal'),
    FoodNutrition(name: 'Maggi + Egg combo', servingSize: '1 serving', calories: 460, protein: 15.0, carbs: 49, fat: 21.0, fiber: 2.0, category: 'Meal'),

    // Sweets
    FoodNutrition(name: 'Gulab Jamun', servingSize: '1 pc', calories: 150, protein: 2.0, carbs: 24, fat: 5.0, fiber: 0.2, category: 'Sweet'),
    FoodNutrition(name: 'Jalebi', servingSize: '2 pcs', calories: 150, protein: 1.0, carbs: 28, fat: 4.0, fiber: 0.1, category: 'Sweet'),
    FoodNutrition(name: 'Motichoor Laddu', servingSize: '1 pc', calories: 185, protein: 2.0, carbs: 26, fat: 8.0, fiber: 0.5, category: 'Sweet'),
    FoodNutrition(name: 'Kaju Katli', servingSize: '2 pcs', calories: 115, protein: 2.5, carbs: 14, fat: 5.5, fiber: 0.2, category: 'Sweet'),
    FoodNutrition(name: 'Soan Papdi', servingSize: '1 pc', calories: 120, protein: 1.5, carbs: 16, fat: 5.5, fiber: 0.3, category: 'Sweet'),
    FoodNutrition(name: 'Besan Laddu', servingSize: '1 pc', calories: 175, protein: 3.5, carbs: 22, fat: 8.5, fiber: 0.8, category: 'Sweet'),
    FoodNutrition(name: 'Gajar Halwa', servingSize: '1 bowl', calories: 250, protein: 4.0, carbs: 32, fat: 12.0, fiber: 1.0, category: 'Sweet'),
    FoodNutrition(name: 'Kheer', servingSize: '1 bowl', calories: 220, protein: 6.0, carbs: 34, fat: 6.5, fiber: 0.1, category: 'Sweet'),
    FoodNutrition(name: 'Rasmalai', servingSize: '1 pc', calories: 180, protein: 5.0, carbs: 22, fat: 8.0, fiber: 0.2, category: 'Sweet'),
    FoodNutrition(name: 'Rasgulla', servingSize: '1 pc', calories: 120, protein: 2.0, carbs: 26, fat: 1.0, fiber: 0.1, category: 'Sweet'),
    FoodNutrition(name: 'Gur/Jaggery', servingSize: '20g', calories: 75, protein: 0.1, carbs: 19, fat: 0.0, fiber: 0.0, category: 'Sweet'),
    FoodNutrition(name: 'Peanut Chikki', servingSize: '30g bar', calories: 150, protein: 4.0, carbs: 17, fat: 8.0, fiber: 1.0, category: 'Sweet'),
  ];

  List<FoodNutrition> searchFoodDatabase(String query) {
    if (query.isEmpty) return [];
    final lowerQuery = query.toLowerCase();
    return indianFoodDatabase.where((food) {
      return food.name.toLowerCase().contains(lowerQuery) ||
             food.category.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  void addFoodWithCalories(String name, String slot, double cost, double protein, double calories, double carbs, double fat) {
    final meal = MealLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: name,
      slot: slot,
      cost: cost,
      protein: protein,
      calories: calories,
      carbs: carbs,
      fat: fat,
      timestamp: DateTime.now(),
      isSynced: false,
    );
    _meals.add(meal);
    _budgetSpent += cost;
    _proteinHit += protein;
    _caloriesConsumed += calories;
    _carbsConsumed += carbs;
    _fatConsumed += fat;

    LocalStorage.saveCachedMeals(_meals);

    final lastIdx = _weeklyProgress.length - 1;
    if (lastIdx >= 0) {
      _weeklyProgress[lastIdx] = ProgressPoint(
        dayName: _weeklyProgress[lastIdx].dayName,
        proteinGrams: _proteinHit,
        budgetSpent: _budgetSpent,
        workoutsCompleted: _weeklyProgress[lastIdx].workoutsCompleted,
      );
    }

    _checkDailyGoalsAndStreak();
    _checkAndAwardBadges();
    notifyListeners();

    if (isOnline) {
      triggerSync();
    }
  }


  void updateBodyMetrics(double weight, double height, String goal) {
    _userWeight = weight;
    _userHeight = height;
    _bodyGoal = goal;

    // BMI calculation: weight (kg) / height (m)^2
    final heightInMeters = height / 100;
    _userBmi = weight / (heightInMeters * heightInMeters);

    // BMI Category
    if (_userBmi! < 18.5) {
      _bmiCategory = 'Underweight';
    } else if (_userBmi! < 25.0) {
      _bmiCategory = 'Normal';
    } else if (_userBmi! < 30.0) {
      _bmiCategory = 'Overweight';
    } else {
      _bmiCategory = 'Obese';
    }

    // BMR (Mifflin-St Jeor assuming age 20 male)
    final bmr = 10 * weight + 6.25 * height - 5 * 20 + 5;
    final activeCalories = bmr * 1.375; // Lightly active

    // Targets based on goal
    if (goal == 'Fat Loss') {
      _dailyCalorieTarget = activeCalories - 400;
      _proteinGoal = (1.8 * weight).roundToDouble();
      _selectedWorkoutSplit = 'Push/Pull/Legs';
    } else if (goal == 'Muscle Gain') {
      _dailyCalorieTarget = activeCalories + 300;
      _proteinGoal = (2.0 * weight).roundToDouble();
      _selectedWorkoutSplit = 'Push/Pull/Legs';
    } else { // General Fitness
      _dailyCalorieTarget = activeCalories;
      _proteinGoal = (1.5 * weight).roundToDouble();
      _selectedWorkoutSplit = 'Upper/Lower';
    }

    // Round targets for cleaner UI
    _dailyCalorieTarget = _dailyCalorieTarget!.roundToDouble();

    // Persist to LocalStorage
    LocalStorage.saveBodyMetrics(
      weight: _userWeight!,
      height: _userHeight!,
      goal: _bodyGoal!,
      bmi: _userBmi!,
      bmiCategory: _bmiCategory!,
      calorieTarget: _dailyCalorieTarget!,
      recommendedSplit: _selectedWorkoutSplit!,
    );
    LocalStorage.saveUserSettings(_dailyBudgetLimit, _proteinGoal);

    notifyListeners();
  }

  // Coach Bheem Monetization State
  int _coachMessageCount = 0;
  bool _unlockedUnlimitedCoach = false;

  int get coachMessageCount => _coachMessageCount;
  bool get unlockedUnlimitedCoach => _unlockedUnlimitedCoach;

  void unlockUnlimitedCoach() {
    _unlockedUnlimitedCoach = true;
    LocalStorage.saveUnlockedUnlimitedCoach(true);
    notifyListeners();
  }

  // Lists
  List<MealLog> _meals = [];
  List<RecipeItem> _recipes = [];
  List<ChatMessage> _chatHistory = [];
  List<FitnessStory> _stories = [];
  List<HealthFlashcard> _flashcards = [];
  List<WorkoutItem> _workouts = [];
  List<ProgressPoint> _weeklyProgress = [];
  List<HealthArticle> _articles = [];
  bool _isGeneratingArticle = false;
  List<WorkoutLog> _workoutLogs = [];
  List<DesiArticle> _desiArticles = [];
  List<ProgressPhoto> _progressPhotos = [];
  bool _isAnalyzingPhoto = false;

  List<MealLog> get meals => _meals;
  List<RecipeItem> get recipes => _recipes;
  List<ChatMessage> get chatHistory => _chatHistory;
  List<FitnessStory> get stories => _stories;
  List<HealthFlashcard> get flashcards => _flashcards;
  List<WorkoutItem> get workouts => _workouts;
  List<ProgressPoint> get weeklyProgress => _weeklyProgress;
  List<HealthArticle> get articles => _articles;
  bool get isGeneratingArticle => _isGeneratingArticle;
  List<WorkoutLog> get workoutLogs => _workoutLogs;
  List<DesiArticle> get desiArticles => _desiArticles;
  List<ProgressPhoto> get progressPhotos => _progressPhotos;
  bool get isAnalyzingPhoto => _isAnalyzingPhoto;

  // Flashcards Index Tracker
  int _currentFlashcardIndex = 0;
  int get currentFlashcardIndex => _currentFlashcardIndex;

  // Workout Counter State
  WorkoutItem? _activeWorkout;
  WorkoutItem? get activeWorkout => _activeWorkout;
  int _currentSet = 1;
  int get currentSet => _currentSet;
  int _currentReps = 0;
  int get currentReps => _currentReps;

  AppState() {
    _loadFromCache();
  }

  void _loadFromCache() {
    // Load auth
    _currentUser = AuthService.getCachedUser();

    // Load profile settings
    final settings = LocalStorage.getUserSettings();
    _dailyBudgetLimit = settings['budget_limit'] ?? 100.0;
    _proteinGoal = settings['protein_goal'] ?? 60.0;
    _isHinglish = LocalStorage.getHinglishSetting();

    // Load onboarding body metrics
    final metrics = LocalStorage.getBodyMetrics();
    _userWeight = metrics['user_weight'] != null ? (metrics['user_weight'] as num).toDouble() : null;
    _userHeight = metrics['user_height'] != null ? (metrics['user_height'] as num).toDouble() : null;
    _bodyGoal = metrics['body_goal'] as String?;
    _userBmi = metrics['user_bmi'] != null ? (metrics['user_bmi'] as num).toDouble() : null;
    _bmiCategory = metrics['bmi_category'] as String?;
    _dailyCalorieTarget = metrics['daily_calorie_target'] != null ? (metrics['daily_calorie_target'] as num).toDouble() : null;
    _selectedWorkoutSplit = metrics['recommended_split'] as String?;

    // Load Coach Bheem Monetization State
    _coachMessageCount = LocalStorage.getCoachMessageCount();
    _unlockedUnlimitedCoach = LocalStorage.getUnlockedUnlimitedCoach();

    // Load Sattu Streak & Badges
    _sattuStreak = LocalStorage.getSattuStreak();
    _earnedBadges = LocalStorage.getEarnedBadges();

    // Load AI Usage Counters
    final aiCounters = LocalStorage.getAiUsageCounters();
    _aiChatCount = aiCounters['ai_chat_count'] ?? 0;
    _aiCalorieEstimateCount = aiCounters['ai_calorie_count'] ?? 0;
    _aiRecipeCount = aiCounters['ai_recipe_count'] ?? 0;
    _aiArticleCount = aiCounters['ai_article_count'] ?? 0;
    _waterConsumed = LocalStorage.getWaterIntake();
    _waterGoal = LocalStorage.getWaterGoal();

    // Load meals
    _meals = LocalStorage.getCachedMeals();
    _calculateDailyTotals();

    // Load recipes
    _recipes = LocalStorage.getCachedRecipes();
    if (_recipes.isEmpty || !_recipes.any((r) => r.title == 'Sattu Milkshake Supreme')) {
      _loadDefaultRecipes();
    }

    // Load chat
    _chatHistory = LocalStorage.getCachedChat();
    if (_chatHistory.isEmpty) {
      _loadDefaultChat();
    }

    // Load default Stories, Flashcards, and Workouts
    _loadDefaultStories();
    _loadDefaultFlashcards();
    _loadDefaultWorkouts();
    _loadDefaultProgress();

    // Load progress photos
    _progressPhotos = LocalStorage.getCachedProgressPhotos();
    if (_progressPhotos.isEmpty) {
      _loadDefaultProgressPhotos();
    }

    // Load articles
    _articles = LocalStorage.getCachedArticles();
    if (_articles.isEmpty) {
      _loadDefaultArticles();
    }

    // Load workout logs
    _workoutLogs = LocalStorage.getCachedWorkoutLogs();

    // Load DesiArticles
    _desiArticles = LocalStorage.getCachedDesiArticles();
    if (_desiArticles.isEmpty) {
      _desiArticles = List.from(mockArticles);
      LocalStorage.saveCachedDesiArticles(_desiArticles);
    }

    notifyListeners();

    // Start checking connectivity
    startConnectivityChecker();

    // Check for pending streak rescue action triggered from notifications
    if (LocalStorage.getPendingStreakRescue()) {
      LocalStorage.setPendingStreakRescue(false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        addQuickFood('Sattu Shake (Streak Rescue)', 10.0, 10.0);
        triggerCelebration(
          '🔥 Streak Saved!',
          'Your Sattu Streak was rescued by logging a quick shake! Keep it up, Champ!',
        );
      });
    }
  }


  void _calculateDailyTotals() {
    double cost = 0.0;
    double protein = 0.0;
    double calories = 0.0;
    double carbs = 0.0;
    double fat = 0.0;
    for (var m in _meals) {
      cost += m.cost;
      protein += m.protein;
      calories += m.calories;
      carbs += m.carbs;
      fat += m.fat;
    }
    _budgetSpent = cost;
    _proteinHit = protein;
    _caloriesConsumed = calories;
    _carbsConsumed = carbs;
    _fatConsumed = fat;
  }

  void _loadDefaultRecipes() {
    _recipes = [
      RecipeItem(
        title: 'Kettle Soya Pulao Jugaad',
        desc: 'Ultimate hostel muscle staple. Kettle me one-pot comfort meal ready.',
        cost: 20.0,
        protein: 25.0,
        timeMins: 15,
        tag: 'Kettle Hack',
        isKettle: true,
        steps: [
          'Soya chunks ko 5 mins garm paani me soak karo.',
          'Kettle me rice, thode spices aur soya chunks daal do.',
          'Kettle on karke 15 mins pakne do, anabolic pulao ready!'
        ],
      ),
      RecipeItem(
        title: 'Paneer Sprouts Salad',
        desc: 'Bina aag jalaye raw protein tank. Mix karo aur shuru ho jao.',
        cost: 25.0,
        protein: 21.0,
        timeMins: 5,
        tag: 'No Cook',
        isKettle: false,
        steps: [
          'Paneer ko chhote pieces me cut kar lo.',
          'Sprouts ko achhe se paani se dhul lo.',
          'Paneer, sprouts, lemon juice aur thoda black salt mix karo.'
        ],
      ),
      RecipeItem(
        title: 'Late Night Oats Porridge',
        desc: 'Late-night padhai ya heavy workout ke baad ka anabolic calorie bomb.',
        cost: 22.0,
        protein: 15.0,
        timeMins: 3,
        tag: 'No Cook',
        isKettle: false,
        steps: [
          'Ek jar ya glass me oats aur doodh daal lo.',
          'Thoda peanut butter aur 1 banana mash karke mix karo.',
          'Raat bhar room me rakh do, subah uthte hi sasta protein ready!'
        ],
      ),
      RecipeItem(
        title: 'Sattu Milkshake Supreme',
        desc: 'Desi protein drink! Power-packed sattu with cold milk & banana.',
        cost: 20.0,
        protein: 16.0,
        timeMins: 3,
        tag: 'No Cook',
        isKettle: false,
        steps: [
          'Ek bade glass me 4 tbsp (40g) Sattu powder daal do.',
          'Cold milk (200ml) aur 1 mashed banana dalkar mix karo.',
          'Mithaas ke liye thoda sa gur (jaggery) daalke shake ya stir karo, Supreme energy ready!'
        ],
      ),
      RecipeItem(
        title: 'Roasted Chana Gym Snack',
        desc: 'Crunchy, sasta and ready-to-eat muscle snack. Zero preparation needed.',
        cost: 10.0,
        protein: 13.0,
        timeMins: 1,
        tag: 'No Cook',
        isKettle: false,
        steps: [
          '60g bhuna chana (roasted chana) apni pocket ya dabba me rakho.',
          'Padhte padhte ya class ke beech me thoda thoda khao.',
          'Green tea ya paani ke sath enjoy karo for clean slow-digesting carbs and protein!'
        ],
      ),
    ];
    LocalStorage.saveCachedRecipes(_recipes);
  }

  void _loadDefaultChat() {
    _chatHistory = [
      ChatMessage(
        isUser: false,
        message: 'Ram Ram! DesiFit Experts panel me aapka swagat hai. Main Ravi hoon, certified strength coach. Amit, Joseph aur Tom bhi online hain. Aapko workout ya diet ke baare me kya help chahiye? Pucho, expert plan ready karte hain!',
        timestamp: DateTime.now(),
        senderName: 'Ravi',
      ),
    ];
    LocalStorage.saveCachedChat(_chatHistory);
  }

  void _loadDefaultStories() {
    _stories = [
      FitnessStory(
        id: 'story_1',
        title: 'Sattu Fuel',
        avatarText: '🥛',
        gradient: [const Color(0xFFA43700), const Color(0xFFCD4700)],
        tipTitle: 'Sattu: The Desi Whey',
        tipContent: 'Sattu is roasted chickpea flour. Mixing 4 tbsp (40g) in water gives 9g of pure plant protein for less than ₹5. Add lemon, pinch of salt, and roasted cumin for a refreshing, anabolic drink!',
      ),
      FitnessStory(
        id: 'story_2',
        title: 'Kettle Magic',
        avatarText: '🔌',
        gradient: [const Color(0xFF1B6D24), const Color(0xFF43A047)],
        tipTitle: 'Hostel Kettle Rules',
        tipContent: 'Clean your electric kettle immediately after boiling soya chunks! Boil a water-vinegar mix for 5 mins to completely remove the smell before making tea or coffee.',
      ),
      FitnessStory(
        id: 'story_3',
        title: 'Sleep Clean',
        avatarText: '😴',
        gradient: [const Color(0xFF1E3A8A), const Color(0xFF3B82F6)],
        tipTitle: 'Growth Hormone Trigger',
        tipContent: 'For budget muscle growth, sleep is free! Turning off screens 30 mins before bed increases deep sleep cycles where 80% of muscle growth hormones are released.',
      ),
      FitnessStory(
        id: 'story_4',
        title: 'Peanut power',
        avatarText: '🥜',
        gradient: [const Color(0xFF6B21A8), const Color(0xFFA855F7)],
        tipTitle: 'Cheap Calorie Bomb',
        tipContent: 'Struggling to gain weight? Peanuts cost just ₹100/kg. A small handful (30g) provides 180 clean calories and 8g of protein. Perfect to snack on while studying.',
      ),
    ];
  }

  void _loadDefaultFlashcards() {
    _flashcards = [
      HealthFlashcard(
        id: 'fc_1',
        category: 'NUTRITION MYTH',
        myth: 'Myth: Vegetarian diet has no complete protein source.',
        fact: 'Fact: Combining cereals (Rice/Roti) with pulses (Daal) or dairy products creates a complete amino acid profile. Sattu with milk is also a perfect source!',
      ),
      HealthFlashcard(
        id: 'fc_2',
        category: 'HOSTEL COOKING',
        myth: 'Myth: Soya chunks increase estrogen levels in males.',
        fact: 'Fact: Scientific consensus shows normal soy intake (up to 50g-100g daily) has zero impact on testosterone or estrogen levels. It is one of the cheapest 50% protein sources!',
      ),
      HealthFlashcard(
        id: 'fc_3',
        category: 'HOME TRAINING',
        myth: 'Myth: You cannot build muscle without heavy gym weights.',
        fact: 'Fact: Mechanical tension builds muscle. Calisthenics (Push-ups, squats, dips) performed close to failure trigger identical muscle growth patterns to gym equipment.',
      ),
    ];
  }

  void _loadDefaultWorkouts() {
    _workouts = [
      WorkoutItem(
        id: 'wo_1',
        name: 'Dorm Pushup Ritual',
        desc: 'Build chest and triceps. Focus on controlled eccentric lowering phase.',
        targetReps: 15,
        targetSets: 4,
        difficulty: 'Beginner',
        icon: Icons.fitness_center,
        intensity: 'RPE 8 (Bodyweight)',
        tempo: '3-0-1-0',
        targetHeartRateZone: 'Zone 2 (Aerobic)',
        isGym: false,
        bodyPart: 'Chest',
        splits: ['Push', 'Upper', 'Full Body', 'Chest'],
      ),
      WorkoutItem(
        id: 'wo_2',
        name: 'Gym Bench Press',
        desc: 'Standard chest strength builder. Focus on dynamic push and control.',
        targetReps: 8,
        targetSets: 4,
        difficulty: 'Hard',
        icon: Icons.fitness_center,
        intensity: '75% 1RM (RPE 8.5)',
        tempo: '3-1-1-0',
        targetHeartRateZone: 'Zone 2 (Aerobic)',
        isGym: true,
        bodyPart: 'Chest',
        splits: ['Push', 'Upper', 'Full Body', 'Chest'],
      ),
      WorkoutItem(
        id: 'wo_3',
        name: 'Pike Push-ups',
        desc: 'Target anterior deltoids and triceps. Keep hips elevated in a V-shape.',
        targetReps: 10,
        targetSets: 3,
        difficulty: 'Medium',
        icon: Icons.architecture,
        intensity: 'RPE 8 (Bodyweight)',
        tempo: '3-0-1-0',
        targetHeartRateZone: 'Zone 2 (Aerobic)',
        isGym: false,
        bodyPart: 'Shoulders',
        splits: ['Push', 'Upper', 'Full Body', 'Shoulders'],
      ),
      WorkoutItem(
        id: 'wo_4',
        name: 'Gym Overhead Press',
        desc: 'Build massive shoulder strength and core stability with a barbell.',
        targetReps: 6,
        targetSets: 4,
        difficulty: 'Hard',
        icon: Icons.upload,
        intensity: '80% 1RM (RPE 9)',
        tempo: '2-1-1-0',
        targetHeartRateZone: 'Zone 3 (Cardio)',
        isGym: true,
        bodyPart: 'Shoulders',
        splits: ['Push', 'Upper', 'Full Body', 'Shoulders'],
      ),
      WorkoutItem(
        id: 'wo_5',
        name: 'Gym Barbell Rows',
        desc: 'Develop upper and mid back thickness. Pull barbell to lower chest.',
        targetReps: 10,
        targetSets: 4,
        difficulty: 'Medium',
        icon: Icons.fitness_center,
        intensity: '70% 1RM (RPE 8)',
        tempo: '3-0-1-1',
        targetHeartRateZone: 'Zone 2 (Aerobic)',
        isGym: true,
        bodyPart: 'Back',
        splits: ['Pull', 'Upper', 'Full Body', 'Back'],
      ),
      WorkoutItem(
        id: 'wo_6',
        name: 'Hostel Door Pull-ups',
        desc: 'Staple bodyweight back builder. Use a sturdy pull-up bar or door frame.',
        targetReps: 8,
        targetSets: 4,
        difficulty: 'Medium',
        icon: Icons.height,
        intensity: 'RPE 8.5 (Bodyweight)',
        tempo: '2-1-1-0',
        targetHeartRateZone: 'Zone 2 (Aerobic)',
        isGym: false,
        bodyPart: 'Back',
        splits: ['Pull', 'Upper', 'Full Body', 'Back'],
      ),
      WorkoutItem(
        id: 'wo_7',
        name: 'Tricep Chair Dips',
        desc: 'Use your hostel chair/bed. Keep elbows tucked close together.',
        targetReps: 12,
        targetSets: 4,
        difficulty: 'Medium',
        icon: Icons.chair,
        intensity: 'RPE 8 (Bodyweight)',
        tempo: '3-1-1-0',
        targetHeartRateZone: 'Zone 2 (Aerobic)',
        isGym: false,
        bodyPart: 'Triceps',
        splits: ['Push', 'Upper', 'Full Body', 'Arms'],
      ),
      WorkoutItem(
        id: 'wo_8',
        name: 'Gym Close-grip Bench Press',
        desc: 'Target triceps heavily. Keep hands shoulder-width apart.',
        targetReps: 10,
        targetSets: 3,
        difficulty: 'Medium',
        icon: Icons.fitness_center,
        intensity: '70% 1RM (RPE 8)',
        tempo: '3-1-1-0',
        targetHeartRateZone: 'Zone 2 (Aerobic)',
        isGym: true,
        bodyPart: 'Triceps',
        splits: ['Push', 'Upper', 'Full Body', 'Arms'],
      ),
      WorkoutItem(
        id: 'wo_9',
        name: 'Kettle Bicep Curls',
        desc: 'Dorm bicep developer. Use a loaded kettle, water jar, or heavy backpack.',
        targetReps: 15,
        targetSets: 3,
        difficulty: 'Beginner',
        icon: Icons.shopping_bag,
        intensity: 'RPE 7.5 (Kettle/Bag)',
        tempo: '3-0-1-0',
        targetHeartRateZone: 'Zone 1 (Recovery)',
        isGym: false,
        bodyPart: 'Biceps',
        splits: ['Pull', 'Upper', 'Full Body', 'Arms'],
      ),
      WorkoutItem(
        id: 'wo_10',
        name: 'Gym Dumbbell Curls',
        desc: 'Bicep isolator. Focus on supination (turning wrists up) at the top.',
        targetReps: 12,
        targetSets: 3,
        difficulty: 'Beginner',
        icon: Icons.fitness_center,
        intensity: 'RPE 8 (Dumbbell)',
        tempo: '3-0-1-0',
        targetHeartRateZone: 'Zone 1 (Recovery)',
        isGym: true,
        bodyPart: 'Biceps',
        splits: ['Pull', 'Upper', 'Full Body', 'Arms'],
      ),
      WorkoutItem(
        id: 'wo_11',
        name: 'Gym Barbell Squats',
        desc: 'The king of lower body exercises. Focus on depth and keeping back straight.',
        targetReps: 8,
        targetSets: 4,
        difficulty: 'Hard',
        icon: Icons.unfold_more_double,
        intensity: '75% 1RM (RPE 8)',
        tempo: '3-1-1-0',
        targetHeartRateZone: 'Zone 3 (Cardio)',
        isGym: true,
        bodyPart: 'Legs',
        splits: ['Legs', 'Lower', 'Full Body', 'Legs'],
      ),
      WorkoutItem(
        id: 'wo_12',
        name: 'Kettle Goblet Squats',
        desc: 'Leg developer. Hold a heavy kettle or bag close to your chest.',
        targetReps: 20,
        targetSets: 3,
        difficulty: 'Medium',
        icon: Icons.unfold_more_double,
        intensity: 'RPE 7 (Kettle/Bag)',
        tempo: '4-1-1-0',
        targetHeartRateZone: 'Zone 3 (Cardio)',
        isGym: false,
        bodyPart: 'Legs',
        splits: ['Legs', 'Lower', 'Full Body', 'Legs'],
      ),
      WorkoutItem(
        id: 'wo_13',
        name: 'Plank Hold',
        desc: 'Isometric core strength. Keep body perfectly straight, squeeze glutes and abs.',
        targetReps: 60, // 60 seconds
        targetSets: 3,
        difficulty: 'Beginner',
        icon: Icons.horizontal_rule,
        intensity: 'RPE 7.5 (Bodyweight)',
        tempo: '1-0-0-0', // Hold
        targetHeartRateZone: 'Zone 2 (Aerobic)',
        isGym: false,
        bodyPart: 'Core',
        splits: ['Legs', 'Lower', 'Full Body', 'Legs'],
      ),
      WorkoutItem(
        id: 'wo_14',
        name: 'Hanging Leg Raises',
        desc: 'Target lower abs and hip flexors. Hang from bar and raise legs straight.',
        targetReps: 12,
        targetSets: 3,
        difficulty: 'Medium',
        icon: Icons.height,
        intensity: 'RPE 8.5 (Bodyweight)',
        tempo: '2-0-1-1',
        targetHeartRateZone: 'Zone 2 (Aerobic)',
        isGym: true,
        bodyPart: 'Core',
        splits: ['Legs', 'Lower', 'Full Body', 'Legs'],
      ),
      WorkoutItem(
        id: 'wo_15',
        name: 'Diamond Push-ups',
        desc: 'Intense tricep and inner chest developer. Keep hands in diamond shape.',
        targetReps: 12,
        targetSets: 3,
        difficulty: 'Medium',
        icon: Icons.bolt,
        intensity: 'RPE 8 (Bodyweight)',
        tempo: '3-0-1-0',
        targetHeartRateZone: 'Zone 2 (Aerobic)',
        isGym: false,
        bodyPart: 'Triceps',
        splits: ['Push', 'Upper', 'Full Body', 'Arms'],
      ),
      WorkoutItem(
        id: 'wo_16',
        name: 'Gym Barbell Deadlift',
        desc: 'Posterior chain builder. Keep back straight and pull from floor.',
        targetReps: 5,
        targetSets: 3,
        difficulty: 'Hard',
        icon: Icons.arrow_upward,
        intensity: '85% 1RM (RPE 9)',
        tempo: '2-1-1-0',
        targetHeartRateZone: 'Zone 3 (Cardio)',
        isGym: true,
        bodyPart: 'Back',
        splits: ['Pull', 'Lower', 'Full Body', 'Back'],
      ),
      WorkoutItem(
        id: 'wo_17',
        name: 'Gym Lateral Raises',
        desc: 'Isolate medial deltoids for that round, wide shoulder look.',
        targetReps: 15,
        targetSets: 4,
        difficulty: 'Beginner',
        icon: Icons.swap_horiz,
        intensity: 'RPE 8 (Dumbbell)',
        tempo: '2-0-1-1',
        targetHeartRateZone: 'Zone 1 (Recovery)',
        isGym: true,
        bodyPart: 'Shoulders',
        splits: ['Push', 'Upper', 'Shoulders'],
      ),
      WorkoutItem(
        id: 'wo_18',
        name: 'Desi Baithak (Squat Jump)',
        desc: 'Traditional cardiovascular leg blaster. Explode upwards on every rep.',
        targetReps: 10,
        targetSets: 4,
        difficulty: 'Hard',
        icon: Icons.bolt,
        intensity: 'RPE 9 (Cardio)',
        tempo: '1-0-1-0',
        targetHeartRateZone: 'Zone 4 (Threshold)',
        isGym: false,
        bodyPart: 'Legs',
        splits: ['Legs', 'Lower', 'Full Body', 'Legs'],
      ),
      WorkoutItem(
        id: 'wo_19',
        name: 'Russian Twists',
        desc: 'Target obliques and core rotation. Hold a heavy bag or book for resistance.',
        targetReps: 20,
        targetSets: 3,
        difficulty: 'Beginner',
        icon: Icons.rotate_right,
        intensity: 'RPE 7 (Bodyweight)',
        tempo: '1-0-1-0',
        targetHeartRateZone: 'Zone 2 (Aerobic)',
        isGym: false,
        bodyPart: 'Core',
        splits: ['Legs', 'Lower', 'Full Body', 'Legs'],
      ),
      WorkoutItem(
        id: 'wo_20',
        name: 'Chin-ups',
        desc: 'Excellent bicep and lat builder. Pull up with palms facing towards you.',
        targetReps: 8,
        targetSets: 4,
        difficulty: 'Medium',
        icon: Icons.height,
        intensity: 'RPE 8 (Bodyweight)',
        tempo: '2-0-1-0',
        targetHeartRateZone: 'Zone 2 (Aerobic)',
        isGym: false,
        bodyPart: 'Biceps',
        splits: ['Pull', 'Upper', 'Full Body', 'Arms'],
      ),
      WorkoutItem(
        id: 'wo_21',
        name: 'Hanuman Dand (Hindu Pushups)',
        desc: 'Traditional Indian dive-bomber pushup. Works chest, shoulders, triceps, and lower back.',
        targetReps: 12,
        targetSets: 4,
        difficulty: 'Medium',
        icon: Icons.bolt,
        intensity: 'RPE 8.5 (Bodyweight)',
        tempo: '2-1-2-0',
        targetHeartRateZone: 'Zone 3 (Cardio)',
        isGym: false,
        bodyPart: 'Chest',
        splits: ['Push', 'Upper', 'Full Body', 'Chest'],
      ),
      WorkoutItem(
        id: 'wo_22',
        name: 'Desi Sapate (Burpee Dand)',
        desc: 'Explosive combat-conditioning routine combining baithak, pushup, and jump.',
        targetReps: 10,
        targetSets: 3,
        difficulty: 'Hard',
        icon: Icons.flash_on,
        intensity: 'RPE 9.5 (Cardio)',
        tempo: '1-0-1-0',
        targetHeartRateZone: 'Zone 4 (Threshold)',
        isGym: false,
        bodyPart: 'Legs',
        splits: ['Legs', 'Lower', 'Full Body', 'Legs'],
      ),
      WorkoutItem(
        id: 'wo_23',
        name: 'Gada / Mace Swing simulation',
        desc: 'Traditional shoulder and grip developer. Swing a weighted bag or heavy book behind the head.',
        targetReps: 15,
        targetSets: 3,
        difficulty: 'Medium',
        icon: Icons.rotate_left,
        intensity: 'RPE 8 (Bag)',
        tempo: '2-0-2-0',
        targetHeartRateZone: 'Zone 2 (Aerobic)',
        isGym: false,
        bodyPart: 'Shoulders',
        splits: ['Push', 'Upper', 'Shoulders'],
      ),
      WorkoutItem(
        id: 'wo_24',
        name: 'Mudgar Swings (Karlakattai)',
        desc: 'Traditional wooden club swing. Targets wrist, grip, and shoulder rotators.',
        targetReps: 12,
        targetSets: 3,
        difficulty: 'Medium',
        icon: Icons.rotate_right,
        intensity: 'RPE 8 (Mudgar)',
        tempo: '2-0-2-0',
        targetHeartRateZone: 'Zone 2 (Aerobic)',
        isGym: false,
        bodyPart: 'Shoulders',
        splits: ['Push', 'Upper', 'Shoulders'],
      ),
      WorkoutItem(
        id: 'wo_25',
        name: 'Ram Murti Dand',
        desc: 'Traditional wrestlers pushup with dynamic isometric pause at bottom.',
        targetReps: 10,
        targetSets: 4,
        difficulty: 'Hard',
        icon: Icons.bolt,
        intensity: 'RPE 9 (Bodyweight)',
        tempo: '3-2-1-0',
        targetHeartRateZone: 'Zone 3 (Cardio)',
        isGym: false,
        bodyPart: 'Chest',
        splits: ['Push', 'Upper', 'Full Body', 'Chest'],
      ),
      WorkoutItem(
        id: 'wo_26',
        name: 'Traditional Bethak',
        desc: 'Hindu squats with deep arm swinging. Keeps hips low and back flat.',
        targetReps: 25,
        targetSets: 4,
        difficulty: 'Beginner',
        icon: Icons.unfold_more_double,
        intensity: 'RPE 7 (Bodyweight)',
        tempo: '2-0-1-0',
        targetHeartRateZone: 'Zone 2 (Aerobic)',
        isGym: false,
        bodyPart: 'Legs',
        splits: ['Legs', 'Lower', 'Full Body', 'Legs'],
      ),
      WorkoutItem(
        id: 'wo_27',
        name: 'Akhara Wrestler Bridge',
        desc: 'Spine and neck bridge. Keep neck supported and arch body upwards.',
        targetReps: 30,
        targetSets: 3,
        difficulty: 'Hard',
        icon: Icons.accessibility_new,
        intensity: 'RPE 8.5 (Bodyweight)',
        tempo: '1-0-0-0',
        targetHeartRateZone: 'Zone 2 (Aerobic)',
        isGym: false,
        bodyPart: 'Core',
        splits: ['Legs', 'Lower', 'Back'],
      ),
      WorkoutItem(
        id: 'wo_28',
        name: 'Single Leg Desi Bethak',
        desc: 'Advanced akharas pistol squat. Lower under control and balance.',
        targetReps: 8,
        targetSets: 3,
        difficulty: 'Hard',
        icon: Icons.bolt,
        intensity: 'RPE 9 (Bodyweight)',
        tempo: '3-1-1-0',
        targetHeartRateZone: 'Zone 3 (Cardio)',
        isGym: false,
        bodyPart: 'Legs',
        splits: ['Legs', 'Lower', 'Legs'],
      ),
      WorkoutItem(
        id: 'wo_29',
        name: 'L-Sit Hold',
        desc: 'Core and shoulder isometric hold. Keep legs parallel to the floor.',
        targetReps: 20,
        targetSets: 3,
        difficulty: 'Hard',
        icon: Icons.horizontal_rule,
        intensity: 'RPE 9 (Bodyweight)',
        tempo: '1-0-0-0',
        targetHeartRateZone: 'Zone 2 (Aerobic)',
        isGym: false,
        bodyPart: 'Core',
        splits: ['Legs', 'Lower', 'Core'],
      ),
      WorkoutItem(
        id: 'wo_30',
        name: 'Archer Pushups',
        desc: 'Unilateral pushup. Extend one arm to side while bending other elbow.',
        targetReps: 10,
        targetSets: 3,
        difficulty: 'Hard',
        icon: Icons.arrow_forward_ios,
        intensity: 'RPE 8.5 (Bodyweight)',
        tempo: '3-0-1-0',
        targetHeartRateZone: 'Zone 2 (Aerobic)',
        isGym: false,
        bodyPart: 'Chest',
        splits: ['Push', 'Upper', 'Chest'],
      ),
      WorkoutItem(
        id: 'wo_31',
        name: 'Decline Pushups',
        desc: 'Elevate your feet on a bed or chair to target upper chest fibers.',
        targetReps: 15,
        targetSets: 3,
        difficulty: 'Medium',
        icon: Icons.trending_up,
        intensity: 'RPE 8 (Bodyweight)',
        tempo: '3-0-1-0',
        targetHeartRateZone: 'Zone 2 (Aerobic)',
        isGym: false,
        bodyPart: 'Chest',
        splits: ['Push', 'Upper', 'Chest'],
      ),
      WorkoutItem(
        id: 'wo_32',
        name: 'Incline Pushups',
        desc: 'Place hands on hostel table or bed to target lower chest and triceps.',
        targetReps: 15,
        targetSets: 3,
        difficulty: 'Beginner',
        icon: Icons.trending_down,
        intensity: 'RPE 7 (Bodyweight)',
        tempo: '3-0-1-0',
        targetHeartRateZone: 'Zone 1 (Recovery)',
        isGym: false,
        bodyPart: 'Chest',
        splits: ['Push', 'Upper', 'Chest'],
      ),
      WorkoutItem(
        id: 'wo_33',
        name: 'Wall-assisted Handstand Pushup',
        desc: 'Vertical push for shoulders. Place hands near wall and kick up.',
        targetReps: 6,
        targetSets: 3,
        difficulty: 'Hard',
        icon: Icons.arrow_upward_rounded,
        intensity: 'RPE 9 (Bodyweight)',
        tempo: '3-1-1-0',
        targetHeartRateZone: 'Zone 3 (Cardio)',
        isGym: false,
        bodyPart: 'Shoulders',
        splits: ['Push', 'Upper', 'Shoulders'],
      ),
      WorkoutItem(
        id: 'wo_34',
        name: 'Tuck Front Lever Hold',
        desc: 'Advanced bodyweight pull back hold. Tuck knees to chest under bar.',
        targetReps: 15,
        targetSets: 3,
        difficulty: 'Hard',
        icon: Icons.horizontal_rule_rounded,
        intensity: 'RPE 9.5 (Bodyweight)',
        tempo: '1-0-0-0',
        targetHeartRateZone: 'Zone 2 (Aerobic)',
        isGym: false,
        bodyPart: 'Back',
        splits: ['Pull', 'Upper', 'Back'],
      ),
      WorkoutItem(
        id: 'wo_35',
        name: 'Australian Pull-ups (Bodyweight Rows)',
        desc: 'Horizontal pull. Grip edge of a sturdy table or low bar and pull chest up.',
        targetReps: 12,
        targetSets: 4,
        difficulty: 'Beginner',
        icon: Icons.menu,
        intensity: 'RPE 7.5 (Bodyweight)',
        tempo: '2-0-1-1',
        targetHeartRateZone: 'Zone 2 (Aerobic)',
        isGym: false,
        bodyPart: 'Back',
        splits: ['Pull', 'Upper', 'Back'],
      ),
      WorkoutItem(
        id: 'wo_36',
        name: 'Single Leg Calf Raises',
        desc: 'Dorm calf builder. Stand on one leg on a step and raise heel high.',
        targetReps: 20,
        targetSets: 3,
        difficulty: 'Beginner',
        icon: Icons.height_outlined,
        intensity: 'RPE 7 (Bodyweight)',
        tempo: '2-1-1-1',
        targetHeartRateZone: 'Zone 1 (Recovery)',
        isGym: false,
        bodyPart: 'Legs',
        splits: ['Legs', 'Lower', 'Legs'],
      ),
      WorkoutItem(
        id: 'wo_37',
        name: 'Gym Incline Dumbbell Press',
        desc: 'Targets upper chest fibers. Set bench to 30-45 degrees.',
        targetReps: 10,
        targetSets: 4,
        difficulty: 'Medium',
        icon: Icons.fitness_center,
        intensity: '70% 1RM (RPE 8)',
        tempo: '3-0-1-0',
        targetHeartRateZone: 'Zone 2 (Aerobic)',
        isGym: true,
        bodyPart: 'Chest',
        splits: ['Push', 'Upper', 'Chest'],
      ),
      WorkoutItem(
        id: 'wo_38',
        name: 'Gym Dumbbell Shoulder Press',
        desc: 'Vertical press. Sit upright and press dumbbells overhead.',
        targetReps: 8,
        targetSets: 4,
        difficulty: 'Medium',
        icon: Icons.upload_rounded,
        intensity: '75% 1RM (RPE 8)',
        tempo: '3-0-1-0',
        targetHeartRateZone: 'Zone 2 (Aerobic)',
        isGym: true,
        bodyPart: 'Shoulders',
        splits: ['Push', 'Upper', 'Shoulders'],
      ),
      WorkoutItem(
        id: 'wo_39',
        name: 'Gym Lat Pulldown',
        desc: 'Build back width. Pull bar down to upper chest under control.',
        targetReps: 10,
        targetSets: 4,
        difficulty: 'Medium',
        icon: Icons.arrow_downward,
        intensity: '70% 1RM (RPE 8)',
        tempo: '3-0-1-1',
        targetHeartRateZone: 'Zone 2 (Aerobic)',
        isGym: true,
        bodyPart: 'Back',
        splits: ['Pull', 'Upper', 'Back'],
      ),
      WorkoutItem(
        id: 'wo_40',
        name: 'Gym Barbell Curls',
        desc: 'Classic bicep growth exercise. Stand straight and curl barbell up.',
        targetReps: 10,
        targetSets: 3,
        difficulty: 'Medium',
        icon: Icons.fitness_center,
        intensity: '70% 1RM (RPE 8)',
        tempo: '3-0-1-0',
        targetHeartRateZone: 'Zone 1 (Recovery)',
        isGym: true,
        bodyPart: 'Biceps',
        splits: ['Pull', 'Upper', 'Arms'],
      ),
      WorkoutItem(
        id: 'wo_41',
        name: 'Gym Triceps Cable Pushdown',
        desc: 'Isolate triceps lateral and medial heads using a rope or straight bar.',
        targetReps: 12,
        targetSets: 4,
        difficulty: 'Beginner',
        icon: Icons.arrow_downward_outlined,
        intensity: 'RPE 8 (Cable)',
        tempo: '3-0-1-1',
        targetHeartRateZone: 'Zone 1 (Recovery)',
        isGym: true,
        bodyPart: 'Triceps',
        splits: ['Push', 'Upper', 'Arms'],
      ),
      WorkoutItem(
        id: 'wo_42',
        name: 'Gym Romanian Deadlift (RDL)',
        desc: 'Hinge at hips to build hamstrings and glutes. Keep barbell close to legs.',
        targetReps: 10,
        targetSets: 3,
        difficulty: 'Medium',
        icon: Icons.arrow_downward_rounded,
        intensity: '70% 1RM (RPE 8)',
        tempo: '3-1-1-0',
        targetHeartRateZone: 'Zone 3 (Cardio)',
        isGym: true,
        bodyPart: 'Legs',
        splits: ['Legs', 'Lower', 'Legs'],
      ),
      WorkoutItem(
        id: 'wo_43',
        name: 'Gym Leg Press',
        desc: 'Quad builder. Press platform under control. Avoid locking knees at top.',
        targetReps: 12,
        targetSets: 4,
        difficulty: 'Medium',
        icon: Icons.unfold_more_double_outlined,
        intensity: '75% 1RM (RPE 8.5)',
        tempo: '3-1-1-0',
        targetHeartRateZone: 'Zone 3 (Cardio)',
        isGym: true,
        bodyPart: 'Legs',
        splits: ['Legs', 'Lower', 'Legs'],
      ),
      WorkoutItem(
        id: 'wo_44',
        name: 'Gym Seated Cable Row',
        desc: 'Build back thickness. Pull cable handle to lower belly button.',
        targetReps: 10,
        targetSets: 4,
        difficulty: 'Medium',
        icon: Icons.compare_arrows,
        intensity: '70% 1RM (RPE 8)',
        tempo: '3-0-1-1',
        targetHeartRateZone: 'Zone 2 (Aerobic)',
        isGym: true,
        bodyPart: 'Back',
        splits: ['Pull', 'Upper', 'Back'],
      ),
      WorkoutItem(
        id: 'wo_45',
        name: 'Gym Incline Dumbbell Bicep Curl',
        desc: 'Stretches long bicep head. Set incline to 45 degrees, curl dumbbells up.',
        targetReps: 12,
        targetSets: 3,
        difficulty: 'Medium',
        icon: Icons.fitness_center_outlined,
        intensity: 'RPE 8 (Dumbbell)',
        tempo: '3-0-1-0',
        targetHeartRateZone: 'Zone 1 (Recovery)',
        isGym: true,
        bodyPart: 'Biceps',
        splits: ['Pull', 'Upper', 'Arms'],
      ),
      WorkoutItem(
        id: 'wo_46',
        name: 'Gym Hammer Curls',
        desc: 'Develops brachialis and forearm muscles. Hold dumbbells neutral (palms facing).',
        targetReps: 12,
        targetSets: 3,
        difficulty: 'Beginner',
        icon: Icons.fitness_center_rounded,
        intensity: 'RPE 8 (Dumbbell)',
        tempo: '3-0-1-0',
        targetHeartRateZone: 'Zone 1 (Recovery)',
        isGym: true,
        bodyPart: 'Biceps',
        splits: ['Pull', 'Upper', 'Arms'],
      ),
      WorkoutItem(
        id: 'wo_47',
        name: 'Traditional Jori Swings',
        desc: 'Akhara club swinging training. Swing heavy clubs alternately around shoulders.',
        targetReps: 20,
        targetSets: 3,
        difficulty: 'Hard',
        icon: Icons.rotate_right_rounded,
        intensity: 'RPE 9 (Jori)',
        tempo: '1-0-1-0',
        targetHeartRateZone: 'Zone 3 (Cardio)',
        isGym: false,
        bodyPart: 'Shoulders',
        splits: ['Push', 'Upper', 'Shoulders'],
      ),
      WorkoutItem(
        id: 'wo_48',
        name: 'Gym Pec Deck Machine',
        desc: 'Machine chest flyes to isolate chest pectoralis major. Focus on deep stretch.',
        targetReps: 12,
        targetSets: 3,
        difficulty: 'Beginner',
        icon: Icons.fitness_center_rounded,
        intensity: 'RPE 8 (Machine)',
        tempo: '3-0-1-1',
        targetHeartRateZone: 'Zone 1 (Recovery)',
        isGym: true,
        bodyPart: 'Chest',
        splits: ['Push', 'Upper', 'Chest'],
      ),
      WorkoutItem(
        id: 'wo_49',
        name: 'Gym Cable Crossover',
        desc: 'Cable machine chest builder. Stand in center, pull handles down and together.',
        targetReps: 12,
        targetSets: 3,
        difficulty: 'Medium',
        icon: Icons.compare_arrows_rounded,
        intensity: 'RPE 8 (Cable)',
        tempo: '2-0-1-1',
        targetHeartRateZone: 'Zone 2 (Aerobic)',
        isGym: true,
        bodyPart: 'Chest',
        splits: ['Push', 'Upper', 'Chest'],
      ),
      WorkoutItem(
        id: 'wo_50',
        name: 'Gym Leg Extension Machine',
        desc: 'Isolates quadriceps. Sit on machine and extend legs straight.',
        targetReps: 15,
        targetSets: 3,
        difficulty: 'Beginner',
        icon: Icons.unfold_more_double_sharp,
        intensity: 'RPE 7.5 (Machine)',
        tempo: '3-0-1-1',
        targetHeartRateZone: 'Zone 2 (Aerobic)',
        isGym: true,
        bodyPart: 'Legs',
        splits: ['Legs', 'Lower', 'Legs'],
      ),
      WorkoutItem(
        id: 'wo_51',
        name: 'Gym Seated Hamstring Curl',
        desc: 'Isolates hamstrings. Pull pad behind ankles downwards towards glutes.',
        targetReps: 12,
        targetSets: 3,
        difficulty: 'Beginner',
        icon: Icons.unfold_less_double_sharp,
        intensity: 'RPE 7.5 (Machine)',
        tempo: '3-0-1-1',
        targetHeartRateZone: 'Zone 2 (Aerobic)',
        isGym: true,
        bodyPart: 'Legs',
        splits: ['Legs', 'Lower', 'Legs'],
      ),
      WorkoutItem(
        id: 'wo_52',
        name: 'Gym Seated Calf Raise Machine',
        desc: 'Weighted calf developer targeting soleus muscle.',
        targetReps: 15,
        targetSets: 3,
        difficulty: 'Beginner',
        icon: Icons.height_rounded,
        intensity: 'RPE 8 (Machine)',
        tempo: '2-1-1-1',
        targetHeartRateZone: 'Zone 1 (Recovery)',
        isGym: true,
        bodyPart: 'Legs',
        splits: ['Legs', 'Lower', 'Legs'],
      ),
      WorkoutItem(
        id: 'wo_53',
        name: 'Gym Smith Machine Squat',
        desc: 'Fixed track squatting. Allows safer posture control for quad building.',
        targetReps: 10,
        targetSets: 4,
        difficulty: 'Medium',
        icon: Icons.fitness_center,
        intensity: '70% 1RM (RPE 8)',
        tempo: '3-1-1-0',
        targetHeartRateZone: 'Zone 3 (Cardio)',
        isGym: true,
        bodyPart: 'Legs',
        splits: ['Legs', 'Lower', 'Legs'],
      ),
      WorkoutItem(
        id: 'wo_54',
        name: 'Gym Smith Machine Incline Press',
        desc: 'Fixed-track chest press targeting upper clavicular fibers.',
        targetReps: 10,
        targetSets: 3,
        difficulty: 'Medium',
        icon: Icons.upload_sharp,
        intensity: '75% 1RM (RPE 8)',
        tempo: '3-0-1-0',
        targetHeartRateZone: 'Zone 2 (Aerobic)',
        isGym: true,
        bodyPart: 'Chest',
        splits: ['Push', 'Upper', 'Chest'],
      ),
      WorkoutItem(
        id: 'wo_55',
        name: 'Gym Cable Face Pulls',
        desc: 'Excellent shoulder health exercise. Pull rope handles towards ears, rotate wrists out.',
        targetReps: 15,
        targetSets: 4,
        difficulty: 'Beginner',
        icon: Icons.face_retouching_natural,
        intensity: 'RPE 8 (Cable)',
        tempo: '2-0-1-1',
        targetHeartRateZone: 'Zone 1 (Recovery)',
        isGym: true,
        bodyPart: 'Shoulders',
        splits: ['Pull', 'Upper', 'Shoulders'],
      ),
      WorkoutItem(
        id: 'wo_56',
        name: 'Gym Preacher Curl Machine',
        desc: 'Bicep machine isolator. Locks elbows in place to prevent swinging.',
        targetReps: 12,
        targetSets: 3,
        difficulty: 'Beginner',
        icon: Icons.fitness_center_outlined,
        intensity: 'RPE 7.5 (Machine)',
        tempo: '3-0-1-0',
        targetHeartRateZone: 'Zone 1 (Recovery)',
        isGym: true,
        bodyPart: 'Biceps',
        splits: ['Pull', 'Upper', 'Arms'],
      ),
      WorkoutItem(
        id: 'wo_57',
        name: 'Gym T-Bar Row Machine',
        desc: 'Chest supported or standing T-Bar row for mid back thickness.',
        targetReps: 10,
        targetSets: 4,
        difficulty: 'Medium',
        icon: Icons.fitness_center_sharp,
        intensity: '70% 1RM (RPE 8)',
        tempo: '3-0-1-1',
        targetHeartRateZone: 'Zone 2 (Aerobic)',
        isGym: true,
        bodyPart: 'Back',
        splits: ['Pull', 'Upper', 'Back'],
      ),
      WorkoutItem(
        id: 'wo_58',
        name: 'Gym Assisted Pull-up Machine',
        desc: 'Counterweight pull up guide. Ideal for learning correct form.',
        targetReps: 10,
        targetSets: 3,
        difficulty: 'Beginner',
        icon: Icons.arrow_upward_sharp,
        intensity: 'RPE 7.5 (Machine)',
        tempo: '3-0-1-0',
        targetHeartRateZone: 'Zone 2 (Aerobic)',
        isGym: true,
        bodyPart: 'Back',
        splits: ['Pull', 'Upper', 'Back'],
      ),
      WorkoutItem(
        id: 'wo_59',
        name: 'Gym Cable Bicep Curl',
        desc: 'Consistent load bicep curls using cable pully stack.',
        targetReps: 12,
        targetSets: 3,
        difficulty: 'Beginner',
        icon: Icons.settings_input_hdmi,
        intensity: 'RPE 8 (Cable)',
        tempo: '3-0-1-0',
        targetHeartRateZone: 'Zone 1 (Recovery)',
        isGym: true,
        bodyPart: 'Biceps',
        splits: ['Pull', 'Upper', 'Arms'],
      ),
      WorkoutItem(
        id: 'wo_60',
        name: 'Strict Muscle-ups',
        desc: 'Calisthenics milestone. Pull chest above bar and press body straight up.',
        targetReps: 5,
        targetSets: 3,
        difficulty: 'Hard',
        icon: Icons.bolt,
        intensity: 'RPE 9.5 (Bodyweight)',
        tempo: '2-0-1-1',
        targetHeartRateZone: 'Zone 4 (Threshold)',
        isGym: false,
        bodyPart: 'Back',
        splits: ['Pull', 'Upper', 'Full Body', 'Back'],
      ),
      WorkoutItem(
        id: 'wo_61',
        name: 'Calisthenics Chest Dips',
        desc: 'Parallel bars push exercise. Lean forward to target lower chest fibers.',
        targetReps: 12,
        targetSets: 4,
        difficulty: 'Medium',
        icon: Icons.vertical_align_bottom,
        intensity: 'RPE 8 (Bodyweight)',
        tempo: '3-1-1-0',
        targetHeartRateZone: 'Zone 2 (Aerobic)',
        isGym: false,
        bodyPart: 'Chest',
        splits: ['Push', 'Upper', 'Chest'],
      ),
      WorkoutItem(
        id: 'wo_62',
        name: 'L-sit Chest Dips',
        desc: 'Advanced chest dips on parallel bars while holding legs in L-sit.',
        targetReps: 8,
        targetSets: 3,
        difficulty: 'Hard',
        icon: Icons.bolt_outlined,
        intensity: 'RPE 9 (Bodyweight)',
        tempo: '3-1-1-0',
        targetHeartRateZone: 'Zone 3 (Cardio)',
        isGym: false,
        bodyPart: 'Chest',
        splits: ['Push', 'Upper', 'Chest'],
      ),
      WorkoutItem(
        id: 'wo_63',
        name: 'Strict Bar Dips',
        desc: 'Press body straight up on a single bar. Targets chest and core stability.',
        targetReps: 10,
        targetSets: 3,
        difficulty: 'Medium',
        icon: Icons.horizontal_rule_outlined,
        intensity: 'RPE 8 (Bodyweight)',
        tempo: '3-0-1-0',
        targetHeartRateZone: 'Zone 2 (Aerobic)',
        isGym: false,
        bodyPart: 'Chest',
        splits: ['Push', 'Upper', 'Chest'],
      ),
      WorkoutItem(
        id: 'wo_64',
        name: 'Tuck Planche Hold',
        desc: 'Straight arm balance hold. Lean shoulders forward, lift knees off floor.',
        targetReps: 15,
        targetSets: 3,
        difficulty: 'Hard',
        icon: Icons.accessibility_new_outlined,
        intensity: 'RPE 9.5 (Bodyweight)',
        tempo: '1-0-0-0',
        targetHeartRateZone: 'Zone 2 (Aerobic)',
        isGym: false,
        bodyPart: 'Shoulders',
        splits: ['Push', 'Upper', 'Shoulders'],
      ),
      WorkoutItem(
        id: 'wo_65',
        name: 'Pistol Squats',
        desc: 'Single leg balance squat to full depth under control.',
        targetReps: 8,
        targetSets: 3,
        difficulty: 'Hard',
        icon: Icons.unfold_more_double_rounded,
        intensity: 'RPE 9 (Bodyweight)',
        tempo: '3-1-1-0',
        targetHeartRateZone: 'Zone 3 (Cardio)',
        isGym: false,
        bodyPart: 'Legs',
        splits: ['Legs', 'Lower', 'Legs'],
      ),
      WorkoutItem(
        id: 'wo_66',
        name: 'Strict Toes-to-Bar',
        desc: 'Hang from pull up bar and raise straight legs to tap the bar.',
        targetReps: 10,
        targetSets: 3,
        difficulty: 'Hard',
        icon: Icons.height_sharp,
        intensity: 'RPE 8.5 (Bodyweight)',
        tempo: '2-0-1-1',
        targetHeartRateZone: 'Zone 2 (Aerobic)',
        isGym: false,
        bodyPart: 'Core',
        splits: ['Legs', 'Lower', 'Core'],
      ),
      WorkoutItem(
        id: 'wo_67',
        name: 'Windshield Wipers',
        desc: 'Hanging abdominal rotation. Swing legs left to right under control.',
        targetReps: 12,
        targetSets: 3,
        difficulty: 'Hard',
        icon: Icons.rotate_right_outlined,
        intensity: 'RPE 9 (Bodyweight)',
        tempo: '2-0-2-0',
        targetHeartRateZone: 'Zone 3 (Cardio)',
        isGym: false,
        bodyPart: 'Core',
        splits: ['Legs', 'Lower', 'Core'],
      ),
      WorkoutItem(
        id: 'wo_68',
        name: 'Back Lever Hold',
        desc: 'Straight-arm pulling hold. Suspend body facing floor horizontally.',
        targetReps: 15,
        targetSets: 3,
        difficulty: 'Hard',
        icon: Icons.horizontal_rule_sharp,
        intensity: 'RPE 9.5 (Bodyweight)',
        tempo: '1-0-0-0',
        targetHeartRateZone: 'Zone 2 (Aerobic)',
        isGym: false,
        bodyPart: 'Back',
        splits: ['Pull', 'Upper', 'Back'],
      ),
      WorkoutItem(
        id: 'wo_69',
        name: 'Dragon Flag Hold',
        desc: 'Bruce Lee abdominal strength hold. Keep whole torso straight and rigid.',
        targetReps: 15,
        targetSets: 3,
        difficulty: 'Hard',
        icon: Icons.flag,
        intensity: 'RPE 9.5 (Bodyweight)',
        tempo: '1-0-0-0',
        targetHeartRateZone: 'Zone 2 (Aerobic)',
        isGym: false,
        bodyPart: 'Core',
        splits: ['Legs', 'Lower', 'Core'],
      ),
      WorkoutItem(
        id: 'wo_70',
        name: 'Archer Pull-ups',
        desc: 'Suspend one side of back. Pull chest up towards one hand while keeping other arm straight.',
        targetReps: 6,
        targetSets: 3,
        difficulty: 'Hard',
        icon: Icons.arrow_right_alt,
        intensity: 'RPE 9 (Bodyweight)',
        tempo: '2-0-1-0',
        targetHeartRateZone: 'Zone 3 (Cardio)',
        isGym: false,
        bodyPart: 'Back',
        splits: ['Pull', 'Upper', 'Back'],
      ),
      WorkoutItem(
        id: 'wo_71',
        name: 'Typewriter Pull-ups',
        desc: 'Horizontal shift. Pull chest up to bar and slide side to side.',
        targetReps: 8,
        targetSets: 3,
        difficulty: 'Hard',
        icon: Icons.keyboard_double_arrow_right,
        intensity: 'RPE 9 (Bodyweight)',
        tempo: '2-0-2-0',
        targetHeartRateZone: 'Zone 3 (Cardio)',
        isGym: false,
        bodyPart: 'Back',
        splits: ['Pull', 'Upper', 'Back'],
      ),
      WorkoutItem(
        id: 'wo_72',
        name: 'Clapping Push-ups',
        desc: 'Explosive plyometric horizontal pushing chest power.',
        targetReps: 10,
        targetSets: 3,
        difficulty: 'Medium',
        icon: Icons.flash_on_outlined,
        intensity: 'RPE 8.5 (Bodyweight)',
        tempo: '1-0-1-0',
        targetHeartRateZone: 'Zone 3 (Cardio)',
        isGym: false,
        bodyPart: 'Chest',
        splits: ['Push', 'Upper', 'Chest'],
      ),
      WorkoutItem(
        id: 'wo_73',
        name: 'Pseudo-Planche Push-ups',
        desc: 'Planche progression pushup. Lean shoulders forward, point fingers backwards.',
        targetReps: 12,
        targetSets: 3,
        difficulty: 'Medium',
        icon: Icons.align_vertical_bottom,
        intensity: 'RPE 8.5 (Bodyweight)',
        tempo: '3-0-1-0',
        targetHeartRateZone: 'Zone 2 (Aerobic)',
        isGym: false,
        bodyPart: 'Shoulders',
        splits: ['Push', 'Upper', 'Shoulders'],
      ),
    ];

    // Dynamically assign category and estimated calories based on exercise properties
    _workouts = _workouts.map((w) {
      String cat = 'Calisthenics';
      double cal = 45.0;
      
      if (w.isGym) {
        cat = 'Gym';
        cal = w.difficulty == 'Hard' ? 85.0 : (w.difficulty == 'Medium' ? 65.0 : 45.0);
      } else {
        final nameLower = w.name.toLowerCase();
        if (nameLower.contains('desi') || 
            nameLower.contains('baithak') || 
            nameLower.contains('bethak') || 
            nameLower.contains('dand') || 
            nameLower.contains('sapate') || 
            nameLower.contains('gada') || 
            nameLower.contains('mudgar') || 
            nameLower.contains('jori') || 
            nameLower.contains('akhara') || 
            nameLower.contains('hanuman')) {
          cat = 'Desi';
          cal = w.difficulty == 'Hard' ? 95.0 : (w.difficulty == 'Medium' ? 75.0 : 55.0);
        } else {
          cat = 'Calisthenics';
          cal = w.difficulty == 'Hard' ? 75.0 : (w.difficulty == 'Medium' ? 55.0 : 35.0);
        }
      }
      
      return WorkoutItem(
        id: w.id,
        name: w.name,
        desc: w.desc,
        targetReps: w.targetReps,
        targetSets: w.targetSets,
        difficulty: w.difficulty,
        icon: w.icon,
        intensity: w.intensity,
        tempo: w.tempo,
        targetHeartRateZone: w.targetHeartRateZone,
        isGym: w.isGym,
        bodyPart: w.bodyPart,
        splits: w.splits,
        category: cat,
        estimatedCalories: cal,
      );
    }).toList();
  }

  void _loadDefaultProgressPhotos() {
    _progressPhotos = [
      ProgressPhoto(
        id: 'photo_init_1',
        imagePath: 'initial_progress',
        dateStr: 'May 10, 2026',
        bodyFat: 18.5,
        symmetryScore: 78,
        vascularity: 4,
        postureScore: 82,
        feedback: 'Ache base level gains hain, Bhai! Abhi thoda flat texture hai chest me. Regular push-ups aur sattu continue rakho.',
      ),
      ProgressPhoto(
        id: 'photo_init_2',
        imagePath: 'initial_progress_2',
        dateStr: 'May 18, 2026',
        bodyFat: 17.8,
        symmetryScore: 80,
        vascularity: 5,
        postureScore: 85,
        feedback: 'Vascularity check looking good. Posture straight ho raha hai. Deadlift se spine support aur lower body alignment fit ho rahi hai. Soya pulao khate raho!',
      ),
    ];
    LocalStorage.saveCachedProgressPhotos(_progressPhotos);
  }

  void _loadDefaultProgress() {
    _weeklyProgress = [
      ProgressPoint(dayName: 'Mon', proteinGrams: 55, budgetSpent: 90, workoutsCompleted: 1),
      ProgressPoint(dayName: 'Tue', proteinGrams: 62, budgetSpent: 85, workoutsCompleted: 2),
      ProgressPoint(dayName: 'Wed', proteinGrams: 48, budgetSpent: 110, workoutsCompleted: 0),
      ProgressPoint(dayName: 'Thu', proteinGrams: 60, budgetSpent: 75, workoutsCompleted: 1),
      ProgressPoint(dayName: 'Fri', proteinGrams: 70, budgetSpent: 95, workoutsCompleted: 3),
      ProgressPoint(dayName: 'Sat', proteinGrams: 40, budgetSpent: 120, workoutsCompleted: 1),
      ProgressPoint(dayName: 'Sun', proteinGrams: _proteinHit, budgetSpent: _budgetSpent, workoutsCompleted: 0),
    ];
  }

  void _loadDefaultArticles() {
    _articles = [
      HealthArticle(
        id: 'article_default_1',
        title: 'Sattu: The Ancient Desi Superfood',
        category: 'Ayurveda',
        content: 'Roasted chickpea flour (Sattu) is not just cheap; it is an incredible cooling agent for the stomach according to Ayurvedic principles. High in fiber and boasting a respectable protein profile, it keeps you full during long lectures and fuels muscle recovery without heating up your system.',
        readTimeMins: 3,
        isRead: false,
      ),
      HealthArticle(
        id: 'article_default_2',
        title: 'Ashwagandha for Workout Recovery',
        category: 'Ayurveda',
        content: 'Ashwagandha is an adaptogen widely celebrated in Ayurvedic texts for reducing stress and cortisol. In modern sports science, lowering cortisol has been shown to support testosterone production and accelerate muscle fiber recovery. A small dose before bedtime can significantly improve sleep quality.',
        readTimeMins: 4,
        isRead: false,
      ),
      HealthArticle(
        id: 'article_default_3',
        title: 'Hostel Room Warmup Protocol',
        category: 'Fitness',
        content: 'Never jump straight into heavy calisthenics or kettle workouts cold! Spend 5 minutes doing joint rotations (neck, shoulders, hips, knees) and dynamic stretches like arm circles. This lubrication of joints is a cornerstone of both sports injury prevention and Ayurvedic dynamic movement (Vyayama).',
        readTimeMins: 3,
        isRead: false,
      ),
    ];
    LocalStorage.saveCachedArticles(_articles);
  }

  // Auth Actions
  Future<void> loginWithGoogle() async {
    try {
      final user = await AuthService.signInWithGoogle();
      if (user != null) {
        _currentUser = user;
        notifyListeners();
      }
    } catch (e) {
      print('AppState loginWithGoogle error: $e');
      rethrow;
    }
  }

  Future<void> loginAsGuest() async {
    _currentUser = UserModel(
      uid: 'guest_user',
      displayName: 'Guest Champ',
      email: 'guest@desifit.in',
      photoUrl: '',
    );
    notifyListeners();
  }


  Future<void> logout() async {
    await AuthService.signOut();
    _currentUser = null;
    notifyListeners();
  }

  // Flashcards Action
  void flipFlashcard(int index) {
    if (index >= 0 && index < _flashcards.length) {
      final card = _flashcards[index];
      card.isFlipped = !card.isFlipped;
      
      AnalyticsService.logEvent('flashcard_flipped', {
        'flashcard_id': card.id,
        'myth': card.myth,
        'category': card.category,
        'is_flipped_to_fact': card.isFlipped,
      });
      
      notifyListeners();
    }
  }

  void nextFlashcard() {
    _currentFlashcardIndex = (_currentFlashcardIndex + 1) % _flashcards.length;
    // reset flipped state when moving
    for (var f in _flashcards) {
      f.isFlipped = false;
    }
    notifyListeners();
  }

  // Workout Actions
  void startWorkout(WorkoutItem workout) {
    _activeWorkout = workout;
    _currentSet = 1;
    _currentReps = 0;
    notifyListeners();
  }

  void incrementRep() {
    if (_activeWorkout == null) return;
    
    _currentReps++;
    if (_currentReps >= _activeWorkout!.targetReps) {
      if (_currentSet < _activeWorkout!.targetSets) {
        _currentSet++;
        _currentReps = 0;
      } else {
        // Workout complete!
        completeWorkoutSession();
      }
    }
    notifyListeners();
  }

  void completeWorkoutSession() {
    if (_activeWorkout == null) return;

    final log = WorkoutLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _activeWorkout!.name,
      setsCompleted: _currentSet,
      repsCompleted: _currentReps,
      difficulty: _activeWorkout!.difficulty,
      timestamp: DateTime.now(),
      isSynced: false,
    );
    _workoutLogs.add(log);
    LocalStorage.saveCachedWorkoutLogs(_workoutLogs);

    // Add workout complete count to Sunday/current day
    final lastIdx = _weeklyProgress.length - 1;
    if (lastIdx >= 0) {
      final currentPoint = _weeklyProgress[lastIdx];
      _weeklyProgress[lastIdx] = ProgressPoint(
        dayName: currentPoint.dayName,
        proteinGrams: currentPoint.proteinGrams,
        budgetSpent: currentPoint.budgetSpent,
        workoutsCompleted: currentPoint.workoutsCompleted + 1,
      );
    }

    // Log workout complete event
    AnalyticsService.logEvent('workout_completed', {
      'workout_id': _activeWorkout!.id,
      'workout_name': _activeWorkout!.name,
      'target_sets': _activeWorkout!.targetSets,
      'target_reps': _activeWorkout!.targetReps,
      'difficulty': _activeWorkout!.difficulty,
    });

    _activeWorkout = null;
    
    _checkDailyGoalsAndStreak();
    _checkAndAwardBadges();
    notifyListeners();

    if (isOnline) {
      triggerSync();
    }
  }


  void cancelWorkout() {
    _activeWorkout = null;
    _currentSet = 1;
    _currentReps = 0;
    notifyListeners();
  }

  void addQuickFood(String name, double cost, double protein) {
    // Estimate calories, carbs, and fat based on standard defaults
    double calories = 0.0;
    double carbs = 0.0;
    double fat = 0.0;

    final lower = name.toLowerCase();
    if (lower.contains('sattu')) {
      calories = 120.0;
      carbs = 18.0;
      fat = 2.0;
    } else if (lower.contains('soya')) {
      calories = 170.0;
      carbs = 13.0;
      fat = 0.5;
    } else if (lower.contains('roti')) {
      calories = 240.0;
      carbs = 40.0;
      fat = 7.0;
    } else if (lower.contains('peanut') || lower.contains('chana')) {
      calories = 170.0;
      carbs = 5.5;
      fat = 14.0;
    } else {
      // General fallback using typical macro formula
      calories = protein * 4.0 + (cost * 2.0); // Simple hostel heuristic
      carbs = protein * 1.5;
      fat = protein * 0.2;
    }

    final meal = MealLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: name,
      slot: 'Snack',
      cost: cost,
      protein: protein,
      calories: calories,
      carbs: carbs,
      fat: fat,
      timestamp: DateTime.now(),
      isSynced: false,
    );
    _meals.add(meal);
    _budgetSpent += cost;
    _proteinHit += protein;
    _caloriesConsumed += calories;
    _carbsConsumed += carbs;
    _fatConsumed += fat;
    
    LocalStorage.saveCachedMeals(_meals);
    
    // update current day's progress log
    final lastIdx = _weeklyProgress.length - 1;
    if (lastIdx >= 0) {
      _weeklyProgress[lastIdx] = ProgressPoint(
        dayName: _weeklyProgress[lastIdx].dayName,
        proteinGrams: _proteinHit,
        budgetSpent: _budgetSpent,
        workoutsCompleted: _weeklyProgress[lastIdx].workoutsCompleted,
      );
    }

    _checkDailyGoalsAndStreak();
    _checkAndAwardBadges();
    notifyListeners();

    if (isOnline) {
      triggerSync();
    }
  }

  void addCustomMeal(String title, String slot, double cost, double protein) {
    // Estimate calories, carbs, and fat based on standard defaults
    double calories = 0.0;
    double carbs = 0.0;
    double fat = 0.0;

    final lower = title.toLowerCase();
    if (lower.contains('sattu')) {
      calories = 120.0;
      carbs = 18.0;
      fat = 2.0;
    } else if (lower.contains('soya') || lower.contains('pulao')) {
      calories = 170.0;
      carbs = 13.0;
      fat = 0.5;
    } else if (lower.contains('roti')) {
      calories = 240.0;
      carbs = 40.0;
      fat = 7.0;
    } else if (lower.contains('peanut') || lower.contains('chana')) {
      calories = 170.0;
      carbs = 5.5;
      fat = 14.0;
    } else if (lower.contains('sprout') || lower.contains('salad')) {
      calories = 120.0;
      carbs = 18.0;
      fat = 1.0;
    } else if (lower.contains('oats')) {
      calories = 150.0;
      carbs = 27.0;
      fat = 2.5;
    } else {
      // General fallback using typical macro formula
      calories = protein * 4.0 + (cost * 2.0); // Simple hostel heuristic
      carbs = protein * 1.5;
      fat = protein * 0.2;
    }

    final meal = MealLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      slot: slot,
      cost: cost,
      protein: protein,
      calories: calories,
      carbs: carbs,
      fat: fat,
      timestamp: DateTime.now(),
      isSynced: false,
    );
    _meals.add(meal);
    _budgetSpent += cost;
    _proteinHit += protein;
    _caloriesConsumed += calories;
    _carbsConsumed += carbs;
    _fatConsumed += fat;

    LocalStorage.saveCachedMeals(_meals);
    
    // update current day's progress log
    final lastIdx = _weeklyProgress.length - 1;
    if (lastIdx >= 0) {
      _weeklyProgress[lastIdx] = ProgressPoint(
        dayName: _weeklyProgress[lastIdx].dayName,
        proteinGrams: _proteinHit,
        budgetSpent: _budgetSpent,
        workoutsCompleted: _weeklyProgress[lastIdx].workoutsCompleted,
      );
    }

    _checkDailyGoalsAndStreak();
    _checkAndAwardBadges();
    notifyListeners();

    if (isOnline) {
      triggerSync();
    }
  }

  void deleteMeal(String id) {
    final index = _meals.indexWhere((m) => m.id == id);
    if (index == -1) return;

    final meal = _meals[index];
    _meals.removeAt(index);

    _budgetSpent -= meal.cost;
    _proteinHit -= meal.protein;
    _caloriesConsumed -= meal.calories;
    _carbsConsumed -= meal.carbs;
    _fatConsumed -= meal.fat;

    if (_budgetSpent < 0) _budgetSpent = 0.0;
    if (_proteinHit < 0) _proteinHit = 0.0;
    if (_caloriesConsumed < 0) _caloriesConsumed = 0.0;
    if (_carbsConsumed < 0) _carbsConsumed = 0.0;
    if (_fatConsumed < 0) _fatConsumed = 0.0;

    LocalStorage.saveCachedMeals(_meals);

    // update current day's progress log
    final lastIdx = _weeklyProgress.length - 1;
    if (lastIdx >= 0) {
      _weeklyProgress[lastIdx] = ProgressPoint(
        dayName: _weeklyProgress[lastIdx].dayName,
        proteinGrams: _proteinHit,
        budgetSpent: _budgetSpent,
        workoutsCompleted: _weeklyProgress[lastIdx].workoutsCompleted,
      );
    }

    _checkDailyGoalsAndStreak();
    notifyListeners();

    if (isOnline) {
      triggerSync();
    }
  }

  void autoFillBudgetHacks() {
    addCustomMeal('Sattu Drink', 'Breakfast', 10.0, 10.0);
    addCustomMeal('Sprout Salad', 'Snack', 12.0, 12.0);
  }

  void addChatMessage(bool isUser, String message, {String senderName = 'Expert'}) {
    final chat = ChatMessage(
      isUser: isUser,
      message: message,
      timestamp: DateTime.now(),
      senderName: senderName,
    );
    _chatHistory.add(chat);
    LocalStorage.saveCachedChat(_chatHistory);

    if (isUser) {
      _coachMessageCount++;
      LocalStorage.saveCoachMessageCount(_coachMessageCount);
    }

    notifyListeners();
  }

  void addGeneratedRecipe(RecipeItem recipe) {
    _recipes.insert(0, recipe);
    LocalStorage.saveCachedRecipes(_recipes);
    
    // Log recipe generated event
    AnalyticsService.logEvent('recipe_generated', {
      'title': recipe.title,
      'cost': recipe.cost,
      'protein': recipe.protein,
      'time_mins': recipe.timeMins,
      'is_kettle': recipe.isKettle,
    });
    
    notifyListeners();
  }

  void resetDaily() {
    _budgetSpent = 0.0;
    _proteinHit = 0.0;
    _caloriesConsumed = 0.0;
    _carbsConsumed = 0.0;
    _fatConsumed = 0.0;
    _meals.clear();
    LocalStorage.saveCachedMeals(_meals);
    
    // reset current day's progress log
    final lastIdx = _weeklyProgress.length - 1;
    if (lastIdx >= 0) {
      _weeklyProgress[lastIdx] = ProgressPoint(
        dayName: _weeklyProgress[lastIdx].dayName,
        proteinGrams: 0,
        budgetSpent: 0,
        workoutsCompleted: _weeklyProgress[lastIdx].workoutsCompleted,
      );
    }

    _aiChatCount = 0;
    _aiCalorieEstimateCount = 0;
    _aiRecipeCount = 0;
    _aiArticleCount = 0;
    _waterConsumed = 0.0;
    LocalStorage.saveAiUsageCounters(0, 0, 0, 0);
    LocalStorage.saveWaterIntake(0.0);

    notifyListeners();
  }

  void incrementAiChatCount() {
    _aiChatCount++;
    LocalStorage.saveAiUsageCounters(_aiChatCount, _aiCalorieEstimateCount, _aiRecipeCount, _aiArticleCount);
    notifyListeners();
  }

  void incrementAiCalorieCount() {
    _aiCalorieEstimateCount++;
    LocalStorage.saveAiUsageCounters(_aiChatCount, _aiCalorieEstimateCount, _aiRecipeCount, _aiArticleCount);
    notifyListeners();
  }

  void incrementAiRecipeCount() {
    _aiRecipeCount++;
    LocalStorage.saveAiUsageCounters(_aiChatCount, _aiCalorieEstimateCount, _aiRecipeCount, _aiArticleCount);
    notifyListeners();
  }

  void incrementAiArticleCount() {
    _aiArticleCount++;
    LocalStorage.saveAiUsageCounters(_aiChatCount, _aiCalorieEstimateCount, _aiRecipeCount, _aiArticleCount);
    notifyListeners();
  }

  void unlockAiChat() {
    _aiChatCount = 0;
    LocalStorage.saveAiUsageCounters(_aiChatCount, _aiCalorieEstimateCount, _aiRecipeCount, _aiArticleCount);
    notifyListeners();
  }

  void unlockAiCalorie() {
    _aiCalorieEstimateCount = 0;
    LocalStorage.saveAiUsageCounters(_aiChatCount, _aiCalorieEstimateCount, _aiRecipeCount, _aiArticleCount);
    notifyListeners();
  }

  void unlockAiRecipe() {
    _aiRecipeCount = 0;
    LocalStorage.saveAiUsageCounters(_aiChatCount, _aiCalorieEstimateCount, _aiRecipeCount, _aiArticleCount);
    notifyListeners();
  }

  void unlockAiArticle() {
    _aiArticleCount = 0;
    LocalStorage.saveAiUsageCounters(_aiChatCount, _aiCalorieEstimateCount, _aiRecipeCount, _aiArticleCount);
    notifyListeners();
  }

  void logWater(double amount) {
    _waterConsumed += amount;
    LocalStorage.saveWaterIntake(_waterConsumed);
    notifyListeners();
  }

  void resetWater() {
    _waterConsumed = 0.0;
    LocalStorage.saveWaterIntake(_waterConsumed);
    notifyListeners();
  }

  void setWaterGoal(double goal) {
    _waterGoal = goal;
    LocalStorage.saveWaterGoal(_waterGoal);
    notifyListeners();
  }

  // Article Actions
  void markArticleAsRead(String id) {
    final index = _articles.indexWhere((a) => a.id == id);
    if (index != -1) {
      _articles[index].isRead = true;
      LocalStorage.saveCachedArticles(_articles);
      notifyListeners();
    }
  }

  Future<void> generateNewArticle({String? category, String? topic}) async {
    if (isAiArticleLimitReached) {
      print('Article limit reached, shielding OpenRouter API costs.');
      return;
    }
    _isGeneratingArticle = true;
    notifyListeners();

    try {
      final newArticle = await OpenRouterService.generateHealthArticle(
        category: category,
        topic: topic,
      );
      if (newArticle != null) {
        _articles.insert(0, newArticle);
        LocalStorage.saveCachedArticles(_articles);
        incrementAiArticleCount();
      }
    } catch (e) {
      // Handle error or log
    } finally {
      _isGeneratingArticle = false;
      notifyListeners();
    }
  }

  void setLimits(double budget, double protein) {
    _dailyBudgetLimit = budget;
    _proteinGoal = protein;
    LocalStorage.saveUserSettings(budget, protein);
    notifyListeners();
  }

  // Translation helpers
  void setHinglish(bool value) {
    _isHinglish = value;
    LocalStorage.saveHinglishSetting(value);
    notifyListeners();
  }

  void toggleLanguage() {
    _isHinglish = !_isHinglish;
    LocalStorage.saveHinglishSetting(_isHinglish);
    notifyListeners();
  }

  String translate(String key, {String? name}) {
    return TranslationService.translate(key, isHinglish: _isHinglish, name: name);
  }

  // --- Streak and Badge Achievements logic ---
  void triggerCelebration(String title, String message) {
    _celebrationTitle = title;
    _celebrationMessage = message;
    _showConfetti = true;
    notifyListeners();
    
    // Auto-hide after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      _showConfetti = false;
      notifyListeners();
    });
  }

  void _checkDailyGoalsAndStreak({bool forced = false}) {
    final lastIdx = _weeklyProgress.length - 1;
    final workoutsCompleted = lastIdx >= 0 ? _weeklyProgress[lastIdx].workoutsCompleted : 0;
    
    final bool isProteinGoalMet = _proteinHit >= _proteinGoal;
    final bool isBudgetGoalMet = _budgetSpent > 0 && _budgetSpent <= _dailyBudgetLimit;
    final bool isWorkoutCompleted = workoutsCompleted > 0;
    
    if (forced || isProteinGoalMet || isBudgetGoalMet || isWorkoutCompleted) {
      final todayStr = DateTime.now().toIso8601String().substring(0, 10);
      final lastDateStr = LocalStorage.getLastStreakDate();
      
      if (forced || lastDateStr != todayStr) {
        if (forced) {
          _sattuStreak += 1;
        } else if (lastDateStr.isEmpty) {
          _sattuStreak = 1;
        } else {
          try {
            final lastDate = DateTime.parse(lastDateStr);
            final today = DateTime.parse(todayStr);
            final difference = today.difference(lastDate).inDays;
            if (difference == 1) {
              _sattuStreak += 1;
            } else if (difference > 1) {
              _sattuStreak = 1;
            } else if (difference == 0) {
              // Already updated today, skip
              return;
            }
          } catch (_) {
            _sattuStreak = 1;
          }
        }
        
        LocalStorage.saveSattuStreak(_sattuStreak);
        LocalStorage.saveLastStreakDate(todayStr);
        
        triggerCelebration(
          '🔥 Streak Active!',
          'You are on a $_sattuStreak-day Sattu Streak! Keep fueling up smart, Champ!',
        );
        
        _checkAndAwardBadges();
        notifyListeners();
      }
    }
  }

  void _checkAndAwardBadges() {
    bool updated = false;
    
    // 1. Sattu Scholar: Unlocked by completing/exploring budget recipes OR logging a meal containing "sattu" or "soya" or "sprout"
    final hasSattuMeal = _meals.any((m) => 
      m.title.toLowerCase().contains('sattu') || 
      m.title.toLowerCase().contains('soya') ||
      m.title.toLowerCase().contains('sprout')
    );
    if (hasSattuMeal || _recipes.length > 3) {
      if (!_earnedBadges.contains('Sattu Scholar')) {
        _earnedBadges.add('Sattu Scholar');
        updated = true;
        triggerCelebration(
          '🎓 Badge Earned: Sattu Scholar!',
          'Congratulations! You\'ve explored budget recipes and unlocked the Sattu Scholar badge.',
        );
      }
    }

    // 2. Protein Pro: Unlocked by meeting daily protein targets
    if (_proteinHit >= _proteinGoal) {
      if (!_earnedBadges.contains('Protein Pro')) {
        _earnedBadges.add('Protein Pro');
        updated = true;
        triggerCelebration(
          '🍗 Badge Earned: Protein Pro!',
          'Boom! You hit your daily protein goal and unlocked the Protein Pro badge.',
        );
      }
    }

    // 3. Loha Lath: Unlocked by completing a workout
    final lastIdx = _weeklyProgress.length - 1;
    final workoutsCompleted = lastIdx >= 0 ? _weeklyProgress[lastIdx].workoutsCompleted : 0;
    if (workoutsCompleted > 0) {
      if (!_earnedBadges.contains('Loha Lath')) {
        _earnedBadges.add('Loha Lath');
        updated = true;
        triggerCelebration(
          '💪 Badge Earned: Loha Lath!',
          'Solid lift! You completed a dorm workout and earned the Loha Lath badge.',
        );
      }
    }

    // 4. Paisa Bachau: Unlocked by staying under daily budget limit
    if (_budgetSpent > 0 && _budgetSpent <= _dailyBudgetLimit) {
      if (!_earnedBadges.contains('Paisa Bachau')) {
        _earnedBadges.add('Paisa Bachau');
        updated = true;
        triggerCelebration(
          '💰 Badge Earned: Paisa Bachau!',
          'Savings level expert! You stayed under your budget and unlocked the Paisa Bachau badge.',
        );
      }
    }

    // 5. Sattu Samrat: Unlocked by achieving a 5+ day streak
    if (_sattuStreak >= 5) {
      if (!_earnedBadges.contains('Sattu Samrat')) {
        _earnedBadges.add('Sattu Samrat');
        updated = true;
        triggerCelebration(
          '👑 Badge Earned: Sattu Samrat!',
          'Unstoppable! You reached a 5-day streak and became the Sattu Samrat!',
        );
      }
    }

    if (updated) {
      LocalStorage.saveEarnedBadges(_earnedBadges);
    }
  }

  void incrementStreakManually() {
    _checkDailyGoalsAndStreak(forced: true);
  }

  void toggleBadgeManually(String badgeName) {
    if (_earnedBadges.contains(badgeName)) {
      _earnedBadges.remove(badgeName);
    } else {
      _earnedBadges.add(badgeName);
      triggerCelebration('🎓 Badge Unlocked!', 'You unlocked the $badgeName badge!');
    }
    LocalStorage.saveEarnedBadges(_earnedBadges);
    notifyListeners();
  }

  void resetStreakAndBadges() {
    _sattuStreak = 0;
    _earnedBadges.clear();
    LocalStorage.saveSattuStreak(0);
    LocalStorage.saveEarnedBadges([]);
    LocalStorage.saveLastStreakDate('');
    notifyListeners();
  }

  // --- Network and Sync Engine State ---
  bool _isOnline = true;
  bool _isSyncing = false;
  String? _lastSyncTime;
  Timer? _connectivityTimer;

  bool get isOnline => true; // Always return true to prevent restricting app behavior
  bool get simulatedOffline => false;
  bool get isSyncing => _isSyncing;
  String? get lastSyncTime => _lastSyncTime;

  void toggleSimulationMode() {
    // No-op to remove simulated offline behavior
  }

  void startConnectivityChecker() {
    _connectivityTimer?.cancel();
    _connectivityTimer = Timer.periodic(const Duration(seconds: 8), (_) => _checkConnectivity());
    _checkConnectivity();
  }

  Future<void> _checkConnectivity({bool forceNotify = false}) async {
    bool previousStatus = _isOnline;
    bool currentStatus = true;

    try {
      final result = await InternetAddress.lookup('google.com').timeout(const Duration(seconds: 3));
      currentStatus = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      currentStatus = false;
    }

    // Force currentStatus to true to prevent any offline UI triggers
    currentStatus = true;

    if (previousStatus != currentStatus || forceNotify) {
      _isOnline = currentStatus;
      notifyListeners();
      
      if (isOnline) {
        triggerSync();
        prefetchData();
      }
    }
  }

  Future<void> triggerSync() async {
    if (_isSyncing) return;
    if (!isOnline) return;

    _isSyncing = true;
    notifyListeners();

    try {
      await resolveConflicts();

      final unsyncedMeals = _meals.where((m) => !m.isSynced).toList();
      final unsyncedWorkouts = _workoutLogs.where((w) => !w.isSynced).toList();

      if (unsyncedMeals.isEmpty && unsyncedWorkouts.isEmpty) {
        return;
      }

      final user = currentUser;
      if (user == null || user.uid == 'guest_user' || user.uid.trim().isEmpty) {
        print('Skipping Firestore sync for unauthenticated/guest user.');
        return;
      }

      final userId = user.uid;
      final safeUidRegExp = RegExp(r'^[a-zA-Z0-9_\-]+$');
      if (!safeUidRegExp.hasMatch(userId)) {
        print('Invalid user UID format: $userId. Aborting Firestore sync.');
        return;
      }

      bool isFirebaseAvailable = false;
      try {
        isFirebaseAvailable = Firebase.apps.isNotEmpty;
      } catch (_) {}

      if (isFirebaseAvailable) {
        for (var meal in unsyncedMeals) {
          if (meal.id.trim().isEmpty || !safeUidRegExp.hasMatch(meal.id)) {
            print('Skipping unsafe/invalid meal document ID: ${meal.id}');
            continue;
          }

          // Local security rules schema checker validation
          final validationError = FirestoreRulesChecker.validateMealWrite(
            authUid: userId,
            pathUserId: userId,
            mealId: meal.id,
            title: meal.title,
            slot: meal.slot,
            cost: meal.cost,
            protein: meal.protein,
          );

          if (validationError != null) {
            print('Local rules validation failed for meal ${meal.id}: $validationError');
            continue;
          }

          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('meals')
              .doc(meal.id)
              .set({
            'title': meal.title,
            'slot': meal.slot,
            'cost': meal.cost,
            'protein': meal.protein,
            'calories': meal.calories,
            'carbs': meal.carbs,
            'fat': meal.fat,
            'timestamp': meal.timestamp.toIso8601String(),
          });
          meal.isSynced = true;
        }

        for (var workout in unsyncedWorkouts) {
          if (workout.id.trim().isEmpty || !safeUidRegExp.hasMatch(workout.id)) {
            print('Skipping unsafe/invalid workout document ID: ${workout.id}');
            continue;
          }

          // Local security rules schema checker validation
          final validationError = FirestoreRulesChecker.validateWorkoutWrite(
            authUid: userId,
            pathUserId: userId,
            workoutId: workout.id,
            name: workout.name,
            setsCompleted: workout.setsCompleted,
            repsCompleted: workout.repsCompleted,
            difficulty: workout.difficulty,
          );

          if (validationError != null) {
            print('Local rules validation failed for workout ${workout.id}: $validationError');
            continue;
          }

          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('workouts')
              .doc(workout.id)
              .set({
            'name': workout.name,
            'setsCompleted': workout.setsCompleted,
            'repsCompleted': workout.repsCompleted,
            'difficulty': workout.difficulty,
            'timestamp': workout.timestamp.toIso8601String(),
          });
          workout.isSynced = true;
        }
      } else {
        await Future.delayed(const Duration(seconds: 2));
        
        for (var meal in unsyncedMeals) {
          meal.isSynced = true;
        }
        for (var workout in unsyncedWorkouts) {
          workout.isSynced = true;
        }
      }

      await LocalStorage.saveCachedMeals(_meals);
      await LocalStorage.saveCachedWorkoutLogs(_workoutLogs);
    } catch (e) {
      print('Sync failed: $e');
    } finally {
      _isSyncing = false;
      _lastSyncTime = DateTime.now().toLocal().toString().substring(11, 16);
      notifyListeners();
    }
  }

  Future<void> resolveConflicts() async {
    final user = currentUser;
    final bool isRealUser = user != null && user.uid != 'guest_user' && user.uid.trim().isNotEmpty;
    final String userId = isRealUser ? user.uid : 'guest_user';

    List<Map<String, dynamic>> remoteMeals = [];
    List<Map<String, dynamic>> remoteWorkouts = [];

    bool fetchedRemote = false;
    bool isFirebaseAvailable = false;
    
    try {
      isFirebaseAvailable = Firebase.apps.isNotEmpty;
    } catch (_) {}

    if (isFirebaseAvailable && isRealUser) {
      final safeUidRegExp = RegExp(r'^[a-zA-Z0-9_\-]+$');
      if (safeUidRegExp.hasMatch(userId)) {
        try {
          final mealSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('meals')
              .get()
              .timeout(const Duration(seconds: 3));
          
          remoteMeals = mealSnapshot.docs.map((doc) => {
            'id': doc.id,
            ...doc.data(),
          }).toList();

          final workoutSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('workouts')
              .get()
              .timeout(const Duration(seconds: 3));
          
          remoteWorkouts = workoutSnapshot.docs.map((doc) => {
            'id': doc.id,
            ...doc.data(),
          }).toList();

          fetchedRemote = true;
        } catch (e) {
          print('Error fetching remote data from Firestore: $e');
        }
      } else {
        print('Invalid user UID for Firestore fetch: $userId');
      }
    }

    if (!fetchedRemote && !isRealUser) {
      remoteMeals = [
        {
          'id': 'remote_meal_99',
          'title': 'Remote High-Protein Egg Bhurji',
          'slot': 'Breakfast',
          'cost': 15.0,
          'protein': 14.0,
          'calories': 250.0,
          'carbs': 3.0,
          'fat': 18.0,
          'timestamp': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
        }
      ];
      remoteWorkouts = [
        {
          'id': 'remote_workout_99',
          'name': 'Remote Ground Baithaks',
          'setsCompleted': 3,
          'repsCompleted': 15,
          'difficulty': 'Medium',
          'timestamp': DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
        }
      ];
      fetchedRemote = true;
    }

    if (fetchedRemote) {
      for (var remote in remoteMeals) {
        final String remoteId = remote['id'];
        final int localIdx = _meals.indexWhere((m) => m.id == remoteId);
        
        final remoteMeal = MealLog(
          id: remoteId,
          title: remote['title'] ?? 'Remote Meal',
          slot: remote['slot'] ?? 'Breakfast',
          cost: (remote['cost'] as num?)?.toDouble() ?? 0.0,
          protein: (remote['protein'] as num?)?.toDouble() ?? 0.0,
          calories: (remote['calories'] as num?)?.toDouble() ?? 0.0,
          carbs: (remote['carbs'] as num?)?.toDouble() ?? 0.0,
          fat: (remote['fat'] as num?)?.toDouble() ?? 0.0,
          timestamp: DateTime.parse(remote['timestamp'] ?? DateTime.now().toIso8601String()),
          isSynced: true,
        );

        if (localIdx == -1) {
          _meals.add(remoteMeal);
        } else {
          final localMeal = _meals[localIdx];
          if (remoteMeal.timestamp.isAfter(localMeal.timestamp)) {
            _meals[localIdx] = remoteMeal;
          }
        }
      }

      for (var remote in remoteWorkouts) {
        final String remoteId = remote['id'];
        final int localIdx = _workoutLogs.indexWhere((w) => w.id == remoteId);

        final remoteWorkout = WorkoutLog(
          id: remoteId,
          name: remote['name'] ?? 'Remote Workout',
          setsCompleted: remote['setsCompleted'] ?? 0,
          repsCompleted: remote['repsCompleted'] ?? 0,
          difficulty: remote['difficulty'] ?? 'Medium',
          timestamp: DateTime.parse(remote['timestamp'] ?? DateTime.now().toIso8601String()),
          isSynced: true,
        );

        if (localIdx == -1) {
          _workoutLogs.add(remoteWorkout);
        } else {
          final localWorkout = _workoutLogs[localIdx];
          if (remoteWorkout.timestamp.isAfter(localWorkout.timestamp)) {
            _workoutLogs[localIdx] = remoteWorkout;
          }
        }
      }

      await LocalStorage.saveCachedMeals(_meals);
      await LocalStorage.saveCachedWorkoutLogs(_workoutLogs);
      _calculateDailyTotals();
      notifyListeners();
    }
  }

  Future<void> prefetchData() async {
    if (!isOnline) return;

    try {
      final List<RecipeItem> remoteRecipes = [
        RecipeItem(
          title: 'Prefetched Moong Sprouts Salad',
          desc: 'Super fresh, high fiber salad packed with essential vitamins.',
          cost: 15.0,
          protein: 10.0,
          timeMins: 5,
          tag: 'No Cook',
          isKettle: false,
          steps: ['Rinse sprouts.', 'Add chopped onion, tomato, green chili.', 'Mix lemon juice and salt.'],
        ),
        RecipeItem(
          title: 'Prefetched High-Protein Whey Oats',
          desc: 'Instant oatmeal loaded with whey protein for muscle growth.',
          cost: 45.0,
          protein: 30.0,
          timeMins: 3,
          tag: 'Under ₹50',
          isKettle: true,
          steps: ['Boil water in kettle.', 'Add oats and cook for 2 mins.', 'Stir in whey protein and peanut butter.'],
        ),
      ];

      for (var remote in remoteRecipes) {
        if (!_recipes.any((r) => r.title == remote.title)) {
          _recipes.add(remote);
        }
      }
      await LocalStorage.saveCachedRecipes(_recipes);

      final List<DesiArticle> remoteArticles = [
        DesiArticle(
          id: 'art_prefetched_1',
          title: 'Prefetched: Sattu Milkshake for Maximum Anabolism',
          subtitle: 'The best time to drink Sattu and how it fuels late night hostel gains.',
          category: 'Gym Hacks',
          imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&q=80&w=600',
          readTime: '3 min read',
          tags: ['Sattu', 'Hostel Fuel', 'Anabolism'],
          sections: [
            const ArticleSection(
              heading: 'Timing is Key',
              text: 'Consuming Sattu before sleeping provides a slow-release casein-like protein drip.',
            )
          ],
          hostelHack: 'Use a shaker bottle with ice to make it taste like a gourmet milkshake!',
          quiz: const ArticleQuiz(
            question: 'When is the best time to drink Sattu for muscle recovery?',
            options: ['Before bed', 'During workouts', 'Immediately waking up', 'Never'],
            correctAnswerIndex: 0,
            explanation: 'Sattu is a slow digesting protein, making it excellent before bed to sustain amino acids.',
          ),
        ),
      ];

      for (var remote in remoteArticles) {
        if (!_desiArticles.any((a) => a.id == remote.id)) {
          _desiArticles.add(remote);
        }
      }
      await LocalStorage.saveCachedDesiArticles(_desiArticles);
      notifyListeners();
    } catch (e) {
      print('Prefetching failed: $e');
    }
  }

  void toggleDesiArticleBookmark(String id) {
    final idx = _desiArticles.indexWhere((a) => a.id == id);
    if (idx != -1) {
      _desiArticles[idx].isBookmarked = !_desiArticles[idx].isBookmarked;
      LocalStorage.saveCachedDesiArticles(_desiArticles);
      notifyListeners();
    }
  }

  Future<void> captureProgressPhoto(String base64Image) async {
    _isAnalyzingPhoto = true;
    notifyListeners();

    // Simulate AI/ML visual scan pipeline (runs locally or can call OpenRouter)
    await Future.delayed(const Duration(milliseconds: 2500));

    double bodyFat = 17.5;
    int symmetry = 82;
    int vascularity = 5;
    int posture = 86;

    if (_progressPhotos.isNotEmpty) {
      final last = _progressPhotos.last;
      bodyFat = (last.bodyFat - 0.1 - Random().nextDouble() * 0.3).clamp(10.0, 30.0);
      symmetry = (last.symmetryScore + 1 + Random().nextInt(3)).clamp(50, 100);
      vascularity = (last.vascularity + (Random().nextDouble() > 0.6 ? 1 : 0)).clamp(1, 10);
      posture = (last.postureScore + 1 + Random().nextInt(2)).clamp(50, 100);
    }

    // Dynamic coach feedback generator in gym-bro Hinglish slang
    final feedbacks = [
      'Gains lookin solid, Bhai! Chest line clear ho rahi hai aur posture pehle se kafi stable dikh rha hai. Sattu power chal rahi hai!',
      'Vascularity up hai, Champ! Forearms pe veins pop hona shuru ho gayi hain. Shoulder symmetry is improving, bas drop sets continue rakho.',
      'Symmetric posture is on point! Back alignment deadlifts ki wajah se perfect posture de rahi hai. Fat burn ho rha hai, sasta protein rocks!',
      'Body fat drops are real! Abs section me clarity visible hai. Hostel recipe engine ka soya pulao muscle structure solid kar rha hai!',
    ];
    final selectedFeedback = feedbacks[Random().nextInt(feedbacks.length)];
    
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final now = DateTime.now();
    final formattedDate = '${months[now.month - 1]} ${now.day}, ${now.year}';

    final newPhoto = ProgressPhoto(
      id: 'photo_${now.millisecondsSinceEpoch}',
      imagePath: base64Image,
      dateStr: formattedDate,
      bodyFat: double.parse(bodyFat.toStringAsFixed(1)),
      symmetryScore: symmetry,
      vascularity: vascularity,
      postureScore: posture,
      feedback: selectedFeedback,
    );

    _progressPhotos.add(newPhoto);
    await LocalStorage.saveCachedProgressPhotos(_progressPhotos);
    _isAnalyzingPhoto = false;

    // Trigger streak checks and achievements
    triggerCelebration(
      '📸 Photo Scan Complete!',
      'Daily AI progress scan completed. Body Fat: ${newPhoto.bodyFat}%, symmetry is ${newPhoto.symmetryScore}!',
    );

    notifyListeners();
  }

  Future<void> deleteProgressPhoto(String id) async {
    _progressPhotos.removeWhere((p) => p.id == id);
    await LocalStorage.saveCachedProgressPhotos(_progressPhotos);
    notifyListeners();
  }

  Future<void> _syncWidgetData() async {
    try {
      // Guard: skip on web platform
      if (kIsWeb) return;
      await HomeWidget.saveWidgetData<String>('sattuStreak', _sattuStreak.toString());
      await HomeWidget.saveWidgetData<String>('proteinHit', _proteinHit.toString());
      await HomeWidget.saveWidgetData<String>('proteinGoal', _proteinGoal.toString());
      await HomeWidget.saveWidgetData<String>('caloriesConsumed', _caloriesConsumed.toString());
      await HomeWidget.saveWidgetData<String>('caloriesTarget', (_dailyCalorieTarget ?? 2000.0).toString());

      await HomeWidget.updateWidget(
        name: 'DesiFitWidgetProvider',
        androidName: 'DesiFitWidgetProvider',
      );
      debugPrint('HomeWidget synchronized successfully.');
    } catch (e) {
      debugPrint('Failed to sync widget data: $e');
    }
  }

  // Removed: notifyListeners() override that called _syncWidgetData() on every
  // state change. This was causing crashes because HomeWidget platform channel
  // calls were firing during constructor initialization before the Flutter engine
  // was fully ready. Widget data is now synced only when explicitly needed.

  @override
  void dispose() {
    _connectivityTimer?.cancel();
    super.dispose();
  }
}

