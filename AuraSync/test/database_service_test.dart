import 'package:flutter_test/flutter_test.dart';
import 'package:aurasync/models/scan_log.dart';
import 'package:aurasync/services/database_service.dart';

void main() {
  late DatabaseService service;

  setUp(() {
    service = DatabaseService();
  });

  group('DatabaseService', () {
    test('getAllScanLogs should return empty list when not initialized', () async {
      final logs = await service.getAllScanLogs();
      expect(logs, isEmpty);
    });

    test('saveScanLog should not throw when not initialized', () async {
      final log = ScanLog()
        ..timestamp = DateTime.now()
        ..roomName = 'Test Room'
        ..temperature = 24.0
        ..humidity = 50.0
        ..co2 = 500.0
        ..voc = 0.1
        ..pm25 = 5.0
        ..light = 300.0
        ..score = 85.0
        ..decibel = 40.0
        ..warnings = <String>[];
      expect(() => service.saveScanLog(log), returnsNormally);
    });

    test('clearAllLogs should not throw when not initialized', () async {
      expect(() => service.clearAllLogs(), returnsNormally);
    });
  });
}
