import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show IconData;
import '../storage/local_storage.dart';
import '../network/analytics_service.dart';
import 'models.dart';

class WorkoutState extends ChangeNotifier {
  List<WorkoutItem> _workouts = [];
  List<WorkoutLog> _workoutLogs = [];

  WorkoutItem? _activeWorkout;
  int _currentSet = 1;
  int _currentReps = 0;

  List<WorkoutItem> get workouts => _workouts;
  List<WorkoutLog> get workoutLogs => _workoutLogs;
  WorkoutItem? get activeWorkout => _activeWorkout;
  int get currentSet => _currentSet;
  int get currentReps => _currentReps;

  // Callbacks
  VoidCallback? _onWorkoutCompleted;
  List<ProgressPoint> Function()? _getWeeklyProgress;
  void Function(List<ProgressPoint>)? _onWeeklyProgressChanged;

  void setCallbacks({
    required void Function() onWorkoutCompleted,
    required List<ProgressPoint> Function() getWeeklyProgress,
    required void Function(List<ProgressPoint>) onWeeklyProgressChanged,
  }) {
    _onWorkoutCompleted = onWorkoutCompleted;
    _getWeeklyProgress = getWeeklyProgress;
    _onWeeklyProgressChanged = onWeeklyProgressChanged;
  }

  void initFromCache({
    required List<WorkoutItem> workouts,
    required List<WorkoutLog> workoutLogs,
  }) {
    _workouts = workouts;
    _workoutLogs = workoutLogs;
    if (_workouts.isEmpty) {
      _loadDefaultWorkouts();
    }
  }

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

    final wp = _getWeeklyProgress?.call() ?? [];
    final lastIdx = wp.length - 1;
    if (lastIdx >= 0) {
      final currentPoint = wp[lastIdx];
      wp[lastIdx] = ProgressPoint(
        dayName: currentPoint.dayName,
        proteinGrams: currentPoint.proteinGrams,
        budgetSpent: currentPoint.budgetSpent,
        workoutsCompleted: currentPoint.workoutsCompleted + 1,
      );
      _onWeeklyProgressChanged?.call(wp);
    }

    AnalyticsService.logEvent('workout_completed', {
      'workout_id': _activeWorkout!.id,
      'workout_name': _activeWorkout!.name,
      'target_sets': _activeWorkout!.targetSets,
      'target_reps': _activeWorkout!.targetReps,
      'difficulty': _activeWorkout!.difficulty,
    });

