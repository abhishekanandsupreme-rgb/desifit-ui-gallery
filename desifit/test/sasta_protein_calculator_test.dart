import 'dart:io';

import 'package:desifit/core/state/app_state.dart';
import 'package:desifit/features/recipe_engine/presentation/screens/sasta_protein_calculator_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import 'helpers/fake_http_images.dart';

/// Big surface: the ingredient list and metric row extend past the default
/// 800x600 test surface; the fake-image HTTP keeps unsplash avatars from
/// throwing NetworkImageLoadException during decode.
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
    installFakeImageHttp();

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

  group('SastaProteinCalculatorScreen', () {
    testWidgets('renders the diet toggle and zeroed totals row', (tester) async {
      final state = AppState();
      await _pump(tester, state, const SastaProteinCalculatorScreen());

      expect(find.text('Veg Only'), findsOneWidget);
      expect(find.text('Include Non-Veg'), findsOneWidget);
      expect(find.text('Protein'), findsOneWidget);
      expect(find.text('Total Cost'), findsOneWidget);
      // Totals start at zero.
      expect(find.text('0.0g'), findsOneWidget);
      expect(find.text('₹0.0'), findsOneWidget);
    });

    testWidgets('stepping sattu (20g protein/100g, ₹12/100g) updates totals exactly', (tester) async {
      final state = AppState();
      await _pump(tester, state, const SastaProteinCalculatorScreen());

      // Sattu is the first ingredient card; its + control is the first
      // add_circle_outline icon.
      await tester.tap(find.byIcon(Icons.add_circle_outline).first);
      await tester.pump();

      // Sattu step is 10g → 10g × (20g protein/100g) = 2.0g protein,
      // 10g × (₹12/100g) = ₹1.2 cost, 10g × (360 kcal/100g) = 36 kcal.
      expect(find.text('2.0g'), findsOneWidget);
      expect(find.text('₹1.2'), findsOneWidget);
      expect(find.text('36 kcal'), findsOneWidget);
    });

    testWidgets('Include Non-Veg toggle reveals egg ingredients', (tester) async {
      final state = AppState();
      await _pump(tester, state, const SastaProteinCalculatorScreen());

      // Default is veg-only: eggs must not be present.
      expect(find.text('Boiled Eggs'), findsNothing);

      await tester.tap(find.text('Include Non-Veg'));
      await tester.pump();

      expect(find.text('Boiled Eggs'), findsOneWidget);
    });
  });
}
