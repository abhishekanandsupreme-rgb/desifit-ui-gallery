import 'dart:io';

import 'package:desifit/core/state/app_state.dart';
import 'package:desifit/features/dashboard/presentation/screens/workout_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

/// The modality chip row is a horizontal ListView that extends past the
/// default 800x600 test surface; a wide surface keeps the chips on-screen.
Future<void> _pump(WidgetTester tester, AppState state, Widget child) async {
  tester.view.physicalSize = const Size(1200, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(ChangeNotifierProvider<AppState>(
    create: (_) => state,
    child: MaterialApp(home: Scaffold(body: child)),
  ));
  await tester.pump();
}

void main() {
  setUpAll(() async {
    final tempDir = Directory.systemTemp.createTempSync();
    Hive.init(tempDir.path);

    await Hive.openBox('settings');
    await Hive.openBox('recipes_cache');
    await Hive.openBox('meals_cache');
    await Hive.openBox('chat_cache');
    await Hive.openBox('articles_cache');
    await Hive.openBox('workout_logs_cache');
    await Hive.openBox('desi_articles_cache');
    await Hive.openBox('progress_photos_cache');
  });

  group('WorkoutScreen', () {
    testWidgets('renders modality chips and the default workout list', (tester) async {
      final state = AppState();
      await _pump(tester, state, const WorkoutScreen());

      // The AppBar title also reads 'Desi Workouts', hence findsWidgets.
      expect(find.text('Desi Workouts'), findsWidgets);
      expect(find.text('Dorm Pushup Ritual'), findsOneWidget);
      expect(find.text('Gym Bench Press'), findsOneWidget);
    });

    testWidgets('Gym modality filters the list to Gym workouts only', (tester) async {
      final state = AppState();
      await _pump(tester, state, const WorkoutScreen());

      await tester.tap(find.text('Gym Workouts').last);
      await tester.pump();

      expect(find.text('Gym Bench Press'), findsOneWidget);
      expect(find.text('Dorm Pushup Ritual'), findsNothing);
    });

    testWidgets('split chips switch the sub-tab set (Push/Pull/Legs → Bro Split)', (tester) async {
      final state = AppState();
      await _pump(tester, state, const WorkoutScreen());

      // Default split is Push/Pull/Legs → sub-tabs Push|Pull|Legs.
      expect(find.text('Push'), findsWidgets);
      expect(find.text('Pull'), findsOneWidget);
      expect(find.text('Legs'), findsOneWidget);

      await tester.tap(find.text('Bro Split'));
      await tester.pump();

      expect(find.text('Chest'), findsOneWidget);
      expect(find.text('Back'), findsOneWidget);
      expect(find.text('Shoulders'), findsOneWidget);
    });
  });
}
