import 'package:hive_flutter/hive_flutter.dart';
import '../state/models.dart';
import '../../features/health_feed/domain/models/article.dart';


class LocalStorage {
  static const String _settingsBox = 'settings';
  static const String _recipesBox = 'recipes_cache';
  static const String _mealsBox = 'meals_cache';
  static const String _chatBox = 'chat_cache';
  static const String _articlesBox = 'articles_cache';
  static const String _workoutLogsBox = 'workout_logs_cache';
  static const String _desiArticlesBox = 'desi_articles_cache';
  static const String _progressPhotosBox = 'progress_photos_cache';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_settingsBox);
    await Hive.openBox(_recipesBox);
    await Hive.openBox(_mealsBox);
    await Hive.openBox(_chatBox);
    await Hive.openBox(_articlesBox);
    await Hive.openBox(_workoutLogsBox);
    await Hive.openBox(_desiArticlesBox);
    await Hive.openBox(_progressPhotosBox);
  }


  // --- User Profile & Settings ---
  static Future<void> saveUserSettings(double budgetLimit, double proteinGoal) async {
    final box = Hive.box(_settingsBox);
    await box.put('budget_limit', budgetLimit);
    await box.put('protein_goal', proteinGoal);
  }

  static Map<String, double> getUserSettings() {
    final box = Hive.box(_settingsBox);
    return {
      'budget_limit': box.get('budget_limit', defaultValue: 100.0) as double,
      'protein_goal': box.get('protein_goal', defaultValue: 60.0) as double,
    };
  }

  static Future<void> saveBodyMetrics({
    required double weight,
    required double height,
    required String goal,
    required double bmi,
    required String bmiCategory,
    required double calorieTarget,
    required String recommendedSplit,
  }) async {
    final box = Hive.box(_settingsBox);
    await box.put('user_weight', weight);
    await box.put('user_height', height);
    await box.put('body_goal', goal);
    await box.put('user_bmi', bmi);
    await box.put('bmi_category', bmiCategory);
    await box.put('daily_calorie_target', calorieTarget);
    await box.put('recommended_split', recommendedSplit);
  }

  static Map<String, dynamic> getBodyMetrics() {
    final box = Hive.box(_settingsBox);
    return {
      'user_weight': box.get('user_weight'),
      'user_height': box.get('user_height'),
      'body_goal': box.get('body_goal'),
      'user_bmi': box.get('user_bmi'),
      'bmi_category': box.get('bmi_category'),
      'daily_calorie_target': box.get('daily_calorie_target'),
      'recommended_split': box.get('recommended_split'),
    };
  }

  static Future<void> saveHinglishSetting(bool isHinglish) async {
    final box = Hive.box(_settingsBox);
    await box.put('is_hinglish', isHinglish);
  }

  static bool getHinglishSetting() {
    final box = Hive.box(_settingsBox);
    return box.get('is_hinglish', defaultValue: false) as bool;
  }

  static Future<void> saveCoachMessageCount(int count) async {
    final box = Hive.box(_settingsBox);
    await box.put('coach_message_count', count);
  }

  static int getCoachMessageCount() {
    final box = Hive.box(_settingsBox);
    return box.get('coach_message_count', defaultValue: 0) as int;
  }

  static Future<void> saveUnlockedUnlimitedCoach(bool unlocked) async {
    final box = Hive.box(_settingsBox);
    await box.put('unlocked_unlimited_coach', unlocked);
  }

  static bool getUnlockedUnlimitedCoach() {
    final box = Hive.box(_settingsBox);
    return box.get('unlocked_unlimited_coach', defaultValue: false) as bool;
  }

  // --- Sattu Streak & Badges ---
  static Future<void> saveSattuStreak(int streak) async {
    final box = Hive.box(_settingsBox);
    await box.put('sattu_streak', streak);
  }

  static int getSattuStreak() {
    final box = Hive.box(_settingsBox);
    return box.get('sattu_streak', defaultValue: 0) as int;
  }

  static Future<void> saveEarnedBadges(List<String> badges) async {
    final box = Hive.box(_settingsBox);
    await box.put('earned_badges', badges);
  }

  static List<String> getEarnedBadges() {
    final box = Hive.box(_settingsBox);
    final raw = box.get('earned_badges');
    if (raw == null) return [];
    return List<String>.from(raw as List);
  }

  static Future<void> saveLastStreakDate(String dateStr) async {
    final box = Hive.box(_settingsBox);
    await box.put('last_streak_date', dateStr);
  }

  static String getLastStreakDate() {
    final box = Hive.box(_settingsBox);
    return box.get('last_streak_date', defaultValue: '') as String;
  }

  // --- Meal Logs Cache ---
  static Future<void> saveCachedMeals(List<MealLog> meals) async {
    final box = Hive.box(_mealsBox);
    final List<Map<String, dynamic>> serialized = meals.map((m) => {
      'id': m.id,
      'title': m.title,
      'slot': m.slot,
      'cost': m.cost,
      'protein': m.protein,
      'calories': m.calories,
      'carbs': m.carbs,
      'fat': m.fat,
      'timestamp': m.timestamp.toIso8601String(),
      'isSynced': m.isSynced,
    }).toList();
    await box.put('meals_list', serialized);
  }

  static List<MealLog> getCachedMeals() {
    final box = Hive.box(_mealsBox);
    final raw = box.get('meals_list');
    if (raw == null) return [];
    
    final List<dynamic> list = raw as List<dynamic>;
    return list.map((item) {
      final map = item as Map<dynamic, dynamic>;
      return MealLog(
        id: map['id'] as String,
        title: map['title'] as String,
        slot: map['slot'] as String,
        cost: (map['cost'] as num).toDouble(),
        protein: (map['protein'] as num).toDouble(),
        calories: (map['calories'] as num?)?.toDouble() ?? 0.0,
        carbs: (map['carbs'] as num?)?.toDouble() ?? 0.0,
        fat: (map['fat'] as num?)?.toDouble() ?? 0.0,
        timestamp: map['timestamp'] != null ? DateTime.parse(map['timestamp'] as String) : null,
        isSynced: map['isSynced'] as bool? ?? false,
      );
    }).toList();
  }


  // --- Recipes Cache ---
  static Future<void> saveCachedRecipes(List<RecipeItem> recipes) async {
    final box = Hive.box(_recipesBox);
    final List<Map<String, dynamic>> serialized = recipes.map((r) => {
      'title': r.title,
      'desc': r.desc,
      'cost': r.cost,
      'protein': r.protein,
      'timeMins': r.timeMins,
      'tag': r.tag,
      'isKettle': r.isKettle,
      'steps': r.steps,
    }).toList();
    await box.put('recipes_list', serialized);
  }

  static List<RecipeItem> getCachedRecipes() {
    final box = Hive.box(_recipesBox);
    final raw = box.get('recipes_list');
    if (raw == null) return [];

    final List<dynamic> list = raw as List<dynamic>;
    return list.map((item) {
      final map = item as Map<dynamic, dynamic>;
      return RecipeItem(
        title: map['title'] as String,
        desc: map['desc'] as String,
        cost: (map['cost'] as num).toDouble(),
        protein: (map['protein'] as num).toDouble(),
        timeMins: map['timeMins'] as int,
        tag: map['tag'] as String,
        isKettle: map['isKettle'] as bool,
        steps: List<String>.from(map['steps'] as List<dynamic>),
      );
    }).toList();
  }

  // --- Chat Logs Cache ---
  static Future<void> saveCachedChat(List<ChatMessage> chatHistory) async {
    final box = Hive.box(_chatBox);
    final List<Map<String, dynamic>> serialized = chatHistory.map((c) => {
      'isUser': c.isUser,
      'message': c.message,
      'timestamp': c.timestamp.toIso8601String(),
      'senderName': c.senderName,
    }).toList();
    await box.put('chat_list', serialized);
  }

  static List<ChatMessage> getCachedChat() {
    final box = Hive.box(_chatBox);
    final raw = box.get('chat_list');
    if (raw == null) return [];

    final List<dynamic> list = raw as List<dynamic>;
    return list.map((item) {
      final map = item as Map<dynamic, dynamic>;
      return ChatMessage(
        isUser: map['isUser'] as bool,
        message: map['message'] as String,
        timestamp: DateTime.parse(map['timestamp'] as String),
        senderName: map['senderName'] as String? ?? 'Expert',
      );
    }).toList();
  }

  // --- Auth User Cache ---
  static Future<void> saveUser(Map<String, dynamic> userMap) async {
    final box = Hive.box(_settingsBox);
    await box.put('current_user', userMap);
  }

  static Map<String, dynamic>? getCachedUser() {
    final box = Hive.box(_settingsBox);
    final raw = box.get('current_user');
    if (raw == null) return null;
    return Map<String, dynamic>.from(raw as Map);
  }

  static Future<void> clearUser() async {
    final box = Hive.box(_settingsBox);
    await box.delete('current_user');
  }

  // --- Articles Cache ---
  static Future<void> saveCachedArticles(List<HealthArticle> articles) async {
    final box = Hive.box(_articlesBox);
    final List<Map<String, dynamic>> serialized = articles.map((a) => {
      'id': a.id,
      'title': a.title,
      'category': a.category,
      'content': a.content,
      'readTimeMins': a.readTimeMins,
      'isRead': a.isRead,
    }).toList();
    await box.put('articles_list', serialized);
  }

  static List<HealthArticle> getCachedArticles() {
    final box = Hive.box(_articlesBox);
    final raw = box.get('articles_list');
    if (raw == null) return [];

    final List<dynamic> list = raw as List<dynamic>;
    return list.map((item) {
      final map = item as Map<dynamic, dynamic>;
      return HealthArticle(
        id: map['id'] as String,
        title: map['title'] as String,
        category: map['category'] as String,
        content: map['content'] as String,
        readTimeMins: map['readTimeMins'] as int,
        isRead: map['isRead'] as bool,
      );
    }).toList();
  }

  // --- Workout Logs Cache ---
  static Future<void> saveCachedWorkoutLogs(List<WorkoutLog> logs) async {
    final box = Hive.box(_workoutLogsBox);
    final List<Map<String, dynamic>> serialized = logs.map((l) => {
      'id': l.id,
      'name': l.name,
      'setsCompleted': l.setsCompleted,
      'repsCompleted': l.repsCompleted,
      'difficulty': l.difficulty,
      'timestamp': l.timestamp.toIso8601String(),
      'isSynced': l.isSynced,
    }).toList();
    await box.put('workout_logs_list', serialized);
  }

  static List<WorkoutLog> getCachedWorkoutLogs() {
    final box = Hive.box(_workoutLogsBox);
    final raw = box.get('workout_logs_list');
    if (raw == null) return [];

    final List<dynamic> list = raw as List<dynamic>;
    return list.map((item) {
      final map = item as Map<dynamic, dynamic>;
      return WorkoutLog(
        id: map['id'] as String,
        name: map['name'] as String,
        setsCompleted: map['setsCompleted'] as int,
        repsCompleted: map['repsCompleted'] as int,
        difficulty: map['difficulty'] as String,
        timestamp: map['timestamp'] != null ? DateTime.parse(map['timestamp'] as String) : DateTime.now(),
        isSynced: map['isSynced'] as bool? ?? false,
      );
    }).toList();
  }

  // --- Desi Articles Cache ---
  static Future<void> saveCachedDesiArticles(List<DesiArticle> articles) async {
    final box = Hive.box(_desiArticlesBox);
    final List<Map<String, dynamic>> serialized = articles.map((a) => a.toJson()).toList();
    await box.put('desi_articles_list', serialized);
  }

  static List<DesiArticle> getCachedDesiArticles() {
    final box = Hive.box(_desiArticlesBox);
    final raw = box.get('desi_articles_list');
    if (raw == null) return [];

    final List<dynamic> list = raw as List<dynamic>;
    return list.map((item) {
      final map = Map<String, dynamic>.from(item as Map);
      return DesiArticle.fromJson(map);
    }).toList();
  }

  // --- Progress Photos Cache ---
  static Future<void> saveCachedProgressPhotos(List<ProgressPhoto> photos) async {
    final box = Hive.box(_progressPhotosBox);
    final List<Map<String, dynamic>> serialized = photos.map((p) => {
      'id': p.id,
      'imagePath': p.imagePath,
      'dateStr': p.dateStr,
      'bodyFat': p.bodyFat,
      'symmetryScore': p.symmetryScore,
      'vascularity': p.vascularity,
      'postureScore': p.postureScore,
      'feedback': p.feedback,
    }).toList();
    await box.put('progress_photos_list', serialized);
  }

  static List<ProgressPhoto> getCachedProgressPhotos() {
    final box = Hive.box(_progressPhotosBox);
    final raw = box.get('progress_photos_list');
    if (raw == null) return [];

    final List<dynamic> list = raw as List<dynamic>;
    return list.map((item) {
      final map = item as Map<dynamic, dynamic>;
      return ProgressPhoto(
        id: map['id'] as String,
        imagePath: map['imagePath'] as String,
        dateStr: map['dateStr'] as String,
        bodyFat: (map['bodyFat'] as num).toDouble(),
        symmetryScore: map['symmetryScore'] as int,
        vascularity: map['vascularity'] as int,
        postureScore: map['postureScore'] as int,
        feedback: map['feedback'] as String,
      );
    }).toList();
  }

  // --- AI Usage Counters ---
  static Future<void> saveAiUsageCounters(int chat, int calorie, int recipe, int article) async {
    final box = Hive.box(_settingsBox);
    await box.put('ai_chat_count', chat);
    await box.put('ai_calorie_count', calorie);
    await box.put('ai_recipe_count', recipe);
    await box.put('ai_article_count', article);
  }

  static Map<String, int> getAiUsageCounters() {
    final box = Hive.box(_settingsBox);
    return {
      'ai_chat_count': box.get('ai_chat_count', defaultValue: 0) as int,
      'ai_calorie_count': box.get('ai_calorie_count', defaultValue: 0) as int,
      'ai_recipe_count': box.get('ai_recipe_count', defaultValue: 0) as int,
      'ai_article_count': box.get('ai_article_count', defaultValue: 0) as int,
    };
  }

  static Future<void> saveWaterIntake(double amount) async {
    final box = Hive.box(_settingsBox);
    await box.put('water_intake', amount);
  }

  static double getWaterIntake() {
    final box = Hive.box(_settingsBox);
    return (box.get('water_intake', defaultValue: 0.0) as num).toDouble();
  }

  static Future<void> saveWaterGoal(double goal) async {
    final box = Hive.box(_settingsBox);
    await box.put('water_goal', goal);
  }

  static double getWaterGoal() {
    final box = Hive.box(_settingsBox);
    return (box.get('water_goal', defaultValue: 2000.0) as num).toDouble();
  }

  static Future<void> saveNotificationsSetting(bool enabled) async {
    final box = Hive.box(_settingsBox);
    await box.put('notifications_enabled', enabled);
  }

  static bool getNotificationsSetting() {
    final box = Hive.box(_settingsBox);
    return box.get('notifications_enabled', defaultValue: true) as bool;
  }

  static Future<void> setPendingStreakRescue(bool pending) async {
    final box = Hive.box(_settingsBox);
    await box.put('pending_streak_rescue', pending);
  }

  static bool getPendingStreakRescue() {
    final box = Hive.box(_settingsBox);
    return box.get('pending_streak_rescue', defaultValue: false) as bool;
  }
}


