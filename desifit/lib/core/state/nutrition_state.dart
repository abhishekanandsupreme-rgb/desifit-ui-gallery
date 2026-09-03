import 'package:flutter/foundation.dart';
import '../storage/local_storage.dart';
import 'models.dart';

class NutritionState extends ChangeNotifier {
  // Budget & Protein Metrics
  double _dailyBudgetLimit = 100.0;
  double _budgetSpent = 0.0;
  double _proteinGoal = 60.0;
  double _proteinHit = 0.0;
  double _caloriesConsumed = 0.0;
  double _carbsConsumed = 0.0;
  double _fatConsumed = 0.0;
  double _waterConsumed = 0.0;
  double _waterGoal = 2000.0;

  // Getters
  double get dailyBudgetLimit => _dailyBudgetLimit;
  double get budgetSpent => _budgetSpent;
  double get budgetLeft => (_dailyBudgetLimit - _budgetSpent).clamp(0.0, _dailyBudgetLimit);
  double get proteinGoal => _proteinGoal;
  double get proteinHit => _proteinHit;
  double get caloriesConsumed => _caloriesConsumed;
  double get carbsConsumed => _carbsConsumed;
  double get fatConsumed => _fatConsumed;
  double get caloriesRemaining => ((_dailyCalorieTarget ?? 2000) - _caloriesConsumed).clamp(0.0, (_dailyCalorieTarget ?? 2000));
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

  double? get userWeight => _userWeight;
  double? get userHeight => _userHeight;
  double? get userBmi => _userBmi;
  String? get bmiCategory => _bmiCategory;
  String? get bodyGoal => _bodyGoal;
  double? get dailyCalorieTarget => _dailyCalorieTarget;
  String? get selectedWorkoutSplit => _selectedWorkoutSplit;

  // Meals list
  List<MealLog> _meals = [];
  List<MealLog> get meals => _meals;

  // Callbacks to other states
  VoidCallback? _onDailyGoalsChanged;
  List<ProgressPoint> Function()? _getWeeklyProgress;

  void setCallbacks({
    required List<ProgressPoint> Function() getWeeklyProgress,
    required void Function() onDailyGoalsChanged,
  }) {
    _getWeeklyProgress = getWeeklyProgress;
    _onDailyGoalsChanged = onDailyGoalsChanged;
  }

  void initFromCache({
    required List<MealLog> meals,
    required double dailyBudgetLimit,
    required double proteinGoal,
  }) {
    _meals = meals;
    _dailyBudgetLimit = dailyBudgetLimit;
    _proteinGoal = proteinGoal;
    _calculateDailyTotals();
  }

  void loadBodyMetrics(Map<String, dynamic> metrics) {
    _userWeight = metrics['user_weight'] != null ? (metrics['user_weight'] as num).toDouble() : null;
    _userHeight = metrics['user_height'] != null ? (metrics['user_height'] as num).toDouble() : null;
    _bodyGoal = metrics['body_goal'] as String?;
    _userBmi = metrics['user_bmi'] != null ? (metrics['user_bmi'] as num).toDouble() : null;
    _bmiCategory = metrics['bmi_category'] as String?;
    _dailyCalorieTarget = metrics['daily_calorie_target'] != null ? (metrics['daily_calorie_target'] as num).toDouble() : null;
    _selectedWorkoutSplit = metrics['recommended_split'] as String?;
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

  List<ProgressPoint> get weeklyProgress => _getWeeklyProgress?.call() ?? [];

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

    _updateWeeklyProgress(_getWeeklyProgress?.call() ?? []);
    _onDailyGoalsChanged?.call();
    notifyListeners();
  }

  void addQuickFood(String name, double cost, double protein) {
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
      calories = protein * 4.0 + (cost * 2.0);
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
    _updateWeeklyProgress(_getWeeklyProgress?.call() ?? []);
    _onDailyGoalsChanged?.call();
    notifyListeners();
  }

  void addCustomMeal(String title, String slot, double cost, double protein) {
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
      calories = protein * 4.0 + (cost * 2.0);
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
    _updateWeeklyProgress(_getWeeklyProgress?.call() ?? []);
    _onDailyGoalsChanged?.call();
    notifyListeners();
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
    _updateWeeklyProgress(_getWeeklyProgress?.call() ?? []);
    _onDailyGoalsChanged?.call();
    notifyListeners();
  }

  void autoFillBudgetHacks() {
    addCustomMeal('Sattu Drink', 'Breakfast', 10.0, 10.0);
    addCustomMeal('Sprout Salad', 'Snack', 12.0, 12.0);
  }

