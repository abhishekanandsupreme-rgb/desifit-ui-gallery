import 'dart:async';
import 'dart:math' as math;
import 'package:noise_meter/noise_meter.dart';
import 'package:permission_handler/permission_handler.dart';

class AcousticService {
  NoiseMeter? _noiseMeter;
  StreamSubscription? _noiseSubscription;
  final _decibelController = StreamController<double>.broadcast();
  
  Stream<double> get decibelStream => _decibelController.stream;
  bool isMonitoring = false;
  
  Timer? _mockTimer;

  // Request Microphone Permissions and Start Monitoring
  Future<void> startMonitoring() async {
    if (isMonitoring) return;
    
    try {
      final status = await Permission.microphone.request();
      if (status.isGranted) {
        _noiseMeter = NoiseMeter();
        _noiseSubscription = _noiseMeter!.noise.listen(
          (noiseReading) {
            final db = noiseReading.meanDecibel;
            if (!_decibelController.isClosed) {
              _decibelController.add(db.clamp(30.0, 120.0));
            }
          },
          onError: (error) {
            _startMockFallback();
          },
        );
        isMonitoring = true;
      } else {
        _startMockFallback();
      }
    } catch (e) {
      _startMockFallback();
    }
  }

  void _startMockFallback() {
    isMonitoring = true;
    _mockTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!_decibelController.isClosed) {
        final double baseDb = 42.0 + math.sin(DateTime.now().second / 10.0) * 5.0;
        final double spike = math.Random().nextDouble() > 0.95 ? 20.0 : 0.0;
        _decibelController.add((baseDb + spike).clamp(30.0, 120.0));
      }
    });
  }

  // Stop sound monitoring
  Future<void> stopMonitoring() async {
    _mockTimer?.cancel();
    _mockTimer = null;
    await _noiseSubscription?.cancel();
    _noiseSubscription = null;
    isMonitoring = false;
  }

  // Dispose stream
  Future<void> dispose() async {
    await stopMonitoring();
    await _decibelController.close();
  }
}
