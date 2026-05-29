import 'dart:async';
import 'package:flutter/services.dart';

class NativeBridge {
  static const MethodChannel _channel = MethodChannel('aurasync/sensors');

  final _sensorStreamController = StreamController<Map<String, double>>.broadcast();
  Stream<Map<String, double>> get sensorStream => _sensorStreamController.stream;

  Timer? _mockTimer;

  void startListening() {
    _channel.setMethodCallHandler((MethodCall call) async {
      if (call.method == 'onSensorChanged') {
        final Map<String, dynamic> data = Map<String, dynamic>.from(call.arguments);
        final Map<String, double> parsed = data.map((key, val) => MapEntry(key, (val as num).toDouble()));
        _sensorStreamController.add(parsed);
      }
    });

    _invokeNativeStart();
  }

  Future<void> _invokeNativeStart() async {
    try {
      await _channel.invokeMethod('startSensors');
    } catch (e) {
      _startMockSensorLoop();
    }
  }

  void _startMockSensorLoop() {
    _mockTimer?.cancel();
    _mockTimer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      if (!_sensorStreamController.isClosed) {
        _sensorStreamController.add({
          'light': 420.0 + (DateTime.now().second % 10) * 20.0,
          'pressure': 1013.25 + (DateTime.now().second % 5) * 0.5,
          'magnetometer': 45.0 + (DateTime.now().second % 8) * 1.5,
        });
      }
    });
  }

  void stopListening() {
    _mockTimer?.cancel();
    try {
      _channel.invokeMethod('stopSensors');
    } catch (_) {}
  }

  void dispose() {
    stopListening();
    _sensorStreamController.close();
  }
}
