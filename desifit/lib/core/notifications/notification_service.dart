import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import '../storage/local_storage.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    // Initialize Timezone Database
    tz.initializeTimeZones();
    try {
      final String currentTimeZone = (await FlutterTimezone.getLocalTimezone()).identifier;
      tz.setLocalLocation(tz.getLocation(currentTimeZone));
    } catch (e) {
      debugPrint('Failed to set timezone: $e. Defaulting to GMT/UTC.');
      // Fallback in case of emulator or locale issues
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) async {
        debugPrint('Notification clicked with payload: ${details.payload}');
        // Handle payload actions here (e.g. log sattu meal for streak rescue)
        if (details.payload == 'streak_rescue') {
          // Setting a temporary flag in local storage to trigger streak rescue on launch
          await LocalStorage.setPendingStreakRescue(true);
        }
      },
    );

    _initialized = true;
    
    // Check local storage and schedule if enabled
    if (areNotificationsEnabled()) {
      await scheduleDailyReminders();
    }
  }

  static bool areNotificationsEnabled() {
    return LocalStorage.getNotificationsSetting();
  }

  static Future<void> setNotificationsEnabled(bool enabled) async {
    await LocalStorage.saveNotificationsSetting(enabled);
    if (enabled) {
      await scheduleDailyReminders();
    } else {
      await cancelAllNotifications();
    }
  }

  static Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
    debugPrint('All scheduled local notifications cancelled.');
  }

  static Future<void> scheduleDailyReminders() async {
    if (!_initialized) return;

    // Cancel existing scheduled notifications to avoid duplicates
    await cancelAllNotifications();

    // 1. Morning Hydration (8:00 AM)
    await _scheduleDailyNotification(
      id: 101,
      title: '🥛 Fill the Matka, Bhai!',
      body: 'Subah ho gayi hai, Champ! Drink a fresh glass of water, chaas, or sattu to start recovery right.',
      hour: 8,
      minute: 0,
      payload: 'hydration_reminder',
    );

    // 2. Mid-Day Protein Check (1:30 PM)
    await _scheduleDailyNotification(
      id: 102,
      title: '🍗 Lunch Protein Check',
      body: 'Kya aapne lunch me soya chunks ya boiled eggs liya? Sasta protein log karna mat bhoolo!',
      hour: 13,
      minute: 30,
      payload: 'protein_reminder',
    );

    // 3. Evening Workout Call (6:00 PM)
    await _scheduleDailyNotification(
      id: 103,
      title: '🏋️‍♂️ Time for Akhada Action!',
      body: 'Ready for Mugdar swings or a quick dorm calisthenics routine? Let\'s get that pump, Champ!',
      hour: 18,
      minute: 0,
      payload: 'workout_reminder',
    );

    // 4. Night Streak Rescue Warning (9:00 PM)
    await _scheduleDailyNotification(
      id: 104,
      title: '🔥 Sattu Streak at Risk!',
      body: 'Bhai, sattu streak toot jayegi! Tap to drink a Sattu Shake and save your daily streak!',
      hour: 21,
      minute: 0,
      payload: 'streak_rescue',
    );

    debugPrint('Daily habit notifications scheduled successfully.');
  }

  static Future<void> _scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    required String payload,
  }) async {
    final tz.TZDateTime scheduledDate = _nextInstanceOfTime(hour, minute);

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'desifit_habit_reminders',
      'Habit Reminders',
      channelDescription: 'Daily notifications promoting workout routines and nutrition logs.',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Schedule notification
    try {
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        platformDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Failed to schedule exact notification $id: $e. Trying inexactAllowWhileIdle fallback...');
      try {
        await _notificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          scheduledDate,
          platformDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: payload,
        );
      } catch (ex) {
        debugPrint('Failed to schedule notification $id with inexactAllowWhileIdle fallback: $ex');
      }
    }
  }

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