    _activeWorkout = null;
    _onWorkoutCompleted?.call();
    notifyListeners();
  }

  void cancelWorkout() {
    _activeWorkout = null;
    _currentSet = 1;
    _currentReps = 0;
    notifyListeners();
  }

  void _loadDefaultWorkouts() {
    _workouts = [
      WorkoutItem(
        id: 'wo_1', name: 'Dorm Pushup Ritual', desc: 'Build chest and triceps.',
        targetReps: 15, targetSets: 4, difficulty: 'Beginner', icon: const IconData(0xf0c3, fontFamily: 'MaterialIcons'),
        intensity: 'RPE 8 (Bodyweight)', tempo: '3-0-1-0', targetHeartRateZone: 'Zone 2 (Aerobic)',
        isGym: false, bodyPart: 'Chest', splits: ['Push', 'Upper', 'Full Body', 'Chest'],
      ),
      WorkoutItem(
        id: 'wo_2', name: 'Gym Bench Press', desc: 'Standard chest strength builder.',
        targetReps: 8, targetSets: 4, difficulty: 'Hard', icon: const IconData(0xf0c3, fontFamily: 'MaterialIcons'),
        intensity: '75% 1RM (RPE 8.5)', tempo: '3-1-1-0', targetHeartRateZone: 'Zone 2 (Aerobic)',
        isGym: true, bodyPart: 'Chest', splits: ['Push', 'Upper', 'Full Body', 'Chest'],
      ),
      WorkoutItem(
        id: 'wo_3', name: 'Pike Push-ups', desc: 'Target anterior deltoids and triceps.',
        targetReps: 10, targetSets: 3, difficulty: 'Medium', icon: const IconData(0xf1ec, fontFamily: 'MaterialIcons'),
        intensity: 'RPE 8 (Bodyweight)', tempo: '3-0-1-0', targetHeartRateZone: 'Zone 2 (Aerobic)',
        isGym: false, bodyPart: 'Shoulders', splits: ['Push', 'Upper', 'Full Body', 'Shoulders'],
      ),
      WorkoutItem(
        id: 'wo_4', name: 'Gym Overhead Press', desc: 'Build massive shoulder strength.',
        targetReps: 6, targetSets: 4, difficulty: 'Hard', icon: const IconData(0xf077, fontFamily: 'MaterialIcons'),
        intensity: '80% 1RM (RPE 9)', tempo: '2-1-1-0', targetHeartRateZone: 'Zone 3 (Cardio)',
        isGym: true, bodyPart: 'Shoulders', splits: ['Push', 'Upper', 'Full Body', 'Shoulders'],
      ),
      WorkoutItem(
        id: 'wo_5', name: 'Gym Barbell Rows', desc: 'Develop upper and mid back thickness.',
        targetReps: 10, targetSets: 4, difficulty: 'Medium', icon: const IconData(0xf0c3, fontFamily: 'MaterialIcons'),
        intensity: '70% 1RM (RPE 8)', tempo: '3-0-1-1', targetHeartRateZone: 'Zone 2 (Aerobic)',
        isGym: true, bodyPart: 'Back', splits: ['Pull', 'Upper', 'Full Body', 'Back'],
      ),
      WorkoutItem(
        id: 'wo_6', name: 'Hostel Door Pull-ups', desc: 'Staple bodyweight back builder.',
        targetReps: 8, targetSets: 4, difficulty: 'Medium', icon: const IconData(0xf07d, fontFamily: 'MaterialIcons'),
        intensity: 'RPE 8.5 (Bodyweight)', tempo: '2-1-1-0', targetHeartRateZone: 'Zone 2 (Aerobic)',
        isGym: false, bodyPart: 'Back', splits: ['Pull', 'Upper', 'Full Body', 'Back'],
      ),
      WorkoutItem(
        id: 'wo_7', name: 'Tricep Chair Dips', desc: 'Use your hostel chair/bed.',
        targetReps: 12, targetSets: 4, difficulty: 'Medium', icon: const IconData(0xf9b6, fontFamily: 'MaterialIcons'),
        intensity: 'RPE 8 (Bodyweight)', tempo: '3-1-1-0', targetHeartRateZone: 'Zone 2 (Aerobic)',
        isGym: false, bodyPart: 'Triceps', splits: ['Push', 'Upper', 'Full Body', 'Arms'],
      ),
      WorkoutItem(
        id: 'wo_8', name: 'Gym Close-grip Bench Press', desc: 'Target triceps heavily.',
        targetReps: 10, targetSets: 3, difficulty: 'Medium', icon: const IconData(0xf0c3, fontFamily: 'MaterialIcons'),
        intensity: '70% 1RM (RPE 8)', tempo: '3-1-1-0', targetHeartRateZone: 'Zone 2 (Aerobic)',
        isGym: true, bodyPart: 'Triceps', splits: ['Push', 'Upper', 'Full Body', 'Arms'],
      ),
      WorkoutItem(
        id: 'wo_9', name: 'Kettle Bicep Curls', desc: 'Dorm bicep developer.',
        targetReps: 15, targetSets: 3, difficulty: 'Beginner', icon: const IconData(0xf54f, fontFamily: 'MaterialIcons'),
        intensity: 'RPE 7.5 (Kettle/Bag)', tempo: '3-0-1-0', targetHeartRateZone: 'Zone 1 (Recovery)',
        isGym: false, bodyPart: 'Biceps', splits: ['Pull', 'Upper', 'Full Body', 'Arms'],
      ),
      WorkoutItem(
        id: 'wo_10', name: 'Gym Dumbbell Curls', desc: 'Bicep isolator.',
        targetReps: 12, targetSets: 3, difficulty: 'Beginner', icon: const IconData(0xf0c3, fontFamily: 'MaterialIcons'),
        intensity: 'RPE 8 (Dumbbell)', tempo: '3-0-1-0', targetHeartRateZone: 'Zone 1 (Recovery)',
        isGym: true, bodyPart: 'Biceps', splits: ['Pull', 'Upper', 'Full Body', 'Arms'],
      ),
      WorkoutItem(
        id: 'wo_11', name: 'Gym Barbell Squats', desc: 'The king of lower body exercises.',
        targetReps: 8, targetSets: 4, difficulty: 'Hard', icon: const IconData(0xf5a1, fontFamily: 'MaterialIcons'),
        intensity: '75% 1RM (RPE 8)', tempo: '3-1-1-0', targetHeartRateZone: 'Zone 3 (Cardio)',
        isGym: true, bodyPart: 'Legs', splits: ['Legs', 'Lower', 'Full Body', 'Legs'],
      ),
      WorkoutItem(
        id: 'wo_12', name: 'Kettle Goblet Squats', desc: 'Leg developer.',
        targetReps: 20, targetSets: 3, difficulty: 'Medium', icon: const IconData(0xf5a1, fontFamily: 'MaterialIcons'),
        intensity: 'RPE 7 (Kettle/Bag)', tempo: '4-1-1-0', targetHeartRateZone: 'Zone 3 (Cardio)',
        isGym: false, bodyPart: 'Legs', splits: ['Legs', 'Lower', 'Full Body', 'Legs'],
      ),
      WorkoutItem(
        id: 'wo_13', name: 'Plank Hold', desc: 'Isometric core strength.',
        targetReps: 60, targetSets: 3, difficulty: 'Beginner', icon: const IconData(0xf105, fontFamily: 'MaterialIcons'),
        intensity: 'RPE 7.5 (Bodyweight)', tempo: '1-0-0-0', targetHeartRateZone: 'Zone 2 (Aerobic)',
        isGym: false, bodyPart: 'Core', splits: ['Legs', 'Lower', 'Full Body', 'Legs'],
      ),
      WorkoutItem(
        id: 'wo_14', name: 'Hanging Leg Raises', desc: 'Target lower abs and hip flexors.',
        targetReps: 12, targetSets: 3, difficulty: 'Medium', icon: const IconData(0xf07d, fontFamily: 'MaterialIcons'),
        intensity: 'RPE 8.5 (Bodyweight)', tempo: '2-0-1-1', targetHeartRateZone: 'Zone 2 (Aerobic)',
        isGym: true, bodyPart: 'Core', splits: ['Legs', 'Lower', 'Full Body', 'Legs'],
      ),
      WorkoutItem(
        id: 'wo_15', name: 'Diamond Push-ups', desc: 'Intense tricep and inner chest developer.',
        targetReps: 12, targetSets: 3, difficulty: 'Medium', icon: const IconData(0xf0e7, fontFamily: 'MaterialIcons'),
        intensity: 'RPE 8 (Bodyweight)', tempo: '3-0-1-0', targetHeartRateZone: 'Zone 2 (Aerobic)',
        isGym: false, bodyPart: 'Triceps', splits: ['Push', 'Upper', 'Full Body', 'Arms'],
      ),
      WorkoutItem(
        id: 'wo_16', name: 'Gym Barbell Deadlift', desc: 'Posterior chain builder.',
        targetReps: 5, targetSets: 3, difficulty: 'Hard', icon: const IconData(0xf062, fontFamily: 'MaterialIcons'),
        intensity: '85% 1RM (RPE 9)', tempo: '2-1-1-0', targetHeartRateZone: 'Zone 3 (Cardio)',
        isGym: true, bodyPart: 'Back', splits: ['Pull', 'Lower', 'Full Body', 'Back'],
      ),
      WorkoutItem(
        id: 'wo_17', name: 'Gym Lateral Raises', desc: 'Isolate medial deltoids.',
        targetReps: 15, targetSets: 4, difficulty: 'Beginner', icon: const IconData(0xf337, fontFamily: 'MaterialIcons'),
        intensity: 'RPE 8 (Dumbbell)', tempo: '2-0-1-1', targetHeartRateZone: 'Zone 1 (Recovery)',
        isGym: true, bodyPart: 'Shoulders', splits: ['Push', 'Upper', 'Shoulders'],
      ),
      WorkoutItem(
        id: 'wo_18', name: 'Desi Baithak (Squat Jump)', desc: 'Traditional cardiovascular leg blaster.',
        targetReps: 10, targetSets: 4, difficulty: 'Hard', icon: const IconData(0xf0e7, fontFamily: 'MaterialIcons'),
        intensity: 'RPE 9 (Cardio)', tempo: '1-0-1-0', targetHeartRateZone: 'Zone 4 (Threshold)',
        isGym: false, bodyPart: 'Legs', splits: ['Legs', 'Lower', 'Full Body', 'Legs'],
      ),
      WorkoutItem(
        id: 'wo_19', name: 'Russian Twists', desc: 'Target obliques and core rotation.',
        targetReps: 20, targetSets: 3, difficulty: 'Beginner', icon: const IconData(0xf044, fontFamily: 'MaterialIcons'),
        intensity: 'RPE 7 (Bodyweight)', tempo: '1-0-1-0', targetHeartRateZone: 'Zone 2 (Aerobic)',
        isGym: false, bodyPart: 'Core', splits: ['Legs', 'Lower', 'Full Body', 'Legs'],
      ),
      WorkoutItem(
        id: 'wo_20', name: 'Chin-ups', desc: 'Excellent bicep and lat builder.',
        targetReps: 8, targetSets: 4, difficulty: 'Medium', icon: const IconData(0xf07d, fontFamily: 'MaterialIcons'),
        intensity: 'RPE 8 (Bodyweight)', tempo: '2-0-1-0', targetHeartRateZone: 'Zone 2 (Aerobic)',
        isGym: false, bodyPart: 'Biceps', splits: ['Pull', 'Upper', 'Full Body', 'Arms'],
      ),
    ];
    
  }
}
