import 'dart:io';

import 'package:desifit/core/state/state_index.dart';
import 'package:desifit/features/dashboard/presentation/widgets/ayurvedic_recovery_card.dart';
import 'package:desifit/features/dashboard/presentation/widgets/budget_summary_card.dart';
import 'package:desifit/features/dashboard/presentation/widgets/dashboard_header.dart';
import 'package:desifit/features/dashboard/presentation/widgets/fitness_stories_tray.dart';
import 'package:desifit/features/dashboard/presentation/widgets/my_health_card.dart';
import 'package:desifit/features/dashboard/presentation/widgets/progress_cards.dart';
import 'package:desifit/features/dashboard/presentation/widgets/quick_actions_grid.dart';
import 'package:desifit/features/dashboard/presentation/widgets/wearable_sync_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

Widget _wrapWithProviders(Widget child) => MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AuthState()..loadFromCache()),
      ChangeNotifierProvider(create: (_) => NutritionState()..loadFromCache()),
      ChangeNotifierProvider(create: (_) => WorkoutState()..loadFromCache()),
      ChangeNotifierProvider(create: (_) => HealthState()..loadFromCache()),
      ChangeNotifierProvider(create: (_) => GamificationState()..loadFromCache()),
      ChangeNotifierProvider(create: (_) => AiState()..loadFromCache()),
    ],
    child: MaterialApp(
      theme: ThemeData.light(),
      home: Scaffold(body: child),
    ),
  );

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

  group('Dashboard Widgets Tests', () {
    testWidgets('DashboardHeader renders greeting and streak', (tester) async {
      await tester.pumpWidget(_wrapWithProviders(
        const SizedBox(height: 200, child: DashboardHeader()),
      ));
      // Use pump() — dashboard widgets may have animated decorations
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Hello, Champ!'), findsOneWidget);
    });

    testWidgets('ProteinProgressCard displays protein progress', (tester) async {
      // Wrap in Column to provide Flex parent for Expanded inside _MetricRing
      await tester.pumpWidget(_wrapWithProviders(
        const SizedBox(height: 200, child: Column(children: [ProteinProgressCard()])),
      ));
      await tester.pump();

      expect(find.text('Protein'), findsOneWidget);
    });

    testWidgets('CaloriesProgressCard displays calorie progress', (tester) async {
      await tester.pumpWidget(_wrapWithProviders(
        const SizedBox(height: 200, child: Column(children: [CaloriesProgressCard()])),
      ));
      await tester.pump();

      expect(find.text('Calories'), findsOneWidget);
    });

    testWidgets('BudgetSummaryCard displays budget info', (tester) async {
      await tester.pumpWidget(_wrapWithProviders(
        const SizedBox(height: 200, child: BudgetSummaryCard()),
      ));
      await tester.pump();

      expect(find.text('Daily Budget Left'), findsOneWidget);
    });

    testWidgets('MyHealthCard shows setup prompt when no metrics', (tester) async {
      await tester.pumpWidget(_wrapWithProviders(
        const SizedBox(height: 200, child: MyHealthCard()),
      ));
      await tester.pump();

      expect(find.text('Setup Health Profile'), findsOneWidget);
    });

    testWidgets('WearableSyncCard shows connect button when not synced', (tester) async {
      await tester.pumpWidget(_wrapWithProviders(
        const SizedBox(height: 200, child: WearableSyncCard()),
      ));
      await tester.pump();

      expect(find.text('CONNECT WEARABLE & SYNC'), findsOneWidget);
    });

    testWidgets('QuickActionsGrid renders tool cards', (tester) async {
      await tester.pumpWidget(_wrapWithProviders(
        const SizedBox(
          height: 500,
          child: SingleChildScrollView(child: QuickActionsGrid()),
        ),
      ));
      // Cards have infinite bob animations; use pump() with sufficient time
      // for entry animations (15 cards × 50ms stagger + 500ms entry)
      await tester.pump(const Duration(seconds: 2));

      expect(find.text('Sasta Protein'), findsOneWidget);
      expect(find.text('Grocery Plan'), findsOneWidget);
      expect(find.text('Akhada Sandbox'), findsOneWidget);
      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('AyurvedicRecoveryCard shows recovery advice', (tester) async {
      await tester.pumpWidget(_wrapWithProviders(
        const SizedBox(
          height: 500,
          child: SingleChildScrollView(child: AyurvedicRecoveryCard()),
        ),
      ));
      await tester.pump();

      expect(find.text('Ayurvedic Recovery Advisor'), findsOneWidget);
    });

    testWidgets('FitnessStoriesTray shows story circles', (tester) async {
      await tester.pumpWidget(_wrapWithProviders(
        const SizedBox(height: 400, child: FitnessStoriesTray()),
      ));
      await tester.pump();

      expect(find.text('FITNESS STORIES'), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
    });
  });
}