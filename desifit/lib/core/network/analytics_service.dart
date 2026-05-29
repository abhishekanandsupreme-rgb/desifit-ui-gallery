import 'package:flutter/foundation.dart';

/// Representation of a logged telemetry event.
class AnalyticsEvent {
  final String key;
  final DateTime timestamp;
  final Map<String, dynamic>? parameters;

  AnalyticsEvent({
    required this.key,
    required this.timestamp,
    this.parameters,
  });

  Map<String, dynamic> toJson() => {
        'key': key,
        'timestamp': timestamp.toIso8601String(),
        'parameters': parameters,
      };

  @override
  String toString() =>
      'AnalyticsEvent(key: "$key", timestamp: ${timestamp.toIso8601String()}, parameters: $parameters)';
}

/// Service to handle event logging for DesiFit features.
class AnalyticsService {
  static final List<AnalyticsEvent> _cache = [];

  /// Get the list of all logged events in-memory.
  static List<AnalyticsEvent> get events => List.unmodifiable(_cache);

  /// Logs a telemetry event with key, timestamp, and optional parameters.
  static void logEvent(String key, [Map<String, dynamic>? parameters]) {
    final event = AnalyticsEvent(
      key: key,
      timestamp: DateTime.now(),
      parameters: parameters,
    );
    _cache.add(event);
    debugPrint('📊 [Telemetry] Event Logged: $event');
  }

  /// Clears the local memory cache of events.
  static void clearCache() {
    _cache.clear();
    debugPrint('📊 [Telemetry] Event cache cleared.');
  }
}

/// Helper to simulate creating shareable text cards for workout achievements and Sattu Streaks.
class ShareMockGenerator {
  /// Generates a shareable text card for a workout achievement.
  static String generateWorkoutCard({
    required String workoutName,
    required int sets,
    required int reps,
    required String difficulty,
  }) {
    return '🏋️ DesiFit Workout Complete! 🏋️\n'
        '-----------------------------------\n'
        'I just finished the "$workoutName"!\n'
        '💪 Routine: $sets sets x $reps reps\n'
        '🔥 Difficulty: $difficulty\n'
        '⚡ No gym? No problem. Dorm room gains are real!\n'
        '-----------------------------------\n'
        '👉 Build pure steel on a budget with DesiFit: https://desifit.in';
  }

  /// Generates a shareable text card for Sattu Streaks.
  static String generateStreakCard({
    required int streakDays,
    required double proteinGrams,
    required double cost,
  }) {
    return '🥛 DesiFit Sattu Streak! 🥛\n'
        '-----------------------------------\n'
        '🔥 I am on a $streakDays-day Sattu Streak!\n'
        '🌱 Hit ${proteinGrams.toInt()}g protein today for just ₹${cost.toInt()}!\n'
        '💪 The ancient Desi Whey power is unmatched.\n'
        '-----------------------------------\n'
        '👉 Join the Sattu Samrats on DesiFit: https://desifit.in';
  }
}
