import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show PipelineOwner, SemanticsNode;
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import 'package:desifit/core/state/app_state.dart';
import 'package:desifit/features/dashboard/presentation/widgets/budget_tracker_card.dart';
import 'package:desifit/features/dashboard/presentation/widgets/diet_tracker_card.dart';
import 'package:desifit/features/dashboard/presentation/widgets/health_profile_card.dart';
import 'package:desifit/features/dashboard/presentation/widgets/quick_add_grid.dart';
import 'package:desifit/features/dashboard/presentation/widgets/toolbox_grid.dart';

/// AppState with every getter the five home cards read pinned to known values,
/// so the Semantics labels rendered by each card are deterministic.
///
/// The base [AppState] constructor still initializes its sub-states from Hive,
/// so the boxes must be opened first (see setUpAll below); the overridden
/// getters below simply shadow whatever was loaded from cache.
class _FakeAppState extends AppState {
  _FakeAppState({
    this.weightV,
    this.heightV,
    this.bmiV,
    this.bmiCategoryV,
    this.bodyGoalV,
    this.workoutSplitV,
    this.calorieTargetV = 2000.0,
    this.caloriesConsumedV = 0.0,
    this.caloriesRemainingV = 2000.0,
    this.proteinGoalV = 60.0,
    this.proteinHitV = 0.0,
    this.budgetLimitV = 150.0,
    this.budgetLeftV = 150.0,
  });

  final double? weightV;
  final double? heightV;
  final double? bmiV;
  final String? bmiCategoryV;
  final String? bodyGoalV;
  final String? workoutSplitV;
  final double calorieTargetV;
  final double caloriesConsumedV;
  final double caloriesRemainingV;
  final double proteinGoalV;
  final double proteinHitV;
  final double budgetLimitV;
  final double budgetLeftV;

  @override
  double? get userWeight => weightV;

  @override
  double? get userHeight => heightV;

  @override
  double? get userBmi => bmiV;

  @override
  String? get bmiCategory => bmiCategoryV;

  @override
  String? get bodyGoal => bodyGoalV;

  @override
  String? get selectedWorkoutSplit => workoutSplitV;

  @override
  double? get dailyCalorieTarget => calorieTargetV;

  @override
  double get caloriesConsumed => caloriesConsumedV;

  @override
  double get caloriesRemaining => caloriesRemainingV;

  @override
  double get proteinGoal => proteinGoalV;

  @override
  double get proteinHit => proteinHitV;

  @override
  double get dailyBudgetLimit => budgetLimitV;

  @override
  double get budgetLeft => budgetLeftV;

  /// Always announce keys verbatim (English), regardless of any persisted
  /// Hinglish setting the base constructor may have loaded from Hive.
  @override
  String translate(String key, {String? name}) => key;
}

/// Provides [state] (taking ownership so the AppState connectivity timer is
/// cancelled on teardown) and hosts [child] in a plain MaterialApp shell.
Widget _wrapWithApp(AppState state, Widget child) {
  return ChangeNotifierProvider<AppState>(
    create: (_) => state,
    child: MaterialApp(
      theme: ThemeData.light(),
      home: Scaffold(body: child),
    ),
  );
}

/// Asserts that at least one node in the live accessibility tree exposes
/// [label] as a substring. Walks every pipeline owner's semantics root the
/// way flutter_test's own SemanticsFinder does (the element-based
/// find.bySemanticsLabel skips labelled container nodes).
void _expectLabelInTree(WidgetTester tester, String label) {
  final found = <String>[];
  bool walk(SemanticsNode n) {
    final nodeLabel = n.getSemanticsData().label;
    if (nodeLabel.isNotEmpty) found.add(nodeLabel);
    n.visitChildren(walk);
    return true;
  }

  bool collectRoots(PipelineOwner owner) {
    final root = owner.semanticsOwner?.rootSemanticsNode;
    if (root != null) root.visitChildren(walk);
    owner.visitChildren(collectRoots);
    return true;
  }

  collectRoots(tester.binding.rootPipelineOwner);
  expect(
    found.any((l) => l.contains(label)),
    isTrue,
    reason: 'Expected a node containing "$label" in:\n  ${found.join('\n  ')}',
  );
}

