import 'dart:io';

import 'package:desifit/core/state/app_state.dart';
import 'package:desifit/features/dashboard/presentation/screens/calorie_counter_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

/// The screens are content-heavy: chips rows run past the default 800x600
/// test surface and taps would land off-screen. A tall/wide surface keeps
/// every interaction target inside the hit-testable area.
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

  group('CalorieCounterScreen', () {
    testWidgets('renders all four meal slots with Breakfast selected', (tester) async {
      final state = AppState();
      await _pump(tester, state, const CalorieCounterScreen());

      expect(find.text('Breakfast'), findsWidgets);
      expect(find.text('Lunch'), findsOneWidget);
      expect(find.text('Dinner'), findsOneWidget);
      expect(find.text('Snack'), findsOneWidget);
    });

    testWidgets('search shows matching food and selecting it opens the macro preview', (tester) async {
      final state = AppState();
      await _pump(tester, state, const CalorieCounterScreen());

      await tester.enterText(find.byType(TextField).first, 'Roti');
      await tester.pump();

      // 'Roti/Chapati' comes from NutritionState.indianFoodDatabase.
      expect(find.text('Roti/Chapati'), findsOneWidget);

      await tester.tap(find.text('Roti/Chapati'));
      await tester.pump();

      // Macro preview for 1 medium roti at 1.0x portion.
      expect(find.text('120 kcal'), findsOneWidget);
    });

    testWidgets('logging a selected food adds its calories to AppState', (tester) async {
      final state = AppState();
      await _pump(tester, state, const CalorieCounterScreen());

      // AppState's guest-sync seeds one demo meal asynchronously during
      // construction; flush it and snapshot the baseline so assertions hold
      // regardless of the seed's contents.
      await tester.pump();
      final baselineCalories = state.caloriesConsumed;

      await tester.enterText(find.byType(TextField).first, 'Roti');
      await tester.pump();
      await tester.tap(find.text('Roti/Chapati'));
      await tester.pump();

      await tester.tap(find.text('Add to Log'));
      await tester.pump();
      // Logging may trigger the gamification celebration, which arms a 4s
      // dismiss timer; advance fake time past it so teardown sees no pending
      // timers.
      await tester.pump(const Duration(seconds: 5));

      expect(state.caloriesConsumed, baselineCalories + 120.0);
      final rotiMeals = state.meals.where((m) => m.title.contains('Roti/Chapati'));
      expect(rotiMeals.length, 1);
      expect(rotiMeals.first.slot, 'Breakfast');
    });

    testWidgets('AI estimator sheet opens with the Coach Bheem UI', (tester) async {
      final state = AppState();
      await _pump(tester, state, const CalorieCounterScreen());

      await tester.tap(find.text('🤖'));
      await tester.pump();

      expect(find.text('AI Coach Bheem Calorie Estimator'), findsOneWidget);
      expect(find.text('Ask AI'), findsOneWidget);
    });
  });
}
