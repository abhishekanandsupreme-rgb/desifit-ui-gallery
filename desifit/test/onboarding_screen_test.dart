import 'dart:io';

import 'package:desifit/core/state/app_state.dart';
import 'package:desifit/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

/// Smoke test for the onboarding shell: guards the extraction of the intro
/// pages into onboarding_intro_pages.dart (the PageView must still render
/// every page and the progress dots must track paging).
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

  testWidgets('OnboardingScreen renders intro content, dots, and pages through extracted content', (tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final state = AppState();
    await tester.pumpWidget(ChangeNotifierProvider<AppState>(
      create: (_) => state,
      child: const MaterialApp(home: OnboardingScreen()),
    ));
    await tester.pump();

    // Intro page (rendered through onboarding_intro_pages.dart): the badge
    // is a plain Text, the headline is RichText (needs findRichText).
    expect(find.text('SWADESHI STRENGTH'), findsOneWidget);
    expect(
      find.textContaining("India's First Desi Workout", findRichText: true),
      findsOneWidget,
    );

    // Nine progress dots for nine pages.
    for (var i = 0; i < 9; i++) {
      expect(find.byKey(ValueKey('onboarding-dot-$i')), findsOneWidget);
    }
    expect(find.text('Next'), findsOneWidget);

    // Page 1 is pure extracted content: paging to it must render its copy.
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('FUELING INDIA'), findsOneWidget);
    expect(find.text('25g Protein for ₹15'), findsOneWidget);

    // The dot state advanced with the page.
    expect(
      tester
          .widget<AnimatedContainer>(find.byKey(const ValueKey('onboarding-dot-1')))
          .constraints
          ?.maxWidth,
      32.0,
    );
  });
}
