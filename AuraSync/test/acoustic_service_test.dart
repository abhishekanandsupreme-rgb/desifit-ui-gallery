import 'package:flutter_test/flutter_test.dart';
import 'package:aurasync/services/acoustic_service.dart';

void main() {
  late AcousticService service;

  setUp(() {
    service = AcousticService();
  });

  tearDown(() async {
    await service.dispose();
  });

  group('AcousticService', () {
    test('should initialize with isMonitoring false', () {
      expect(service.isMonitoring, false);
    });

    test('should provide decibelStream', () {
      expect(service.decibelStream, isNotNull);
    });

    test('stopMonitoring should set isMonitoring to false', () async {
      await service.stopMonitoring();
      expect(service.isMonitoring, false);
    });

    test('dispose should complete without error', () async {
      expect(() => service.dispose(), returnsNormally);
    });

    test('startMonitoring should set isMonitoring to true', () async {
      await service.startMonitoring();
      expect(service.isMonitoring, true);
    });

    test('stopMonitoring should be idempotent', () async {
      await service.stopMonitoring();
      await service.stopMonitoring();
      expect(service.isMonitoring, false);
    });
  });
}