  void updateBodyMetrics(double weight, double height, String goal) {
    _userWeight = weight;
    _userHeight = height;
    _bodyGoal = goal;

    final heightInMeters = height / 100;
    _userBmi = weight / (heightInMeters * heightInMeters);

    if (_userBmi! < 18.5) {
      _bmiCategory = 'Underweight';
    } else if (_userBmi! < 25.0) {
      _bmiCategory = 'Normal';
    } else if (_userBmi! < 30.0) {
      _bmiCategory = 'Overweight';
    } else {
      _bmiCategory = 'Obese';
    }

    final bmr = 10 * weight + 6.25 * height - 5 * 20 + 5;
    final activeCalories = bmr * 1.375;

    if (goal == 'Fat Loss') {
      _dailyCalorieTarget = activeCalories - 400;
      _proteinGoal = (1.8 * weight).roundToDouble();
      _selectedWorkoutSplit = 'Push/Pull/Legs';
    } else if (goal == 'Muscle Gain') {
      _dailyCalorieTarget = activeCalories + 300;
      _proteinGoal = (2.0 * weight).roundToDouble();
      _selectedWorkoutSplit = 'Push/Pull/Legs';
    } else {
      _dailyCalorieTarget = activeCalories;
      _proteinGoal = (1.5 * weight).roundToDouble();
      _selectedWorkoutSplit = 'Upper/Lower';
    }

    _dailyCalorieTarget = _dailyCalorieTarget!.roundToDouble();

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

  void setLimits(double budget, double protein) {
    _dailyBudgetLimit = budget;
    _proteinGoal = protein;
    LocalStorage.saveUserSettings(budget, protein);
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

  void resetDaily() {
    _budgetSpent = 0.0;
    _proteinHit = 0.0;
    _caloriesConsumed = 0.0;
    _carbsConsumed = 0.0;
    _fatConsumed = 0.0;
    _meals.clear();
    LocalStorage.saveCachedMeals(_meals);
    _waterConsumed = 0.0;
    LocalStorage.saveWaterIntake(0.0);
    notifyListeners();
  }

  void _updateWeeklyProgress(List<ProgressPoint> weeklyProgress) {
    final lastIdx = weeklyProgress.length - 1;
    if (lastIdx >= 0) {
      weeklyProgress[lastIdx] = ProgressPoint(
        dayName: weeklyProgress[lastIdx].dayName,
        proteinGrams: _proteinHit,
        budgetSpent: _budgetSpent,
        workoutsCompleted: weeklyProgress[lastIdx].workoutsCompleted,
      );
    }
  }

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
    FoodNutrition(name: 'Dal/Lentils (Tadka)', servingSize: '1 bowl', calories: 180, protein: 12.0, carbs: 28, fat: 2.0, fiber: 5.0, category: 'Protein'),
    FoodNutrition(name: 'Sprouts Salad', servingSize: '1 cup', calories: 120, protein: 9.0, carbs: 18, fat: 1.0, fiber: 4.0, category: 'Protein'),
    FoodNutrition(name: 'Sattu Powder', servingSize: '2 tbsp (30g)', calories: 100, protein: 6.0, carbs: 15, fat: 1.5, fiber: 3.0, category: 'Protein'),
    FoodNutrition(name: 'Roasted Chana', servingSize: '50g', calories: 180, protein: 11.0, carbs: 30, fat: 3.0, fiber: 6.5, category: 'Protein'),
    FoodNutrition(name: 'Roasted Peanuts', servingSize: '30g handful', calories: 170, protein: 7.5, carbs: 5.5, fat: 14.0, fiber: 2.5, category: 'Protein'),
    // Dairy
    FoodNutrition(name: 'Milk (Toned)', servingSize: '1 glass (250ml)', calories: 120, protein: 8.0, carbs: 12, fat: 4.5, fiber: 0.0, category: 'Dairy'),
    FoodNutrition(name: 'Curd/Dahi', servingSize: '1 cup', calories: 100, protein: 5.0, carbs: 8.0, fat: 5.0, fiber: 0.0, category: 'Dairy'),
    FoodNutrition(name: 'Whey Protein', servingSize: '1 scoop', calories: 120, protein: 24.0, carbs: 3.0, fat: 1.5, fiber: 0.0, category: 'Dairy'),
    // Beverages
    FoodNutrition(name: 'Chai/Tea', servingSize: '1 cup', calories: 50, protein: 1.0, carbs: 7.0, fat: 1.5, fiber: 0.0, category: 'Beverage'),
    FoodNutrition(name: 'Sattu Drink', servingSize: '1 glass', calories: 120, protein: 7.0, carbs: 18, fat: 2.0, fiber: 3.5, category: 'Beverage'),
    FoodNutrition(name: 'Protein Shake', servingSize: '1 glass', calories: 200, protein: 26.0, carbs: 5.0, fat: 3.0, fiber: 1.0, category: 'Beverage'),
  ];
}
