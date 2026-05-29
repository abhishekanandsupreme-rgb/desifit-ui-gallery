import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';

class SensorService {
  // Magnetometer stream (Microteslas uT)
  Stream<double> get magnetometerStream {
    return magnetometerEventStream().map((event) {
      // Calculate magnitude of magnetic field: sqrt(x^2 + y^2 + z^2)
      return event.x * event.x + event.y * event.y + event.z * event.z;
    });
  }
}