void main() {
  setUpAll(() async {
    final tempDir = Directory.systemTemp.createTempSync();
    Hive.init(tempDir.path);

    // Open every box that LocalStorage/AppState touches during construction.
    await Hive.openBox('settings');
    await Hive.openBox('recipes_cache');
    await Hive.openBox('meals_cache');
    await Hive.openBox('chat_cache');
    await Hive.openBox('articles_cache');
    await Hive.openBox('workout_logs_cache');
    await Hive.openBox('desi_articles_cache');
    await Hive.openBox('progress_photos_cache');
  });

  group('DietTrackerCard semantics', () {
    testWidgets('exposes a section label with the calorie/protein values', (tester) async {
      final handle = tester.ensureSemantics();
      final state = _FakeAppState(
        calorieTargetV: 2000.0,
        caloriesConsumedV: 1050.0,
        caloriesRemainingV: 950.0,
        proteinGoalV: 60.0,
        proteinHitV: 30.0,
      );
      await tester.pumpWidget(_wrapWithApp(state, const DietTrackerCard()));
      await tester.pump();

      _expectLabelInTree(tester, 'Nutrition Tracker. Calories: 1050 of 2000 kcal. Protein: 30 of 60g.');
      handle.dispose();
    });

    testWidgets('exposes the Log Food button as tappable with a label', (tester) async {
      final handle = tester.ensureSemantics();
      final state = _FakeAppState();
      await tester.pumpWidget(_wrapWithApp(state, const DietTrackerCard()));
      await tester.pump();

      _expectLabelInTree(tester, 'Log Food. Navigate to calorie counter');
      handle.dispose();
    });
  });

  group('BudgetTrackerCard semantics', () {
    testWidgets('exposes a section label with the remaining budget', (tester) async {
      final handle = tester.ensureSemantics();
      final state = _FakeAppState(budgetLimitV: 150.0, budgetLeftV: 100.0);
      await tester.pumpWidget(_wrapWithApp(state, const BudgetTrackerCard()));
      await tester.pump();

      _expectLabelInTree(tester, 'Daily Budget. Budget left: ₹100 of ₹150');
      handle.dispose();
    });

    testWidgets('exposes the Weekly Reports button with a label', (tester) async {
      final handle = tester.ensureSemantics();
      final state = _FakeAppState();
      await tester.pumpWidget(_wrapWithApp(state, const BudgetTrackerCard()));
      await tester.pump();

      _expectLabelInTree(tester, 'Weekly Reports. Open progress report');
      handle.dispose();
    });
  });

  group('HealthProfileCard semantics', () {
    testWidgets('empty profile shows a labeled Setup button', (tester) async {
      final handle = tester.ensureSemantics();
      final state = _FakeAppState();
      await tester.pumpWidget(_wrapWithApp(state, const HealthProfileCard()));
      await tester.pump();

      _expectLabelInTree(tester, 'Setup Health Profile. Calculate BMI, targets & sasta diet');
      handle.dispose();
    });

    testWidgets('filled profile exposes section label and expand/collapse toggle', (tester) async {
      final handle = tester.ensureSemantics();
      final state = _FakeAppState(
        weightV: 80.0,
        heightV: 180.0,
        bmiV: 24.7,
        bmiCategoryV: 'Normal',
        bodyGoalV: 'Muscle Gain',
        workoutSplitV: 'Push/Pull/Legs',
      );
      await tester.pumpWidget(_wrapWithApp(state, const HealthProfileCard()));
      await tester.pump();

      _expectLabelInTree(tester, 'MY FITNESS PROFILE. Weight: 80 kg. Height: 180 cm. BMI: 24.7');
      _expectLabelInTree(tester, 'Expand profile details');

      // Expanding the card flips the toggle label and reveals the VIEW DIET button.
      await tester.tap(find.text('MY FITNESS PROFILE'));
      await tester.pump();

      _expectLabelInTree(tester, 'Collapse profile details');
      _expectLabelInTree(tester, 'VIEW DIET. Show sasta protein diet plan');
      handle.dispose();
    });
  });

  group('ToolboxGrid semantics', () {
    testWidgets('exposes section label and per-tool button labels', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final handle = tester.ensureSemantics();
      final state = _FakeAppState();
      await tester.pumpWidget(_wrapWithApp(state, const ToolboxGrid()));
      // AestheticToolCard staggers its entry animation (80ms * index), so let
      // every delayed start fire and the fade/slide animations finish.
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      _expectLabelInTree(tester, 'SWADESHI TOOLBOX. Nine tools');
      _expectLabelInTree(tester, 'Sasta Protein. Cost/g meter. Double tap to open');
      handle.dispose();
    });
  });

  group('QuickAddGrid semantics', () {
    testWidgets('exposes section label and per-card quick-add labels', (tester) async {
      final handle = tester.ensureSemantics();
      final state = _FakeAppState();
      await tester.pumpWidget(_wrapWithApp(state, const QuickAddGrid()));
      await tester.pump();

      _expectLabelInTree(tester, "Quick Add. Add food to today's log");
      _expectLabelInTree(
        tester,
        "Quick Add 1 Glass Sattu. Cost is ₹10. Protein is 10 grams. Double tap to add to today's log.",
      );
      handle.dispose();
    });
  });
}
