import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aurasync/main.dart';

void main() {
  testWidgets('AuraSync smoke test - verify application title and UI layout', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AuraSyncApp());
    await tester.pump();

    // Verify that the AppBar title is displayed.
    expect(find.text('AURASYNC // DIGITAL TWIN'), findsOneWidget);

    // Verify that the NOMINAL status tag is displayed.
    expect(find.text('NOMINAL'), findsOneWidget);
  });

  testWidgets('Verify Tap-to-Raycast Isometric Probe Placement', (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(const AuraSyncApp());
    await tester.pump();

    // Find the viewport gesture detector by key
    final gestureFinder = find.byKey(const Key('viewport_gesture'));
    expect(gestureFinder, findsOneWidget);

    // Initial state: no probes placed
    expect(find.text('0 / 5 ACTIVE'), findsOneWidget);

    // Tap on the viewport
    await tester.tap(gestureFinder);
    await tester.pump();

    // Verify that a probe has been placed
    expect(find.text('1 / 5 ACTIVE'), findsOneWidget);
  });
}
