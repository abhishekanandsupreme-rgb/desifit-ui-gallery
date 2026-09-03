import 'package:flutter_test/flutter_test.dart';
import 'package:aurasync/services/vision_service.dart';

void main() {
  late VisionService service;

  setUp(() {
    service = VisionService();
  });

  tearDown(() async {
    await service.dispose();
  });

  group('VisionService', () {
    test('should initialize with isCameraInitialized false', () {
      expect(service.isCameraInitialized, false);
    });

    test('should provide detectedObjectsStream', () {
      expect(service.detectedObjectsStream, isNotNull);
    });

    test('dispose should complete without error', () async {
      expect(() => service.dispose(), returnsNormally);
    });

    test('stopDetection should not throw when camera is null', () async {
      expect(() => service.stopDetection(), returnsNormally);
    });

    test('startDetection should not throw when camera is null', () {
      expect(() => service.startDetection(), returnsNormally);
    });
  });
}
