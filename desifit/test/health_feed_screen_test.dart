import 'dart:io';

import 'package:desifit/core/state/app_state.dart';
import 'package:desifit/features/health_feed/presentation/screens/health_feed_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import 'helpers/fake_http_images.dart';

/// The article list is a lazy ListView fed by NetworkImages: the fake-image
/// HTTP prevents NetworkImageLoadException (unsplash returns 400 in the test
/// binding) from failing the suite, and the tall surface keeps list items
/// rendered.
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

  group('HealthFeedScreen', () {
    testWidgets('renders the featured story and article cards from mock data', (tester) async {
      final state = AppState();
      await _pump(tester, state, const HealthFeedScreen());

      expect(find.text('Desi Health Feed'), findsOneWidget);
      expect(find.text('FEATURED STORY'), findsOneWidget);
      // art_1 is the featured article in mockArticles.
      expect(find.text('Sattu vs Whey: The Ultimate Indian Budget Protein Showdown'), findsOneWidget);
      // art_2 appears in the regular list.
      expect(find.text('The Soya Chunks Estrogen Myth: Demolishing False Claims'), findsOneWidget);
    });

    testWidgets('search filters articles and hides the featured section', (tester) async {
      final state = AppState();
      await _pump(tester, state, const HealthFeedScreen());

      await tester.enterText(find.byType(TextField).first, 'Soya');
      await tester.pump();

      // Matching article stays.
      expect(find.text('The Soya Chunks Estrogen Myth: Demolishing False Claims'), findsOneWidget);
      // Non-matching article and the featured section disappear.
      expect(find.text('Sattu vs Whey: The Ultimate Indian Budget Protein Showdown'), findsNothing);
      expect(find.text('FEATURED STORY'), findsNothing);
    });
  });
}
