import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aurasync/services/native_bridge.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('aurasync/sensors');

  late NativeBridge bridge;

  setUp(() {
    bridge = NativeBridge();
    // No native platform exists under `flutter test`, so answer every method
    // channel call so the bridge takes its success path (no mock sensor loop).
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async => null);
  });

  tearDown(() {
    bridge.dispose();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('NativeBridge', () {
    test('should provide sensorStream', () {
      expect(bridge.sensorStream, isNotNull);
    });

    test('dispose should complete without error', () {
      expect(() => bridge.dispose(), returnsNormally);
    });

    test('stopListening should be idempotent', () {
      bridge.stopListening();
      bridge.stopListening();
      expect(() => bridge.dispose(), returnsNormally);
    });

    test('startListening should not throw', () {
      expect(() => bridge.startListening(), returnsNormally);
    });
  });
}
