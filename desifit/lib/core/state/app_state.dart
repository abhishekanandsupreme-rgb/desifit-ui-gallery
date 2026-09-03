import 'package:flutter/material.dart';
import 'dart:async';
import '../storage/local_storage.dart';
import '../auth/auth_service.dart';
import '../localization/translation_service.dart';
import '../../features/health_feed/domain/models/article.dart';
import 'models.dart';
import 'auth_state.dart';
import 'nutrition_state.dart';
import 'workout_state.dart';
import 'gamification_state.dart';
import 'ai_state.dart';
import 'content_state.dart';
import 'sync_state.dart';

// Re-export all models for backward compatibility
export 'models.dart';

class AppState extends ChangeNotifier {
  // Sub-states
  final AuthState _auth = AuthState();
  final NutritionState _nutrition = NutritionState();
  final WorkoutState _workout = WorkoutState();
  final GamificationState _gamification = GamificationState();
  final AiState _ai = AiState();
  final ContentState _content = ContentState();
  final SyncState _sync = SyncState();

  // Single owner of weekly progress data
  List<ProgressPoint> _weeklyProgress = [];

  // Settings
  bool _isHinglish = false;

  // --- Auth Delegation ---
  UserModel? get currentUser => _auth.currentUser;
  bool get isLoggedIn => _auth.isLoggedIn;
  bool get isGuest => _auth.isGuest;

  // --- Nutrition Delegation ---
  double get dailyBudgetLimit => _nutrition.dailyBudgetLimit;
  double get budgetSpent => _nutrition.budgetSpent;
  double get budgetLeft => _nutrition.budgetLeft;
  double get proteinGoal => _nutrition.proteinGoal;
  double get proteinHit => _nutrition.proteinHit;
  double get caloriesConsumed => _nutrition.caloriesConsumed;
  double get carbsConsumed => _nutrition.carbsConsumed;
  double get fatConsumed => _nutrition.fatConsumed;
  double get caloriesRemaining => _nutrition.caloriesRemaining;
  double get waterConsumed => _nutrition.waterConsumed;
  double get waterGoal => _nutrition.waterGoal;
  double? get userWeight => _nutrition.userWeight;
  double? get userHeight => _nutrition.userHeight;
  double? get userBmi => _nutrition.userBmi;
  String? get bmiCategory => _nutrition.bmiCategory;
  String? get bodyGoal => _nutrition.bodyGoal;
  double? get dailyCalorieTarget => _nutrition.dailyCalorieTarget;
  String? get selectedWorkoutSplit => _nutrition.selectedWorkoutSplit;
  List<MealLog> get meals => _nutrition.meals;

  // --- Workout Delegation ---
  List<WorkoutItem> get workouts => _workout.workouts;
  List<WorkoutLog> get workoutLogs => _workout.workoutLogs;
  WorkoutItem? get activeWorkout => _workout.activeWorkout;
  int get currentSet => _workout.currentSet;
  int get currentReps => _workout.currentReps;

  // --- Gamification Delegation ---
  int get sattuStreak => _gamification.sattuStreak;
  List<String> get earnedBadges => _gamification.earnedBadges;
  bool get showConfetti => _gamification.showConfetti;
  String get celebrationTitle => _gamification.celebrationTitle;
  String get celebrationMessage => _gamification.celebrationMessage;

  // --- AI Delegation ---
  int get aiChatCount => _ai.aiChatCount;
  int get aiCalorieEstimateCount => _ai.aiCalorieEstimateCount;
  int get aiRecipeCount => _ai.aiRecipeCount;
  int get aiArticleCount => _ai.aiArticleCount;
  bool get isAiChatLimitReached => _ai.isAiChatLimitReached;
  bool get isAiCalorieLimitReached => _ai.isAiCalorieLimitReached;
  bool get isAiRecipeLimitReached => _ai.isAiRecipeLimitReached;
  bool get isAiArticleLimitReached => _ai.isAiArticleLimitReached;
  int get coachMessageCount => _ai.coachMessageCount;
  bool get unlockedUnlimitedCoach => _ai.unlockedUnlimitedCoach;
  List<ChatMessage> get chatHistory => _ai.chatHistory;
  List<RecipeItem> get recipes => _ai.recipes;

  // --- Content Delegation ---
  List<FitnessStory> get stories => _content.stories;
  List<HealthFlashcard> get flashcards => _content.flashcards;
  List<HealthArticle> get articles => _content.articles;
  List<DesiArticle> get desiArticles => _content.desiArticles;
  List<ProgressPhoto> get progressPhotos => _content.progressPhotos;
  int get currentFlashcardIndex => _content.currentFlashcardIndex;
  bool get isGeneratingArticle => _content.isGeneratingArticle;
  bool get isAnalyzingPhoto => _content.isAnalyzingPhoto;

  // --- Sync Delegation ---
  bool get isOnline => _sync.isOnline;
  bool get simulatedOffline => _sync.simulatedOffline;
  bool get isSyncing => _sync.isSyncing;
  String? get lastSyncTime => _sync.lastSyncTime;

