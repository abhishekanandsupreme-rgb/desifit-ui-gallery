import 'dart:io';

import 'package:desifit/core/state/app_state.dart';
import 'package:desifit/features/dashboard/presentation/widgets/badges_dialog.dart';
import 'package:desifit/features/dashboard/presentation/widgets/celebration_overlay.dart';
import 'package:desifit/features/dashboard/presentation/widgets/flashcard_widget.dart';
import 'package:desifit/features/dashboard/presentation/widgets/matka_hydration_widget.dart';
import 'package:desifit/features/dashboard/presentation/widgets/guest_prompt_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

/// Wraps a widget with a single [AppState] provider and MaterialApp shell.
Widget _wrapWithApp(Widget child) => ChangeNotifierProvider<AppState>(
      create: (_) => AppState(),
      child: MaterialApp(
        theme: ThemeData.light(),
        home: Scaffold(body: child),
      ),
    );

void main() {
  setUpAll(() async {
    // Use a temp directory for Hive, matching the pattern in app_state_test.dart.
    final tempDir = Directory.systemTemp.createTempSync();
    Hive.init(tempDir.path);

    // Open every box that LocalStorage or AppState may touch during construction.
    await Hive.openBox('settings');
    await Hive.openBox('recipes_cache');
    await Hive.openBox('meals_cache');
    await Hive.openBox('chat_cache');
    await Hive.openBox('articles_cache');
    await Hive.openBox('workout_logs_cache');
    await Hive.openBox('desi_articles_cache');
    await Hive.openBox('progress_photos_cache');
  });

  // ---------------------------------------------------------------
  // BadgesDialog
  // ---------------------------------------------------------------
  group('BadgesDialog', () {
    testWidgets('renders header and streak card', (tester) async {
      await tester.pumpWidget(
        _wrapWithApp(
          const BadgesDialog(),
        ),
      );
      await tester.pump();

      expect(find.text('🏆 Badges & Achievements'), findsOneWidget);
      expect(find.text('0 Day Sattu Streak'), findsOneWidget);
    });

    testWidgets('shows all five badge names', (tester) async {
      await tester.pumpWidget(_wrapWithApp(const BadgesDialog()));
      await tester.pump();

      expect(find.text('Sattu Scholar'), findsOneWidget);
      expect(find.text('Protein Pro'), findsOneWidget);
      expect(find.text('Loha Lath'), findsOneWidget);
      expect(find.text('Paisa Bachau'), findsOneWidget);
      expect(find.text('Sattu Samrat'), findsOneWidget);
    });

    testWidgets('shows simulator controls', (tester) async {
      await tester.pumpWidget(_wrapWithApp(const BadgesDialog()));
      await tester.pump();

      expect(find.text('Simulate +1 Day'), findsOneWidget);
      expect(find.text('Reset All'), findsOneWidget);
    });

    testWidgets('badge toggle increments earned badges', (tester) async {
      await tester.pumpWidget(_wrapWithApp(const BadgesDialog()));
      await tester.pump();

      // Tap the first badge card (Sattu Scholar) to earn it.
      final badgeTile = find.byType(InkWell).first;
      await tester.tap(badgeTile);
      await tester.pumpAndSettle();

      // A snackbar should confirm the earned badge.
      expect(find.text('Earned Sattu Scholar badge!'), findsOneWidget);

      // The check-circle icon should now appear (badge is earned).
      expect(find.byIcon(Icons.check), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------
  // CelebrationOverlay
  // ---------------------------------------------------------------
  group('CelebrationOverlay', () {
    testWidgets('displays title and message', (tester) async {
      await tester.pumpWidget(
        _wrapWithApp(
          const CelebrationOverlay(
            title: '🔥 Streak Saved!',
            message: 'Your Sattu Streak was rescued!',
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('🔥 Streak Saved!'), findsOneWidget);
      expect(find.text('Your Sattu Streak was rescued!'), findsOneWidget);
      expect(find.text('SHABAASH! 🤝'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------
  // MatkaHydrationWidget
  // ---------------------------------------------------------------
  group('MatkaHydrationWidget', () {
    testWidgets('shows header and default water target', (tester) async {
      await tester.pumpWidget(_wrapWithApp(const MatkaHydrationWidget()));
      await tester.pump();

      expect(find.text('Desi Hydration'), findsOneWidget);
      expect(find.text('0 / 2000 ml'), findsOneWidget);
    });

    testWidgets('shows all drink chips', (tester) async {
      await tester.pumpWidget(_wrapWithApp(const MatkaHydrationWidget()));
      await tester.pump();

      expect(find.text('💧 Water'), findsOneWidget);
      expect(find.text('🥛 Chaas'), findsOneWidget);
      expect(find.text('🥛 Lassi'), findsOneWidget);
      expect(find.text('🌾 Sattu Drink'), findsOneWidget);
      expect(find.text('🥥 Coconut'), findsOneWidget);
    });

    testWidgets('tapping Water chip updates total', (tester) async {
      await tester.pumpWidget(_wrapWithApp(const MatkaHydrationWidget()));
      await tester.pump();

      // Tap the Water chip (+250 ml).
      await tester.tap(find.text('💧 Water'));
      await tester.pumpAndSettle();

      // The displayed total should now reflect 250 ml.
      expect(find.text('250 / 2000 ml'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------
  // GuestPromptWidget
  // ---------------------------------------------------------------
  group('GuestPromptWidget', () {
    testWidgets('displays title and description', (tester) async {
      await tester.pumpWidget(
        _wrapWithApp(
          const GuestPromptWidget(
            title: 'Sign In to Unlock',
            description: 'Create an account to save your progress.',
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Sign In to Unlock'), findsOneWidget);
      expect(find.text('Create an account to save your progress.'), findsOneWidget);
      expect(find.text('Sign In with Google'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------
  // FlashcardWidget
  // ---------------------------------------------------------------
  group('FlashcardWidget', () {
    testWidgets('renders flashcard front with flip prompt', (tester) async {
      await tester.pumpWidget(_wrapWithApp(const FlashcardWidget()));
      // Allow animations to settle.
      await tester.pump(const Duration(seconds: 1));

      // The default flashcard should show the "TAP TO FLIP" hint.
      expect(find.text('TAP TO FLIP'), findsOneWidget);
    });
  });
}
