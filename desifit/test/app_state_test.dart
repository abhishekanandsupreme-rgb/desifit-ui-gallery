import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:desifit/core/state/app_state.dart';
import 'package:hive/hive.dart';

void main() {
  setUpAll(() async {
    // Setup temporary directory for Hive in testing environment
    final tempDir = Directory.systemTemp.createTempSync();
    Hive.init(tempDir.path);
    
    // Open the boxes expected by LocalStorage and AppState
    await Hive.openBox('settings');
    await Hive.openBox('recipes_cache');
    await Hive.openBox('meals_cache');
    await Hive.openBox('chat_cache');
    await Hive.openBox('articles_cache');
    await Hive.openBox('workout_logs_cache');
    await Hive.openBox('desi_articles_cache');
    await Hive.openBox('progress_photos_cache');
  });

  group('AppState Tests', () {
    test('Hinglish Localization Translation Check', () {
      final state = AppState();
      
      // Default should be English
      expect(state.isHinglish, false);
      expect(state.translate('Hello, Champ!'), 'Hello, Champ!');
      
      // Toggle to Hinglish Mode
      state.setHinglish(true);
      expect(state.isHinglish, true);
      expect(state.translate('Hello, Champ!'), 'Ram Ram, Bhai!');
      expect(state.translate('Budget Left'), 'Paisa Bacha');
      
      // Toggle back to English
      state.setHinglish(false);
      expect(state.isHinglish, false);
      expect(state.translate('Budget Left'), 'Budget Left');
    });

    test('Sattu Streak and Badge Unlock Logic', () {
      final state = AppState();
      
      // Reset streak and badges to baseline
      state.resetStreakAndBadges();
      expect(state.sattuStreak, 0);
      expect(state.earnedBadges.length, 0);

      // Verify manual badge manipulation
      state.toggleBadgeManually('Loha Lath');
      expect(state.earnedBadges.contains('Loha Lath'), true);
      
      state.toggleBadgeManually('Loha Lath');
      expect(state.earnedBadges.contains('Loha Lath'), false);

      // Verify streak incrementation triggers
      state.incrementStreakManually();
      expect(state.sattuStreak, 1);
      
      state.incrementStreakManually();
      expect(state.sattuStreak, 2);
    });

    test('Daily Target Setting and Limits', () {
      final state = AppState();
      
      state.setLimits(150.0, 80.0);
      expect(state.dailyBudgetLimit, 150.0);
      expect(state.proteinGoal, 80.0);
    });

    test('Onboarding Metrics BMI and Splits recommendations check', () {
      final state = AppState();
      
      // Test Muscle Gain goal recommendations
      state.updateBodyMetrics(80.0, 180.0, 'Muscle Gain');
      expect(state.userWeight, 80.0);
      expect(state.userHeight, 180.0);
      expect(state.bodyGoal, 'Muscle Gain');
      
      // BMI = 80 / (1.8 * 1.8) = 24.69
      expect(state.userBmi, closeTo(24.69, 0.1));
      expect(state.bmiCategory, 'Normal');
      
      // Protein target for muscle gain is 2.0g per kg = 160g
      expect(state.proteinGoal, 160.0);
      
      // Split should be Push/Pull/Legs
      expect(state.selectedWorkoutSplit, 'Push/Pull/Legs');
      
      // Test Fat Loss goal recommendations
      state.updateBodyMetrics(90.0, 180.0, 'Fat Loss');
      expect(state.bmiCategory, 'Overweight');
      
      // Protein target for fat loss is 1.8g per kg = 162g
      expect(state.proteinGoal, 162.0);
      expect(state.selectedWorkoutSplit, 'Push/Pull/Legs');
      
      // Test General Fitness recommendations
      state.updateBodyMetrics(55.0, 180.0, 'General Fitness');
      expect(state.bmiCategory, 'Underweight');
      
      // Protein target is 1.5g per kg = 83g (82.5 rounded)
      expect(state.proteinGoal, 83.0);
      expect(state.selectedWorkoutSplit, 'Upper/Lower');
    });

    test('Progress Photo capture and analysis flow', () async {
      final state = AppState();
      
      // Before capture, check if default photos are loaded
      expect(state.progressPhotos.length, 2);
      expect(state.isAnalyzingPhoto, false);
      
      // Capture a progress photo
      final captureFuture = state.captureProgressPhoto('mock_base64_image_data');
      expect(state.isAnalyzingPhoto, true);
      
      await captureFuture;
      
      expect(state.isAnalyzingPhoto, false);
      expect(state.progressPhotos.length, 3);
      
      // Verify body composition progression logic (body fat decreases, symmetry increases)
      final latestPhoto = state.progressPhotos.last;
      
      expect(latestPhoto.imagePath, 'mock_base64_image_data');
      // Body fat is decreasing from previous last (which was 17.8 in mock data)
      expect(latestPhoto.bodyFat, lessThan(17.8));
      // Symmetry score is increasing from previous last (which was 80 in mock data)
      expect(latestPhoto.symmetryScore, greaterThan(80));
      expect(latestPhoto.feedback.isNotEmpty, true);
      
      // Test photo deletion
      final idToDelete = latestPhoto.id;
      await state.deleteProgressPhoto(idToDelete);
      expect(state.progressPhotos.length, 2);
      expect(state.progressPhotos.any((p) => p.id == idToDelete), false);
    });

    test('Meal Deletion and Macro Recalculation', () async {
      final state = AppState();
      
      // Log in with Google to avoid mock remote sync data
      await state.loginWithGoogle();
      
      // Ensure daily metrics are reset
      state.resetDaily();
      expect(state.meals.length, 0);
      expect(state.caloriesConsumed, 0.0);
      expect(state.proteinHit, 0.0);
      expect(state.carbsConsumed, 0.0);
      expect(state.fatConsumed, 0.0);
      expect(state.budgetSpent, 0.0);

      // Add a couple of meals
      state.addFoodWithCalories('Roti', 'Lunch', 10.0, 3.5, 120.0, 20.0, 3.5);
      state.addFoodWithCalories('Paneer', 'Lunch', 50.0, 18.0, 265.0, 3.5, 20.0);

      expect(state.meals.length, 2);
      expect(state.caloriesConsumed, 385.0);
      expect(state.proteinHit, 21.5);
      expect(state.carbsConsumed, 23.5);
      expect(state.fatConsumed, 23.5);
      expect(state.budgetSpent, 60.0);

      // Delete the first meal (Roti)
      final rotiId = state.meals[0].id;
      state.deleteMeal(rotiId);

      expect(state.meals.length, 1);
      expect(state.meals[0].title, 'Paneer');
      expect(state.caloriesConsumed, 265.0);
      expect(state.proteinHit, 18.0);
      expect(state.carbsConsumed, 3.5);
      expect(state.fatConsumed, 20.0);
      expect(state.budgetSpent, 50.0);
    });

    test('AI Usage Counters and Limit Gating Logic', () {
      final state = AppState();
      
      // Reset daily to start fresh
      state.resetDaily();
      
      expect(state.aiChatCount, 0);
      expect(state.isAiChatLimitReached, false);
      
      // Test chat increment and limit
      state.incrementAiChatCount();
      state.incrementAiChatCount();
      state.incrementAiChatCount();
      state.incrementAiChatCount();
      state.incrementAiChatCount();
      expect(state.aiChatCount, 5);
      expect(state.isAiChatLimitReached, true);
      
      state.unlockAiChat();
      expect(state.aiChatCount, 0);
      expect(state.isAiChatLimitReached, false);
      
      // Test calorie estimation limit
      expect(state.isAiCalorieLimitReached, false);
      state.incrementAiCalorieCount();
      state.incrementAiCalorieCount();
      state.incrementAiCalorieCount();
      expect(state.isAiCalorieLimitReached, true);
      
      state.unlockAiCalorie();
      expect(state.isAiCalorieLimitReached, false);

      // Test recipe limit
      expect(state.isAiRecipeLimitReached, false);
      state.incrementAiRecipeCount();
      state.incrementAiRecipeCount();
      state.incrementAiRecipeCount();
      expect(state.isAiRecipeLimitReached, true);

      state.unlockAiRecipe();
      expect(state.isAiRecipeLimitReached, false);

      // Test article limit
      expect(state.isAiArticleLimitReached, false);
      state.incrementAiArticleCount();
      state.incrementAiArticleCount();
      state.incrementAiArticleCount();
      expect(state.isAiArticleLimitReached, true);

      state.unlockAiArticle();
      expect(state.isAiArticleLimitReached, false);
    });

    test('AppState Tests Water/Hydration Logging Check', () {
      final state = AppState();
      
      // Reset water
      state.resetWater();
      expect(state.waterConsumed, 0.0);
      expect(state.waterGoal, 2000.0);

      // Log water
      state.logWater(250.0);
      expect(state.waterConsumed, 250.0);

      state.logWater(300.0);
      expect(state.waterConsumed, 550.0);

      // Custom water goal
      state.setWaterGoal(3000.0);
      expect(state.waterGoal, 3000.0);

      // Reset water
      state.resetWater();
      expect(state.waterConsumed, 0.0);
    });
  });
}