  // --- Settings ---
  bool get isHinglish => _isHinglish;

  // --- Weekly Progress (single owner) ---
  List<ProgressPoint> get weeklyProgress => _weeklyProgress;

  // Static food database reference
  static const List<FoodNutrition> indianFoodDatabase = NutritionState.indianFoodDatabase;

  AppState() {
    _init();
  }

  void _init() {
    _isHinglish = LocalStorage.getHinglishSetting();

    // Set up cross-state callbacks
    _nutrition.setCallbacks(
      getWeeklyProgress: () => _weeklyProgress,
      onDailyGoalsChanged: () => _checkDailyGoalsAndStreak(),
    );

    _workout.setCallbacks(
      onWorkoutCompleted: () => _checkDailyGoalsAndStreak(),
      getWeeklyProgress: () => _weeklyProgress,
      onWeeklyProgressChanged: (wp) { _weeklyProgress = wp; notifyListeners(); },
    );

    _content.setCallbacks(
      onCelebration: triggerCelebration,
    );

    _sync.setCallbacks(
      onSyncComplete: () {
        triggerSync();
        prefetchData();
      },
      onDataFetched: (meals, workouts) {
        _nutrition.initFromCache(
          meals: _nutrition.meals,
          dailyBudgetLimit: _nutrition.dailyBudgetLimit,
          proteinGoal: _nutrition.proteinGoal,
        );
        notifyListeners();
      },
    );

    // Initialize sub-states from cache
    final settings = LocalStorage.getUserSettings();
    final meals = LocalStorage.getCachedMeals();
    final recipes = LocalStorage.getCachedRecipes();
    final chatHistory = LocalStorage.getCachedChat();
    final articles = LocalStorage.getCachedArticles();
    final workoutLogs = LocalStorage.getCachedWorkoutLogs();
    final progressPhotos = LocalStorage.getCachedProgressPhotos();
    final desiArticles = LocalStorage.getCachedDesiArticles();

    _weeklyProgress = _loadDefaultProgress();

    _nutrition.initFromCache(
      meals: meals,
      dailyBudgetLimit: settings['budget_limit'] ?? 100.0,
      proteinGoal: settings['protein_goal'] ?? 60.0,
    );

    _workout.initFromCache(
      workouts: [], // WorkoutState loads its own defaults
      workoutLogs: workoutLogs,
    );

    _gamification.initFromCache();

    _ai.initFromCache(
      recipes: recipes,
      chatHistory: chatHistory,
    );

    _content.initFromCache(
      articles: articles,
      progressPhotos: progressPhotos,
      desiArticles: desiArticles,
    );

    // Load body metrics via public method
    final metrics = LocalStorage.getBodyMetrics();
    _nutrition.loadBodyMetrics(metrics);

    notifyListeners();

    _sync.startConnectivityChecker();

    // Check for pending streak rescue
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

  // --- Auth Methods ---
  Future<void> loginWithGoogle() => _auth.loginWithGoogle();
  Future<void> loginAsGuest() => _auth.loginAsGuest();
  Future<void> logout() async {
    await _auth.logout();
    notifyListeners();
  }

  // --- Nutrition Methods ---
  List<FoodNutrition> searchFoodDatabase(String query) => _nutrition.searchFoodDatabase(query);
  void addFoodWithCalories(String name, String slot, double cost, double protein, double calories, double carbs, double fat) {
    _nutrition.addFoodWithCalories(name, slot, cost, protein, calories, carbs, fat);
    _checkDailyGoalsAndStreak();
    if (isOnline) triggerSync();
  }
  void addQuickFood(String name, double cost, double protein) {
    _nutrition.addQuickFood(name, cost, protein);
    _checkDailyGoalsAndStreak();
    if (isOnline) triggerSync();
  }
  void addCustomMeal(String title, String slot, double cost, double protein) {
    _nutrition.addCustomMeal(title, slot, cost, protein);
    _checkDailyGoalsAndStreak();
    if (isOnline) triggerSync();
  }
  void deleteMeal(String id) {
    _nutrition.deleteMeal(id);
    _checkDailyGoalsAndStreak();
    if (isOnline) triggerSync();
  }
  void autoFillBudgetHacks() => _nutrition.autoFillBudgetHacks();
  void updateBodyMetrics(double weight, double height, String goal) => _nutrition.updateBodyMetrics(weight, height, goal);
  void setLimits(double budget, double protein) => _nutrition.setLimits(budget, protein);
  void logWater(double amount) => _nutrition.logWater(amount);
  void resetWater() => _nutrition.resetWater();
  void setWaterGoal(double goal) => _nutrition.setWaterGoal(goal);

  // --- Workout Methods ---
  void startWorkout(WorkoutItem workout) => _workout.startWorkout(workout);
  void incrementRep() => _workout.incrementRep();
  void completeWorkoutSession() {
    _workout.completeWorkoutSession();
    _checkDailyGoalsAndStreak();
    if (isOnline) triggerSync();
  }
  void cancelWorkout() => _workout.cancelWorkout();

  // --- Gamification Methods ---
  void triggerCelebration(String title, String message) => _gamification.triggerCelebration(title, message);
  void incrementStreakManually() {
    _gamification.incrementStreakManually(
      proteinHit: _nutrition.proteinHit,
      proteinGoal: _nutrition.proteinGoal,
      budgetSpent: _nutrition.budgetSpent,
      dailyBudgetLimit: _nutrition.dailyBudgetLimit,
      weeklyProgress: _weeklyProgress,
    );
  }
  void toggleBadgeManually(String badgeName) => _gamification.toggleBadgeManually(badgeName);
  void resetStreakAndBadges() => _gamification.resetStreakAndBadges();

  // --- AI Methods ---
  void incrementAiChatCount() => _ai.incrementAiChatCount();
  void incrementAiCalorieCount() => _ai.incrementAiCalorieCount();
  void incrementAiRecipeCount() => _ai.incrementAiRecipeCount();
  void incrementAiArticleCount() => _ai.incrementAiArticleCount();
  void unlockAiChat() => _ai.unlockAiChat();
  void unlockAiCalorie() => _ai.unlockAiCalorie();
  void unlockAiRecipe() => _ai.unlockAiRecipe();
  void unlockAiArticle() => _ai.unlockAiArticle();
  void unlockUnlimitedCoach() => _ai.unlockUnlimitedCoach();
  void addChatMessage(bool isUser, String message, {String senderName = 'Expert'}) => _ai.addChatMessage(isUser, message, senderName: senderName);
  void addGeneratedRecipe(RecipeItem recipe) => _ai.addGeneratedRecipe(recipe);

  // --- Content Methods ---
  void flipFlashcard(int index) => _content.flipFlashcard(index);
  void nextFlashcard() => _content.nextFlashcard();
  void markArticleAsRead(String id) => _content.markArticleAsRead(id);
  Future<void> generateNewArticle({String? category, String? topic}) => _content.generateNewArticle(category: category, topic: topic, isAiArticleLimitReached: isAiArticleLimitReached);
  void toggleDesiArticleBookmark(String id) => _content.toggleDesiArticleBookmark(id);
  Future<void> captureProgressPhoto(String base64Image) => _content.captureProgressPhoto(base64Image);
  Future<void> deleteProgressPhoto(String id) => _content.deleteProgressPhoto(id);

  // --- Sync Methods ---
  void toggleSimulationMode() => _sync.toggleSimulationMode();
  void startConnectivityChecker() => _sync.startConnectivityChecker();
  Future<void> triggerSync() => _sync.triggerSync(meals: _nutrition.meals, workoutLogs: _workout.workoutLogs, currentUser: _auth.currentUser);
  Future<void> resolveConflicts() => _sync.resolveConflicts(meals: _nutrition.meals, workoutLogs: _workout.workoutLogs, currentUser: _auth.currentUser);
  Future<void> prefetchData() => _sync.prefetchData(recipes: _ai.recipes, desiArticles: _content.desiArticles);

  // --- Settings Methods ---
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

  // --- Complex Methods ---
  void _checkDailyGoalsAndStreak({bool forced = false}) {
    _gamification.checkDailyGoalsAndStreak(
      proteinHit: _nutrition.proteinHit,
      proteinGoal: _nutrition.proteinGoal,
      budgetSpent: _nutrition.budgetSpent,
      dailyBudgetLimit: _nutrition.dailyBudgetLimit,
      weeklyProgress: _weeklyProgress,
      forced: forced,
    );
  }

  void resetDaily() {
    _nutrition.resetDaily();
    _ai.resetAiCounts();
    notifyListeners();
  }

  // --- Default Data Loader ---
  List<ProgressPoint> _loadDefaultProgress() {
    return [
      ProgressPoint(dayName: 'Mon', proteinGrams: 0, budgetSpent: 0, workoutsCompleted: 0),
      ProgressPoint(dayName: 'Tue', proteinGrams: 0, budgetSpent: 0, workoutsCompleted: 0),
      ProgressPoint(dayName: 'Wed', proteinGrams: 0, budgetSpent: 0, workoutsCompleted: 0),
      ProgressPoint(dayName: 'Thu', proteinGrams: 0, budgetSpent: 0, workoutsCompleted: 0),
      ProgressPoint(dayName: 'Fri', proteinGrams: 0, budgetSpent: 0, workoutsCompleted: 0),
      ProgressPoint(dayName: 'Sat', proteinGrams: 0, budgetSpent: 0, workoutsCompleted: 0),
      ProgressPoint(dayName: 'Sun', proteinGrams: 0, budgetSpent: 0, workoutsCompleted: 0),
    ];
  }

  @override
  void dispose() {
    _sync.dispose();
    super.dispose();
  }
}
