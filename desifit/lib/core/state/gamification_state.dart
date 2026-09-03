import 'dart:async';
import 'package:flutter/foundation.dart';
import '../storage/local_storage.dart';
import 'models.dart';

class GamificationState extends ChangeNotifier {
  // Sattu Streak & Badges State
  int _sattuStreak = 0;
  List<String> _earnedBadges = [];

  // Celebration state
  bool _showConfetti = false;
  String _celebrationTitle = '';
  String _celebrationMessage = '';

  int get sattuStreak => _sattuStreak;
  List<String> get earnedBadges => _earnedBadges;
  bool get showConfetti => _showConfetti;
  String get celebrationTitle => _celebrationTitle;
  String get celebrationMessage => _celebrationMessage;

  void initFromCache() {
    _sattuStreak = LocalStorage.getSattuStreak();
    _earnedBadges = LocalStorage.getEarnedBadges();
  }

  void triggerCelebration(String title, String message) {
    _celebrationTitle = title;
    _celebrationMessage = message;
    _showConfetti = true;
    notifyListeners();
    
    Future.delayed(const Duration(seconds: 4), () {
      _showConfetti = false;
      notifyListeners();
    });
  }

  void checkDailyGoalsAndStreak({
    required double proteinHit,
    required double proteinGoal,
    required double budgetSpent,
    required double dailyBudgetLimit,
    required List<ProgressPoint> weeklyProgress,
    bool forced = false,
  }) {
    final lastIdx = weeklyProgress.length - 1;
    final workoutsCompleted = lastIdx >= 0 ? weeklyProgress[lastIdx].workoutsCompleted : 0;
    
    final bool isProteinGoalMet = proteinHit >= proteinGoal;
    final bool isBudgetGoalMet = budgetSpent > 0 && budgetSpent <= dailyBudgetLimit;
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
        
        _checkAndAwardBadges(
          proteinHit: proteinHit,
          proteinGoal: proteinGoal,
          budgetSpent: budgetSpent,
          dailyBudgetLimit: dailyBudgetLimit,
          weeklyProgress: weeklyProgress,
        );
        notifyListeners();
      }
    }
  }

  void _checkAndAwardBadges({
    required double proteinHit,
    required double proteinGoal,
    required double budgetSpent,
    required double dailyBudgetLimit,
    required List<ProgressPoint> weeklyProgress,
    List<MealLog>? meals,
  }) {
    bool updated = false;
    
    // 1. Sattu Scholar
    final hasSattuMeal = meals?.any((m) => 
      m.title.toLowerCase().contains('sattu') || 
      m.title.toLowerCase().contains('soya') ||
      m.title.toLowerCase().contains('sprout')
    ) ?? false;
    if (hasSattuMeal) {
      if (!_earnedBadges.contains('Sattu Scholar')) {
        _earnedBadges.add('Sattu Scholar');
        updated = true;
        triggerCelebration(
          '🎓 Badge Earned: Sattu Scholar!',
          'Congratulations! You\'ve explored budget recipes and unlocked the Sattu Scholar badge.',
        );
      }
    }

    // 2. Protein Pro
    if (proteinHit >= proteinGoal) {
      if (!_earnedBadges.contains('Protein Pro')) {
        _earnedBadges.add('Protein Pro');
        updated = true;
        triggerCelebration(
          '🍗 Badge Earned: Protein Pro!',
          'Boom! You hit your daily protein goal and unlocked the Protein Pro badge.',
        );
      }
    }

    // 3. Loha Lath
    final lastIdx = weeklyProgress.length - 1;
    final workoutsCompleted = lastIdx >= 0 ? weeklyProgress[lastIdx].workoutsCompleted : 0;
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

    // 4. Paisa Bachau
    if (budgetSpent > 0 && budgetSpent <= dailyBudgetLimit) {
      if (!_earnedBadges.contains('Paisa Bachau')) {
        _earnedBadges.add('Paisa Bachau');
        updated = true;
        triggerCelebration(
          '💰 Badge Earned: Paisa Bachau!',
          'Savings level expert! You stayed under your budget and unlocked the Paisa Bachau badge.',
        );
      }
    }

    // 5. Sattu Samrat
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

  void incrementStreakManually({
    required double proteinHit,
    required double proteinGoal,
    required double budgetSpent,
    required double dailyBudgetLimit,
    required List<ProgressPoint> weeklyProgress,
  }) {
    checkDailyGoalsAndStreak(
      proteinHit: proteinHit,
      proteinGoal: proteinGoal,
      budgetSpent: budgetSpent,
      dailyBudgetLimit: dailyBudgetLimit,
      weeklyProgress: weeklyProgress,
      forced: true,
    );
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
}
