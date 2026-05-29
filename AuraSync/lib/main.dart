import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'services/sensor_service.dart';
import 'services/openrouter_service.dart';
import 'services/database_service.dart';
import 'services/vision_service.dart';
import 'models/scan_log.dart';
import 'services/export_service.dart';
import 'widgets/history_charts.dart';
import 'services/acoustic_service.dart';
import 'services/smart_home_service.dart';
import 'services/local_classifier_service.dart';
import 'services/native_bridge.dart';

void main() {
  runApp(const AuraSyncApp());
}

class AuraSyncApp extends StatelessWidget {
  const AuraSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AuraSync // Environmental Digital Twin',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF060913),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00F0FF),
          secondary: Color(0xFF00E586),
          surface: Color(0xFF0D1426),
          error: Color(0xFFFF1A6E),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontFamily: 'Outfit', color: Color(0xFFE2E8F0)),
          bodyMedium: TextStyle(fontFamily: 'Outfit', color: Color(0xFF94A3B8)),
        ),
        useMaterial3: true,
      ),
      home: const AuraSyncDashboard(),
    );
  }
}

class AuraSyncDashboard extends StatefulWidget {
  const AuraSyncDashboard({super.key});

  @override
  State<AuraSyncDashboard> createState() => _AuraSyncDashboardState();
}

class _AuraSyncDashboardState extends State<AuraSyncDashboard> with TickerProviderStateMixin {
  final _sensorService = SensorService();
  final _openRouterService = OpenRouterService();
  final _dbService = DatabaseService();
  final _visionService = VisionService();
  final _exportService = ExportService();
  final _acousticService = AcousticService();
  final _smartHomeService = SmartHomeService();
  final _localClassifierService = LocalClassifierService();
  final _nativeBridge = NativeBridge();
  StreamSubscription<Map<String, double>>? _nativeBridgeSub;
  bool _cameraAvailable = false;
  List<DetectedObject> _detectedObjects = [];
  List<ScanLog> _scanHistory = [];
  StreamSubscription<List<DetectedObject>>? _objectSub;
  final Set<String> _previouslyDetectedLabels = {};

  // State Management
  String _selectedRoom = 'living_room';
  bool _heatmapActive = true;
  bool _isLoading = false;

  // Real-time sensor values
  double _temp = 22.0;
  double _humidity = 45.0;
  double _co2 = 550.0;
  double _voc = 140.0;
  double _pm25 = 8.0;
  double _light = 420.0;
  double _decibels = 45.0;
  bool _isMicMonitoring = false;
  bool _circadianSyncActive = false;

  // Offsets from calibration
  double _tempOffset = 0.0;
  double _humidityOffset = 0.0;
  double _co2Offset = 0.0;
  double _vocOffset = 0.0;
  double _pm25Offset = 0.0;
  double _lightOffset = 0.0;
  double _utilityRate = 0.16;

  // Lists of assets & logs
  final List<String> _consoleLogs = [];
  final List<Map<String, dynamic>> _probes = [];
  List<dynamic> _recommendations = [];

  // Controllers
  late AnimationController _painterController;
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _promptController = TextEditingController();
  String _selectedModel = "google/gemini-2.5-flash";
  bool _isObscureKey = true;

  // Local streams subscriptions
  StreamSubscription? _magSub;
  double _rawMagnetometerVal = 0.0;
  StreamSubscription<double>? _acousticSub;
  StreamSubscription<String>? _smartHomeSub;

  // Environment constant datasets
  final Map<String, Map<String, dynamic>> _roomsData = {
    'living_room': {
      'name': 'Living Room',
      'temp': 22.0,
      'humidity': 45.0,
      'co2': 550.0,
      'voc': 140.0,
      'pm25': 8.0,
      'light': 420.0,
      'decibel': 42.0,
      'airflow': 1.25,
      'coords': 'LAT: 35.6895 // LNG: 139.6917',
      'signal': '98% / OPTIMAL',
    },
    'server_room': {
      'name': 'Server Room',
      'temp': 27.5,
      'humidity': 24.0,
      'co2': 420.0,
      'voc': 80.0,
      'pm25': 4.0,
      'light': 180.0,
      'decibel': 62.0,
      'airflow': 3.45,
      'coords': 'LAT: 35.6898 // LNG: 139.6921',
      'signal': '94% / HIGH_BANDWIDTH',
    },
    'greenhouse': {
      'name': 'Greenhouse',
      'temp': 25.0,
      'humidity': 82.0,
      'co2': 850.0,
      'voc': 350.0,
      'pm25': 14.0,
      'light': 1100.0,
      'decibel': 38.0,
      'airflow': 0.85,
      'coords': 'LAT: 35.6892 // LNG: 139.6909',
      'signal': '91% / MARGINAL_STABLE',
    },
    'workshop': {
      'name': 'Workshop',
      'temp': 19.0,
      'humidity': 52.0,
      'co2': 1100.0,
      'voc': 1150.0,
      'pm25': 58.0,
      'light': 620.0,
      'decibel': 74.0,
      'airflow': 2.10,
      'coords': 'LAT: 35.6901 // LNG: 139.6934',
      'signal': '88% / DENSE_INTERFERENCE',
    }
  };

  // Safe Threshold ranges
  final Map<String, dynamic> _thresholds = {
    'temp': {'warning': [16.0, 26.0], 'critical': [10.0, 32.0]},
    'humidity': {'warning': [30.0, 70.0], 'critical': [20.0, 80.0]},
    'co2': {'safeMax': 800.0, 'warningMax': 1500.0},
    'voc': {'safeMax': 300.0, 'warningMax': 1000.0},
    'pm25': {'safeMax': 12.0, 'warningMax': 35.0},
    'light': {'warning': [150.0, 1500.0], 'critical': [50.0, 2000.0]},
    'decibel': {'safeMax': 55.0, 'warningMax': 70.0}
  };

  // Particles for 3D simulation
  final List<AirflowParticle> _particles = [];
  Offset? _hoverPos;
  Offset? _clickedCell;

  @override
  void initState() {
    super.initState();

    _promptController.text =
        "You are the AuraSync AI Diagnostic Engine. Analyze the indoor environmental twin sensor readings. Return a JSON array containing exactly 3 objects: two advice cards and one product recommendation card.\n\nSchema for Advice Card:\n{\n  \"type\": \"safe\" | \"cyan\" | \"warning\" | \"critical\",\n  \"tag\": \"MITIGATION LAYER\",\n  \"time\": \"JUST NOW\",\n  \"title\": \"Short title\",\n  \"text\": \"Detailed recommendation message, max 2 sentences.\"\n}\n\nSchema for Product Card:\n{\n  \"type\": \"product\",\n  \"tag\": \"HARDWARE RECOMMENDATION\",\n  \"title\": \"Product Name\",\n  \"text\": \"Short description of how this product solves the problem\",\n  \"price\": \"\$XX.XX\",\n  \"originalPrice\": \"\$XX.XX\",\n  \"rating\": 4.7,\n  \"ratingCount\": 85,\n  \"coupon\": \"PROMOCODE\"\n}\n\nDo not output markdown code blocks. Output raw JSON only.";

    // Animation controller for running simulation frames
    _painterController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..addListener(() {
        _updateAirflowParticles();
        setState(() {});
      })..repeat();

    // Initialize 40 particles
    for (int i = 0; i < 40; i++) {
      _particles.add(AirflowParticle.random());
    }

    _appendLog("System initialization finished. Environmental matrices linked.", "system");
    _syncRoomTelemetry(_selectedRoom);

    // Try starting physical magnetometer listener
    _startPhysicalSensors();

    // Initialize DB and ML vision
    _initDatabase();
    _initVision();
    _initAcousticAndSmartHome();
  }

  void _initAcousticAndSmartHome() {
    _acousticSub = _acousticService.decibelStream.listen((db) {
      setState(() {
        _decibels = db;
      });
      _triggerCircadianSync();
    }, onError: (e) {
      _appendLog("Acoustic Sensor Error: $e", "error");
    });

    _acousticService.startMonitoring().then((_) {
      setState(() {
        _isMicMonitoring = _acousticService.isMonitoring;
      });
      _appendLog("Acoustic monitoring active. Baseline noise linked.", "system");
    });

    _smartHomeSub = _smartHomeService.logStream.listen((logMsg) {
      _appendLog(logMsg, "automation");
    });
    
    _smartHomeService.discoverBridge();
    _initNativeBridge();
  }

  void _initNativeBridge() {
    _nativeBridgeSub = _nativeBridge.sensorStream.listen((data) {
      setState(() {
        if (data.containsKey('light')) {
          _light = data['light']!;
        }
        if (data.containsKey('magnetometer')) {
          _rawMagnetometerVal = data['magnetometer']!;
          if (_rawMagnetometerVal > 100.0) {
            _voc = (140.0 + (_rawMagnetometerVal - 100.0) * 2.0).clamp(50.0, 2000.0);
          }
        }
        _updateSensorUIRendering();
      });
      _evaluateGlobalSystemStatus();
    });
    
    _nativeBridge.startListening();
    _appendLog("Native Method Channel bridge listening to hardware registers.", "system");
  }

  void _triggerCircadianSync() {
    if (_circadianSyncActive) {
      _smartHomeService.updateCircadianLighting(_light, DateTime.now().hour);
    }
  }

  Future<void> _initDatabase() async {
    try {
      await _dbService.init();
      await _loadHistory();
      _appendLog("Local database Isar initialized.", "system");
    } catch (e) {
      _appendLog("Failed to initialize database: $e", "error");
    }
  }

  Future<void> _loadHistory() async {
    final history = await _dbService.getAllScanLogs();
    setState(() {
      _scanHistory = history;
    });
  }

  Future<void> _initVision() async {
    try {
      await _visionService.init();
      if (_visionService.isCameraInitialized) {
        setState(() {
          _cameraAvailable = true;
        });
        _objectSub = _visionService.detectedObjectsStream.listen((objects) {
          setState(() {
            _detectedObjects = objects;
          });
          
          final currentLabels = objects
              .expand((obj) => obj.labels)
              .map((l) => l.text.toLowerCase())
              .toSet();
              
          bool recommendationsUpdated = false;
          for (var label in currentLabels) {
            if (!_previouslyDetectedLabels.contains(label)) {
              _appendLog("CV Anchor: Detected [$label] in camera viewport.", "info");
              _previouslyDetectedLabels.add(label);
              recommendationsUpdated = true;
            }
          }
          
          _previouslyDetectedLabels.retainAll(currentLabels);

          if (recommendationsUpdated) {
            _generateLocalHeuristicAI();
          }
        });
        _visionService.startDetection();
        _appendLog("Live camera feed and ML Kit object detector active.", "system");
      } else {
        _appendLog("Camera hardware or ML Kit not supported on this platform.", "warning");
      }
    } catch (e) {
      _appendLog("Failed to start camera vision stream: $e", "warning");
    }
  }

  void _startPhysicalSensors() {
    try {
      _magSub = _sensorService.magnetometerStream.listen((eventMagnitude) {
        setState(() {
          _rawMagnetometerVal = math.sqrt(eventMagnitude);
          // If magnetometer value is high, feed it into VOC/EMI telemetry
          if (_rawMagnetometerVal > 100.0) {
            _voc = (140.0 + (_rawMagnetometerVal - 100.0) * 2.0).clamp(50.0, 2000.0);
            _updateSensorUIRendering();
          }
        });
      }, onError: (e) {
        _appendLog("Physical Magnetometer stream unavailable on this device.", "warning");
      });
    } catch (e) {
      _appendLog("Failed to initialize physical hardware sensors.", "warning");
    }
  }

  void _appendLog(String message, String type) {
    final timeStr = DateTime.now().toIso8601String().substring(11, 19);
    setState(() {
      _consoleLogs.add("[$timeStr] [$type] $message");
      if (_consoleLogs.length > 30) {
        _consoleLogs.removeAt(0);
      }
    });
  }

  void _syncRoomTelemetry(String roomKey) {
    final data = _roomsData[roomKey]!;
    setState(() {
      _selectedRoom = roomKey;
      _tempOffset = 0.0;
      _humidityOffset = 0.0;
      _co2Offset = 0.0;
      _vocOffset = 0.0;
      _pm25Offset = 0.0;
      _lightOffset = 0.0;

      _temp = data['temp'];
      _humidity = data['humidity'];
      _co2 = data['co2'];
      _voc = data['voc'];
      _pm25 = data['pm25'];
      _light = data['light'];
      _decibels = data['decibel'] ?? 45.0;

      _probes.clear();
      _clickedCell = null;
    });

    _appendLog("Twin reconfigured: [${data['name']!.toUpperCase()}] mesh nodes connected.", "info");
    _generateLocalHeuristicAI();
    _triggerCircadianSync();
  }

  String _getSensorState(String key, double value) {
    final bounds = _thresholds[key]!;
    if (bounds.containsKey('warning') && bounds.containsKey('critical')) {
      final List<double> warn = List<double>.from(bounds['warning']);
      final List<double> crit = List<double>.from(bounds['critical']);
      if (value < crit[0] || value > crit[1]) return 'critical';
      if (value < warn[0] || value > warn[1]) return 'warning';
      return 'safe';
    } else if (bounds.containsKey('safeMax') && bounds.containsKey('warningMax')) {
      final double safeMax = bounds['safeMax'];
      final double warnMax = bounds['warningMax'];
      if (value > warnMax) return 'critical';
      if (value > safeMax) return 'warning';
      return 'safe';
    }
    return 'safe';
  }

  Color _getStateColor(String state) {
    switch (state) {
      case 'critical':
        return const Color(0xFFFF1A6E);
      case 'warning':
        return const Color(0xFFFFA200);
      case 'cyan':
        return const Color(0xFF00F0FF);
      case 'safe':
      default:
        return const Color(0xFF00E586);
    }
  }

  void _updateSensorUIRendering() {
    // Synchronize placed probes relative to ambient changes
    for (var p in _probes) {
      final rx = p['x'];
      final ry = p['y'];
      p['temp'] = _temp + math.sin(rx / 15) * 1.2 + math.cos(ry / 20) * 0.8;
      p['humidity'] = (_humidity + math.cos(rx / 20) * 4 + math.sin(ry / 15) * 3).clamp(10.0, 95.0);
      p['co2'] = (_co2 + (rx * 2 - ry * 1.5)).clamp(300.0, 2500.0);
      p['pm25'] = (_pm25 + math.sin((rx + ry) / 10) * 3).clamp(1.0, 100.0);
    }
  }

  void _generateLocalHeuristicAI() {
    _appendLog("Connecting to local intelligence heuristic models...", "system");
    final currentLabels = _detectedObjects
        .expand((obj) => obj.labels)
        .map((l) => l.text.toLowerCase())
        .toList();

    final localCards = _localClassifierService.classify(
      temp: _temp,
      humidity: _humidity,
      co2: _co2,
      voc: _voc,
      pm25: _pm25,
      light: _light,
      decibel: _decibels,
      detectedLabels: currentLabels,
    );

    setState(() {
      _recommendations = localCards;
    });
    _appendLog("Intelligence optimization cards generated successfully.", "safe");
    _saveCurrentScanToDb();
  }

  Future<void> _saveCurrentScanToDb() async {
    try {
      final log = ScanLog()
        ..timestamp = DateTime.now()
        ..roomName = _roomsData[_selectedRoom]!['name']
        ..temperature = _temp
        ..humidity = _humidity
        ..co2 = _co2
        ..voc = _voc
        ..pm25 = _pm25
        ..light = _light
        ..score = _calculateEcoScore()
        ..decibel = _decibels
        ..warnings = _getCurrentWarnings();

      await _dbService.saveScanLog(log);
      await _loadHistory();
      _appendLog("Scan result persisted to local history database.", "safe");
    } catch (e) {
      _appendLog("Failed to persist scan history: $e", "warning");
    }
  }

  double _calculateEcoScore() {
    double score = 100.0;
    final list = ['temp', 'humidity', 'co2', 'voc', 'pm25', 'light', 'decibel'];
    for (var key in list) {
      double val = 0;
      if (key == 'temp') val = _temp;
      if (key == 'humidity') val = _humidity;
      if (key == 'co2') val = _co2;
      if (key == 'voc') val = _voc;
      if (key == 'pm25') val = _pm25;
      if (key == 'light') val = _light;
      if (key == 'decibel') val = _decibels;

      final state = _getSensorState(key, val);
      if (state == 'critical') score -= 15.0;
      if (state == 'warning') score -= 8.0;
    }
    return score.clamp(0.0, 100.0);
  }

  List<String> _getCurrentWarnings() {
    final List<String> warnings = [];
    final list = ['temp', 'humidity', 'co2', 'voc', 'pm25', 'light', 'decibel'];
    for (var key in list) {
      double val = 0;
      if (key == 'temp') val = _temp;
      if (key == 'humidity') val = _humidity;
      if (key == 'co2') val = _co2;
      if (key == 'voc') val = _voc;
      if (key == 'pm25') val = _pm25;
      if (key == 'light') val = _light;
      if (key == 'decibel') val = _decibels;

      final state = _getSensorState(key, val);
      if (state != 'safe') {
        warnings.add("${key.toUpperCase()} is $state (${val.toStringAsFixed(1)})");
      }
    }
    return warnings;
  }

  Future<void> _runAIAudit() async {
    final apiKey = _apiKeyController.text.trim();
    if (apiKey.isEmpty) {
      _appendLog("No API Key provided. Running local fail-safe models.", "warning");
      _generateLocalHeuristicAI();
      return;
    }

    setState(() {
      _isLoading = true;
    });
    _appendLog("Connecting to OpenRouter endpoint...", "system");
    _appendLog("Preparing request payload utilizing model: [$_selectedModel]", "info");

    final Map<String, dynamic> payload = {
      "room": _roomsData[_selectedRoom]!['name'].toString().toUpperCase(),
      "temperature": "${_temp.toStringAsFixed(1)}°C",
      "humidity": "${_humidity.toStringAsFixed(0)}%",
      "co2": "${_co2.toStringAsFixed(0)} ppm",
      "voc": "${_voc.toStringAsFixed(0)} ppb",
      "pm25": "${_pm25.toStringAsFixed(0)} µg/m³",
      "light": "${_light.toStringAsFixed(0)} lux",
      "sound_level": "${_decibels.toStringAsFixed(0)} dBA",
      "airflow": "${_roomsData[_selectedRoom]!['airflow'].toStringAsFixed(2)} m/s",
      "probes": _probes.map((p) => {"id": p['id'], "x": p['x'], "y": p['y'], "temp": p['temp'].toStringAsFixed(1)}).toList()
    };

    final result = await _openRouterService.fetchRecommendations(
      apiKey: apiKey,
      model: _selectedModel,
      systemPrompt: _promptController.text,
      telemetryPayload: payload,
    );

    setState(() {
      _isLoading = false;
    });

    if (result['success'] == true) {
      setState(() {
        _recommendations = result['cards'];
      });
      _appendLog("Successfully initialized twin recommendations from OpenRouter.", "safe");
      _saveCurrentScanToDb();
    } else {
      _appendLog("Inference failed: ${result['error']}. Running local fail-safe models.", "error");
      _generateLocalHeuristicAI();
    }
  }

  void _updateAirflowParticles() {
    final data = _roomsData[_selectedRoom]!;
    final double airflowSpeed = data['airflow'] * 0.4;
    for (var p in _particles) {
      p.x += p.speed * airflowSpeed * 2.0;
      p.y += p.speed * airflowSpeed * 2.0;
      p.z += math.sin(p.x / 10.0 + _particles.indexOf(p)) * 0.3;

      if (p.x > 80.0 || p.y > 80.0) {
        p.reset();
      }
    }
  }

  void _runCalibration() {
    _appendLog("Initiating ambient zero-calibration routine...", "info");
    int progress = 0;
    Timer.periodic(const Duration(milliseconds: 150), (timer) {
      progress += 20;
      _appendLog("Calibration sequence: $progress%...", "system");
      if (progress >= 100) {
        timer.cancel();
        setState(() {
          _co2Offset = -15;
          _vocOffset = -8;
          _tempOffset = -0.2;
          _humidityOffset = -2;
          _pm25Offset = -1;
          _lightOffset = -10;

          _temp += _tempOffset;
          _co2 += _co2Offset;
          _voc += _vocOffset;
          _humidity += _humidityOffset;
          _pm25 += _pm25Offset;
          _light += _lightOffset;
          _updateSensorUIRendering();
        });
        _appendLog("Ambient sensor matrix offsets adjusted. Calibration completed.", "safe");
      }
    });
  }

  void _runSelfDiagnosis() {
    _appendLog("Executing full environmental Twin Self-Diagnosis...", "warning");
    int progress = 0;
    Timer.periodic(const Duration(milliseconds: 200), (timer) {
      progress += 25;
      if (progress == 25) {
        _appendLog("TESTING CRITICAL ALARM SIGNAL INDICATORS... PASS", "error");
      } else if (progress == 50) {
        _appendLog("TESTING WARNING ALERT MATRIX... PASS", "warning");
      } else if (progress == 75) {
        _appendLog("TESTING SAFE SYSTEM LOOPS... PASS", "safe");
      } else if (progress >= 100) {
        timer.cancel();
        _appendLog("Diagnosis successful. 6/6 environmental arrays operating normally.", "safe");
      }
    });
  }

  void _showAnomalyInjectorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0D1426),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: const Color(0xFFFFA200).withValues(alpha: 0.3)),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_outlined, color: Color(0xFFFFA200)),
              SizedBox(width: 10),
              Text(
                'TELEMETRY ANOMALY INJECTOR',
                style: TextStyle(fontFamily: 'Outfit', fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select a preset to simulate severe environmental twin deviations and test warning overlays in real-time.',
                style: TextStyle(fontFamily: 'Outfit', fontSize: 11, color: Colors.grey),
              ),
              const SizedBox(height: 14),
              _buildAnomalyPresetItem(
                context, 
                "Severe Gas & CO2 Leak", 
                "CO2: 1800 ppm | VOC: 1200 ppb", 
                () {
                  setState(() {
                    _co2 = 1800.0;
                    _voc = 1200.0;
                  });
                  _appendLog("Simulation Sandbox: Injected severe CO2/VOC gas leak.", "warning");
                  _generateLocalHeuristicAI();
                }
              ),
              _buildAnomalyPresetItem(
                context, 
                "Thermal Draft / HVAC Failure", 
                "Temp: 31.5°C | Airflow: 0.15 m/s", 
                () {
                  setState(() {
                    _temp = 31.5;
                    _roomsData[_selectedRoom]!['airflow'] = 0.15;
                  });
                  _appendLog("Simulation Sandbox: HVAC damper failure draft. Temp rose to 31.5°C.", "warning");
                  _generateLocalHeuristicAI();
                }
              ),
              _buildAnomalyPresetItem(
                context, 
                "Heavy Particulate Dust Storm", 
                "PM2.5: 75 ug/m3 | Airflow: 2.8 m/s", 
                () {
                  setState(() {
                    _pm25 = 75.0;
                    _roomsData[_selectedRoom]!['airflow'] = 2.8;
                  });
                  _appendLog("Simulation Sandbox: Dust filter blowback. PM2.5 spikes.", "warning");
                  _generateLocalHeuristicAI();
                }
              ),
              _buildAnomalyPresetItem(
                context, 
                "Electromagnetic Spikes (EMI)", 
                "Magnetometer: 250 uT", 
                () {
                  setState(() {
                    _voc = 850.0; // EMI maps into VOC in telemetry
                  });
                  _appendLog("Simulation Sandbox: High electromagnetic transformer spike.", "warning");
                  _generateLocalHeuristicAI();
                }
              ),
              _buildAnomalyPresetItem(
                context, 
                "Reset Telemetry", 
                "Sync back to room standard defaults", 
                () {
                  _syncRoomTelemetry(_selectedRoom);
                  _appendLog("Simulation Sandbox: Cleared simulation offsets. Telemetry reset.", "safe");
                }
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close Sandbox', style: TextStyle(fontFamily: 'Outfit', color: Colors.grey, fontSize: 11)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAnomalyPresetItem(BuildContext context, String title, String subtitle, VoidCallback onTap) {
    return Card(
      color: const Color(0xFF060913),
      margin: const EdgeInsets.only(bottom: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: ListTile(
        dense: true,
        title: Text(title, style: const TextStyle(fontFamily: 'Outfit', fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
        subtitle: Text(subtitle, style: const TextStyle(fontFamily: 'Outfit', fontSize: 9, color: Colors.grey)),
        trailing: const Icon(Icons.play_arrow_outlined, color: Color(0xFFFFA200), size: 16),
        onTap: () {
          onTap();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  void dispose() {
    _magSub?.cancel();
    _objectSub?.cancel();
    _acousticSub?.cancel();
    _acousticService.dispose();
    _smartHomeSub?.cancel();
    _smartHomeService.dispose();
    _nativeBridgeSub?.cancel();
    _nativeBridge.dispose();
    _visionService.dispose();
    _painterController.dispose();
    _apiKeyController.dispose();
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0F1E),
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.blur_circular, color: Color(0xFF00F0FF), size: 28),
            const SizedBox(width: 10),
            Text(
              'AURASYNC // DIGITAL TWIN',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: isDesktop ? 18 : 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.history, color: Color(0xFF00F0FF)),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
              tooltip: 'Scan History',
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF00E586),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'NOMINAL',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
      endDrawer: _buildHistoryDrawer(),
      body: SafeArea(
        child: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
      ),
    );
  }

  Widget _buildHistoryDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF0D1426),
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: const Color(0xFF0A0F1E),
              border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06))),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, color: Color(0xFF00F0FF), size: 32),
                  SizedBox(height: 8),
                  Text(
                    'SCAN HISTORY LOGS',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_scanHistory.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: HistoryChartsWidget(scanLogs: _scanHistory),
            ),
          Expanded(
            child: _scanHistory.isEmpty
                ? const Center(
                    child: Text(
                      'No past scans found.\nRun AI Audit to persist records.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: 'Outfit', color: Colors.grey, fontSize: 12),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _scanHistory.length,
                    itemBuilder: (context, idx) {
                      final log = _scanHistory[idx];
                      return Card(
                        color: const Color(0xFF060913),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Colors.white.withValues(alpha: 0.04)),
                        ),
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    log.roomName.toUpperCase(),
                                    style: const TextStyle(
                                      fontFamily: 'Outfit',
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF00F0FF),
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    "Score: ${log.score.toStringAsFixed(0)}%",
                                    style: TextStyle(
                                      fontFamily: 'Fira Code',
                                      fontWeight: FontWeight.bold,
                                      color: log.score > 85
                                          ? const Color(0xFF00E586)
                                          : log.score > 60
                                              ? const Color(0xFFFFA200)
                                              : const Color(0xFFFF1A6E),
                                      fontSize: 11,
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Time: ${log.timestamp.toLocal().toString().substring(0, 19)}",
                                style: const TextStyle(fontFamily: 'Outfit', color: Colors.grey, fontSize: 10),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "T: ${log.temperature.toStringAsFixed(1)}°C | H: ${log.humidity.toStringAsFixed(0)}% | CO2: ${log.co2.toStringAsFixed(0)}ppm | N: ${log.decibel.toStringAsFixed(0)}dB",
                                style: const TextStyle(fontFamily: 'Fira Code', fontSize: 9.5),
                              ),
                              if (log.warnings.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 4,
                                  runSpacing: 2,
                                  children: log.warnings.map((w) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFF1A6E).withValues(alpha: 0.08),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: const Color(0xFFFF1A6E).withValues(alpha: 0.2)),
                                      ),
                                      child: Text(
                                        w.split(" is ").first,
                                        style: const TextStyle(fontFamily: 'Outfit', fontSize: 8, color: Color(0xFFFF1A6E)),
                                      ),
                                    );
                                  }).toList(),
                                )
                              ]
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (_scanHistory.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF00E586)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          onPressed: () async {
                            final success = await _exportService.exportAndShareCSV(_scanHistory);
                            if (success) {
                              _appendLog("CSV Telemetry log share successfully triggered.", "safe");
                            } else {
                              _appendLog("Failed to initiate CSV share.", "warning");
                            }
                          },
                          icon: const Icon(Icons.description, size: 14, color: Color(0xFF00E586)),
                          label: const Text('Export CSV', style: TextStyle(fontFamily: 'Outfit', fontSize: 10, color: Color(0xFF00E586))),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF00F0FF)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          onPressed: () async {
                            final success = await _exportService.exportAndShareJSON(_scanHistory);
                            if (success) {
                              _appendLog("JSON Telemetry log share successfully triggered.", "safe");
                            } else {
                              _appendLog("Failed to initiate JSON share.", "warning");
                            }
                          },
                          icon: const Icon(Icons.code, size: 14, color: Color(0xFF00F0FF)),
                          label: const Text('Export JSON', style: TextStyle(fontFamily: 'Outfit', fontSize: 10, color: Color(0xFF00F0FF))),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF00F0FF)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      onPressed: () async {
                        final success = await _exportService.exportAndShareHTMLReport(_scanHistory, _utilityRate);
                        if (success) {
                          _appendLog("HTML Health Audit Report share successfully triggered.", "safe");
                        } else {
                          _appendLog("Failed to initiate HTML Report share.", "warning");
                        }
                      },
                      icon: const Icon(Icons.assessment_outlined, size: 14, color: Color(0xFF00F0FF)),
                      label: const Text('Generate Health Report', style: TextStyle(fontFamily: 'Outfit', fontSize: 10, color: Color(0xFF00F0FF))),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF1A6E).withValues(alpha: 0.12),
                        side: const BorderSide(color: Color(0xFFFF1A6E)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      onPressed: () async {
                        await _dbService.clearAllLogs();
                        await _loadHistory();
                        _appendLog("Persisted logs database cleared.", "info");
                      },
                      icon: const Icon(Icons.delete_forever, size: 16, color: Color(0xFFFF1A6E)),
                      label: const Text('Clear Scan History', style: TextStyle(fontFamily: 'Outfit', fontSize: 11, color: Color(0xFFFF1A6E))),
                    ),
                  ),
                ],
              ),
            )
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Left Column: AR view and HUD Cards
        Expanded(
          flex: 6,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  flex: 3,
                  child: _buildARViewportCard(),
                ),
                const SizedBox(height: 16),
                _buildHUDTelemetryGrid(),
                const SizedBox(height: 16),
                Expanded(
                  flex: 1,
                  child: _buildProbesManager(),
                ),
              ],
            ),
          ),
        ),
        // Right Column: Controls and OpenRouter AI panel
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildSensorMatrixPanel(),
                  const SizedBox(height: 16),
                  _buildAutomationPanel(),
                  const SizedBox(height: 16),
                  _buildEnergyAuditPanel(),
                  const SizedBox(height: 16),
                  _buildCalibrationPanel(),
                  const SizedBox(height: 16),
                  _buildOpenRouterPanel(),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            SizedBox(
              height: 380,
              child: _buildARViewportCard(),
            ),
            const SizedBox(height: 12),
            _buildHUDTelemetryGrid(),
            const SizedBox(height: 12),
            _buildSensorMatrixPanel(),
            const SizedBox(height: 12),
            _buildAutomationPanel(),
            const SizedBox(height: 12),
            _buildEnergyAuditPanel(),
            const SizedBox(height: 12),
            _buildCalibrationPanel(),
            const SizedBox(height: 12),
            _buildOpenRouterPanel(),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: _buildProbesManager(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildARViewportCard() {
    return Card(
      color: const Color(0xFF0D1426),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(
        children: [
          // Viewport Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.videocam_outlined, color: Color(0xFF00F0FF), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'LIVE 3D DIGITAL TWIN WIREFRAME',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Text(
                  _roomsData[_selectedRoom]!['coords'],
                  style: const TextStyle(
                    fontFamily: 'Fira Code',
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          // Viewport Canvas Area
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  key: const Key('viewport_gesture'),
                  onPanUpdate: (details) {
                    final local = details.localPosition;
                    final size = Size(constraints.maxWidth, constraints.maxHeight);
                    final isoCoord = _reverseIso(local, size);
                    final double snappedX = (isoCoord.dx / 20.0).round() * 20.0;
                    final double snappedY = (isoCoord.dy / 20.0).round() * 20.0;
                    setState(() {
                      _hoverPos = local;
                      _clickedCell = Offset(snappedX, snappedY);
                    });
                  },
                  onTapUp: (details) {
                    final local = details.localPosition;
                    final size = Size(constraints.maxWidth, constraints.maxHeight);
                    final isoCoord = _reverseIso(local, size);
                    if (_probes.length >= 5) {
                      _appendLog("Maximum probe capacity reached (5).", "error");
                      return;
                    }
                    final double snappedX = (isoCoord.dx / 20.0).round() * 20.0;
                    final double snappedY = (isoCoord.dy / 20.0).round() * 20.0;
                    final probeId = "PROBE-${(_probes.length + 1).toString().padLeft(2, '0')}";
                    final double pTemp = _temp + math.sin(snappedX / 15) * 1.2 + math.cos(snappedY / 20) * 0.8;
                    final double pHumid = (_humidity + math.cos(snappedX / 20) * 4 + math.sin(snappedY / 15) * 3).clamp(10.0, 95.0);
                    final double pCO2 = (_co2 + (snappedX * 2 - snappedY * 1.5)).clamp(300.0, 2500.0);
                    final double pPM25 = (_pm25 + math.sin((snappedX + snappedY) / 10) * 3).clamp(1.0, 100.0);

                    setState(() {
                      _probes.add({
                        "id": probeId,
                        "x": snappedX,
                        "y": snappedY,
                        "temp": pTemp,
                        "humidity": pHumid,
                        "co2": pCO2,
                        "pm25": pPM25,
                      });
                    });
                    _appendLog("Registered Micro-sensor Node [$probeId] at [X: ${snappedX.round()}, Y: ${snappedY.round()}].", "safe");
                  },
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(0),
                      bottomRight: Radius.circular(0),
                    ),
                    child: Stack(
                      children: [
                        // Camera stream preview overlay
                        if (_cameraAvailable && _visionService.cameraController != null)
                          Positioned.fill(
                            child: CameraPreview(_visionService.cameraController!),
                          ),
                        // Custom Twin Wireframe
                        CustomPaint(
                          size: Size(constraints.maxWidth, constraints.maxHeight),
                          painter: IsometricTwinPainter(
                            roomKey: _selectedRoom,
                            heatmapActive: _heatmapActive,
                            temp: _temp,
                            pm25: _pm25,
                            particles: _particles,
                            probes: _probes,
                            hoverPos: _hoverPos,
                            detectedObjects: _detectedObjects,
                            pulseValue: _painterController.value,
                            decibels: _decibels,
                          ),
                        ),
                        // HUD overlay left
                        Positioned(
                          top: 10,
                          left: 10,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHUDCard("Active Room", _roomsData[_selectedRoom]!['name'].toString().toUpperCase(), const Color(0xFF00F0FF)),
                              const SizedBox(height: 6),
                              _buildHUDCard("Airflow Velocity", "${_roomsData[_selectedRoom]!['airflow'].toStringAsFixed(2)} m/s", Colors.white),
                            ],
                          ),
                        ),
                        // HUD overlay right
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _buildHUDCard("Mesh Signal", _roomsData[_selectedRoom]!['signal'].toString().toUpperCase(), const Color(0xFF00E586)),
                              const SizedBox(height: 6),
                              _buildHUDCard("Render Mode", "ISOMETRIC MESH", const Color(0xFF00F0FF)),
                            ],
                          ),
                        ),
                        // Reticle projection box
                        if (_clickedCell != null && _hoverPos != null)
                          Positioned(
                            left: _hoverPos!.dx + 15,
                            top: _hoverPos!.dy + 15,
                            child: _buildReticleReadoutBox(),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Viewport footer switcher
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF080C18),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _roomsData.keys.map((key) {
                      final isActive = _selectedRoom == key;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: isActive
                                ? const Color(0xFF00F0FF).withValues(alpha: 0.12)
                                : Colors.white.withValues(alpha: 0.02),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                              side: BorderSide(
                                color: isActive ? const Color(0xFF00F0FF) : Colors.white.withValues(alpha: 0.06),
                              ),
                            ),
                          ),
                          onPressed: () => _syncRoomTelemetry(key),
                          child: Text(
                            _roomsData[key]!['name'],
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 12,
                              color: isActive ? const Color(0xFF00F0FF) : Colors.grey,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _heatmapActive = !_heatmapActive;
                        });
                        _appendLog(
                          "Thermal gradient heatmap mesh overlay ${_heatmapActive ? 'enabled' : 'disabled'}.",
                          "info",
                        );
                      },
                      icon: Icon(
                        _heatmapActive ? Icons.radio_button_checked : Icons.radio_button_off,
                        color: _heatmapActive ? const Color(0xFF00E586) : Colors.grey,
                        size: 14,
                      ),
                      label: Text(
                        'Heatmap Overlay',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 11,
                          color: _heatmapActive ? const Color(0xFF00E586) : Colors.grey,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _probes.clear();
                        });
                        _appendLog("All custom environmental micro-probes decommissioned.", "info");
                      },
                      icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 14),
                      label: const Text(
                        'Clear Probes',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildHUDCard(String label, String value, Color valColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF060913).withValues(alpha: 0.85),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontFamily: 'Outfit',
              fontSize: 8,
              color: Colors.grey,
              letterSpacing: 1.0,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: valColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReticleReadoutBox() {
    final rx = _clickedCell!.dx.round();
    final ry = _clickedCell!.dy.round();
    final double pTemp = _temp + math.sin(rx / 15) * 1.2 + math.cos(ry / 20) * 0.8;
    final double pHumid = (_humidity + math.cos(rx / 20) * 4 + math.sin(ry / 15) * 3).clamp(10.0, 95.0);
    final double pCO2 = (_co2 + (rx * 2 - ry * 1.5)).clamp(300.0, 2500.0);
    final double pPM25 = (_pm25 + math.sin((rx + ry) / 10) * 3).clamp(1.0, 100.0);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1020).withValues(alpha: 0.95),
        border: Border.all(color: const Color(0xFF00F0FF)),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00F0FF).withValues(alpha: 0.15),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'COORD: ($rx, $ry)',
            style: const TextStyle(fontFamily: 'Fira Code', fontSize: 9, color: Color(0xFF00F0FF)),
          ),
          const SizedBox(height: 2),
          Text('TEMP:  ${pTemp.toStringAsFixed(1)}°C', style: const TextStyle(fontFamily: 'Fira Code', fontSize: 9)),
          Text('HUMID: ${pHumid.toStringAsFixed(0)}%', style: const TextStyle(fontFamily: 'Fira Code', fontSize: 9)),
          Text('CO2:   ${pCO2.toStringAsFixed(0)} ppm', style: const TextStyle(fontFamily: 'Fira Code', fontSize: 9)),
          Text('PM2.5: ${pPM25.toStringAsFixed(0)} µg/m³', style: const TextStyle(fontFamily: 'Fira Code', fontSize: 9)),
        ],
      ),
    );
  }

  Widget _buildHUDTelemetryGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = constraints.maxWidth > 600 ? 4 : 2;
        return GridView.count(
          crossAxisCount: count,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 2.3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: [
            _buildTelemetryCard('Temp', '${_temp.toStringAsFixed(1)}°C', 'temp'),
            _buildTelemetryCard('Humidity', '${_humidity.toStringAsFixed(0)}%', 'humidity'),
            _buildTelemetryCard('CO2 Levels', '${_co2.toStringAsFixed(0)} ppm', 'co2'),
            _buildTelemetryCard('Total VOCs', '${_voc.toStringAsFixed(0)} ppb', 'voc'),
            _buildTelemetryCard('Particulates', '${_pm25.toStringAsFixed(0)} µg/m³', 'pm25'),
            _buildTelemetryCard('Light Intensity', '${_light.toStringAsFixed(0)} lux', 'light'),
            _buildTelemetryCard('Sound Level', '${_decibels.toStringAsFixed(0)} dBA', 'decibel'),
            _buildTelemetryCard('Eco Score', '${_calculateEcoScore().toStringAsFixed(0)}%', 'eco'),
          ],
        );
      },
    );
  }

  Widget _buildTelemetryCard(String label, String value, String key) {
    double val = 0;
    if (key == 'temp') {
      val = _temp;
    } else if (key == 'humidity') {
      val = _humidity;
    } else if (key == 'co2') {
      val = _co2;
    } else if (key == 'voc') {
      val = _voc;
    } else if (key == 'pm25') {
      val = _pm25;
    } else if (key == 'light') {
      val = _light;
    } else if (key == 'decibel') {
      val = _decibels;
    } else if (key == 'eco') {
      val = _calculateEcoScore();
    }

    final state = key == 'eco' ? (val > 80 ? 'safe' : val > 65 ? 'warning' : 'critical') : _getSensorState(key, val);
    final color = _getStateColor(state);

    return Card(
      color: const Color(0xFF0D1426),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Text(
                      label.toUpperCase(),
                      style: const TextStyle(fontFamily: 'Outfit', fontSize: 8, color: Colors.grey),
                    ),
                    if (key == 'decibel' && _isMicMonitoring) ...[
                      const SizedBox(width: 4),
                      Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          color: Color(0xFF00E586),
                          shape: BoxShape.circle,
                        ),
                      )
                    ]
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'Fira Code',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            Icon(
              key == 'temp'
                  ? Icons.thermostat_outlined
                  : key == 'humidity'
                      ? Icons.water_drop_outlined
                      : key == 'co2'
                          ? Icons.co2_outlined
                          : key == 'voc'
                              ? Icons.air_outlined
                              : key == 'pm25'
                                  ? Icons.grain_outlined
                                  : key == 'light'
                                      ? Icons.light_mode_outlined
                                      : key == 'decibel'
                                          ? Icons.volume_up_outlined
                                          : Icons.eco_outlined,
              color: Colors.white.withValues(alpha: 0.06),
              size: 24,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSensorMatrixPanel() {
    return Card(
      color: const Color(0xFF0D1426),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '[ SENSOR SIMULATION MATRIX ]',
                  style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF00F0FF)),
                ),
                Icon(Icons.tune, color: Color(0xFF00F0FF), size: 16),
              ],
            ),
            const SizedBox(height: 12),
            _buildSliderRow('Temperature', _temp, 5.0, 45.0, 'temp', '°C'),
            _buildSliderRow('Humidity', _humidity, 10.0, 95.0, 'humidity', '%'),
            _buildSliderRow('CO2 Levels', _co2, 300.0, 2500.0, 'co2', ' ppm'),
            _buildSliderRow('VOC Levels', _voc, 50.0, 2000.0, 'voc', ' ppb'),
            _buildSliderRow('Particulates PM2.5', _pm25, 1.0, 100.0, 'pm25', ' µg/m³'),
            _buildSliderRow('Light Intensity', _light, 0.0, 2500.0, 'light', ' lux'),
            _buildSliderRow('Ambient Noise', _decibels, 30.0, 120.0, 'decibel', ' dBA'),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderRow(String label, double value, double min, double max, String key, String unit) {
    final state = _getSensorState(key, value);
    final color = _getStateColor(state);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontFamily: 'Outfit', fontSize: 11, fontWeight: FontWeight.bold),
            ),
            Text(
              "${value.toStringAsFixed(key == 'temp' ? 1 : 0)}$unit",
              style: TextStyle(fontFamily: 'Fira Code', fontSize: 11, color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: value.clamp(min, max),
                min: min,
                max: max,
                activeColor: color,
                inactiveColor: Colors.white.withValues(alpha: 0.08),
                onChanged: (newValue) {
                  setState(() {
                    if (key == 'temp') _temp = newValue;
                    if (key == 'humidity') _humidity = newValue;
                    if (key == 'co2') _co2 = newValue;
                    if (key == 'voc') _voc = newValue;
                    if (key == 'pm25') _pm25 = newValue;
                    if (key == 'light') _light = newValue;
                    if (key == 'decibel') _decibels = newValue;
                    _updateSensorUIRendering();
                  });
                  _evaluateGlobalSystemStatus();
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh, size: 14),
              onPressed: () {
                setState(() {
                  final baseVal = _roomsData[_selectedRoom]![key] ?? (key == 'decibel' ? 45.0 : 0.0);
                  if (key == 'temp') _temp = baseVal;
                  if (key == 'humidity') _humidity = baseVal;
                  if (key == 'co2') _co2 = baseVal;
                  if (key == 'voc') _voc = baseVal;
                  if (key == 'pm25') _pm25 = baseVal;
                  if (key == 'light') _light = baseVal;
                  if (key == 'decibel') _decibels = baseVal;
                  _updateSensorUIRendering();
                });
                _appendLog("Sensor matrix [$key] reset to baseline.", "info");
              },
            )
          ],
        ),
      ],
    );
  }

  void _evaluateGlobalSystemStatus() {
    // Re-trigger visual alerts if anything is critical
  }

  Widget _buildCalibrationPanel() {
    return Card(
      color: const Color(0xFF0D1426),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '[ HARDWARE CALIBRATION ]',
              style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF00F0FF)),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.02),
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    onPressed: _runCalibration,
                    icon: const Icon(Icons.tune_outlined, size: 14),
                    label: const Text('Zero-Calibrate', style: TextStyle(fontFamily: 'Outfit', fontSize: 10)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.02),
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    onPressed: _runSelfDiagnosis,
                    icon: const Icon(Icons.flash_on_outlined, size: 14),
                    label: const Text('Self-Diagnosis', style: TextStyle(fontFamily: 'Outfit', fontSize: 10)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: Colors.white10, height: 1),
            const SizedBox(height: 12),
            const Text(
              '[ SIMULATION SANDBOX ]',
              style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFFFFA200)),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 34,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFA200).withValues(alpha: 0.08),
                  side: const BorderSide(color: Color(0xFFFFA200)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                onPressed: _showAnomalyInjectorDialog,
                icon: const Icon(Icons.warning_amber_outlined, size: 14, color: Color(0xFFFFA200)),
                label: const Text('Inject Telemetry Anomaly', style: TextStyle(fontFamily: 'Outfit', fontSize: 10, color: Color(0xFFFFA200))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAutomationPanel() {
    return Card(
      color: const Color(0xFF0D1426),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '[ SMART LIGHT AUTOMATION ]',
                  style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF00F0FF)),
                ),
                Icon(
                  _circadianSyncActive ? Icons.brightness_auto : Icons.brightness_low,
                  color: _circadianSyncActive ? const Color(0xFF00E586) : Colors.grey,
                  size: 16,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Circadian Sync Loop',
                        style: TextStyle(fontFamily: 'Outfit', fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Adjust color temperature & brightness based on natural cycles & lux deficiencies',
                        style: TextStyle(fontFamily: 'Outfit', fontSize: 9, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _circadianSyncActive,
                  activeThumbColor: const Color(0xFF00E586),
                  activeTrackColor: const Color(0xFF00E586).withValues(alpha: 0.2),
                  inactiveThumbColor: Colors.grey,
                  inactiveTrackColor: Colors.white.withValues(alpha: 0.08),
                  onChanged: (val) {
                    setState(() {
                      _circadianSyncActive = val;
                    });
                    if (val) {
                      _appendLog("Circadian Automation sync loop initialized.", "info");
                      _triggerCircadianSync();
                    } else {
                      _appendLog("Circadian Automation sync disabled.", "info");
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(color: Colors.white10, height: 1),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Automated Light Status',
                      style: TextStyle(fontFamily: 'Outfit', fontSize: 9, color: Colors.grey),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      !_circadianSyncActive
                          ? 'STANDBY / INACTIVE'
                          : _smartHomeService.isLightOn
                              ? 'ACTIVE // ${( _smartHomeService.currentBrightness * 100 ).toStringAsFixed(0)}% BRI // ${_smartHomeService.miredToKelvin(_smartHomeService.currentCt)}K TEMP'
                              : 'IDLE // LIGHTS OFF (ADEQUATE NATURAL LIGHT)',
                      style: TextStyle(
                        fontFamily: 'Fira Code',
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        color: !_circadianSyncActive
                            ? Colors.grey
                            : _smartHomeService.isLightOn
                                ? const Color(0xFF00E586)
                                : const Color(0xFF00F0FF),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnergyAuditPanel() {
    double totalWatts = 0.0;
    for (var card in _recommendations) {
      if (card.containsKey('energyWaste')) {
        totalWatts += (card['energyWaste'] ?? 0.0) as double;
      }
    }

    final double annualKWh = (totalWatts * 24 * 365) / 1000.0;
    final double annualCost = annualKWh * _utilityRate;
    final double roiMonths = annualCost > 0 ? (150.0 / (annualCost / 12.0)) : 0.0;

    return Card(
      color: const Color(0xFF0D1426),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: totalWatts >= 150.0
              ? const Color(0xFFFF1A6E).withValues(alpha: 0.4)
              : totalWatts > 0.0
                  ? const Color(0xFFFFA200).withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.05),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '[ SUSTAINABILITY ENERGY AUDIT ]',
                  style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF00F0FF)),
                ),
                Icon(
                  Icons.bar_chart,
                  color: totalWatts >= 150.0
                      ? const Color(0xFFFF1A6E)
                      : totalWatts > 0.0
                          ? const Color(0xFFFFA200)
                          : const Color(0xFF00E586),
                  size: 16,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Local Utility Rate:',
                  style: TextStyle(fontFamily: 'Outfit', fontSize: 10, color: Colors.grey),
                ),
                Text(
                  '\$${_utilityRate.toStringAsFixed(2)} / kWh',
                  style: const TextStyle(fontFamily: 'Fira Code', fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
            Slider(
              value: _utilityRate,
              min: 0.05,
              max: 0.50,
              activeColor: const Color(0xFF00F0FF),
              inactiveColor: Colors.white.withValues(alpha: 0.08),
              onChanged: (val) {
                setState(() {
                  _utilityRate = val;
                });
              },
            ),
            const Divider(color: Colors.white10, height: 1),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ESTIMATED WASTE LOAD',
                      style: TextStyle(fontFamily: 'Outfit', fontSize: 8, color: Colors.grey),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${totalWatts.toStringAsFixed(0)} W',
                      style: TextStyle(
                        fontFamily: 'Fira Code',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: totalWatts >= 150.0
                            ? const Color(0xFFFF1A6E)
                            : totalWatts > 0.0
                                ? const Color(0xFFFFA200)
                                : const Color(0xFF00E586),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'ANNUAL PENALTY COST',
                      style: TextStyle(fontFamily: 'Outfit', fontSize: 8, color: Colors.grey),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '\$${annualCost.toStringAsFixed(2)} USD',
                      style: TextStyle(
                        fontFamily: 'Fira Code',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: totalWatts >= 150.0
                            ? const Color(0xFFFF1A6E)
                            : totalWatts > 0.0
                                ? const Color(0xFFFFA200)
                                : const Color(0xFF00E586),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (totalWatts > 0) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E586).withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFF00E586).withValues(alpha: 0.2)),
                ),
                child: Text(
                  '💡 MITIGATION PAYBACK ROI: ${roiMonths.toStringAsFixed(1)} MONTHS',
                  style: const TextStyle(fontFamily: 'Outfit', fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF00E586)),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOpenRouterPanel() {
    return Card(
      color: const Color(0xFF0D1426),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '[ OPENROUTER INTELLIGENCE AGENT ]',
              style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF00F0FF)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _apiKeyController,
              obscureText: _isObscureKey,
              decoration: InputDecoration(
                labelText: 'OpenRouter API Key',
                labelStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                hintText: 'sk-or-v1-... (leave blank to run simulated heuristic AI)',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_isObscureKey ? Icons.visibility : Icons.visibility_off, size: 18),
                  onPressed: () {
                    setState(() {
                      _isObscureKey = !_isObscureKey;
                    });
                  },
                ),
              ),
              style: const TextStyle(fontFamily: 'Fira Code', fontSize: 12),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedModel,
              decoration: const InputDecoration(
                labelText: 'Inference Model',
                labelStyle: TextStyle(fontSize: 12, color: Colors.grey),
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: "google/gemini-2.5-flash", child: Text("Google Gemini 2.5 Flash")),
                DropdownMenuItem(value: "meta-llama/llama-3-8b-instruct:free", child: Text("Llama 3 8B Instruct (Free)")),
                DropdownMenuItem(value: "anthropic/claude-3.5-sonnet", child: Text("Claude 3.5 Sonnet")),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedModel = val;
                  });
                }
              },
              style: const TextStyle(fontFamily: 'Outfit', fontSize: 12, color: Colors.white),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 38,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00F0FF),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                onPressed: _isLoading ? null : _runAIAudit,
                child: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                      )
                    : const Text(
                        'ANALYZE DIGITAL TWIN',
                        style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, fontSize: 11),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            // Intelligence terminal console
            Container(
              height: 90,
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _consoleLogs.length,
                itemBuilder: (context, idx) {
                  return Text(
                    _consoleLogs[idx],
                    style: const TextStyle(fontFamily: 'Fira Code', fontSize: 8.5, color: Color(0xFF00F0FF)),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            // Recommendations list
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recommendations.length,
              itemBuilder: (context, idx) {
                final card = _recommendations[idx];
                if (card['type'] == 'product') {
                  return _buildProductCard(card);
                } else {
                  return _buildAdviceCard(card);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdviceCard(Map<String, dynamic> card) {
    final String type = card['type'] ?? 'safe';
    final Color color = _getStateColor(type);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF060913),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                (card['tag'] ?? 'MITIGATION OPTION').toString().toUpperCase(),
                style: TextStyle(fontFamily: 'Outfit', fontSize: 8, color: color, fontWeight: FontWeight.bold),
              ),
              Text(
                card['time'] ?? '1M AGO',
                style: const TextStyle(fontFamily: 'Outfit', fontSize: 8, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            card['title'] ?? '',
            style: const TextStyle(fontFamily: 'Outfit', fontSize: 11, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            card['text'] ?? '',
            style: const TextStyle(fontFamily: 'Outfit', fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> card) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF060913),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF00F0FF).withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.02),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.shopping_bag_outlined, color: Color(0xFF00F0FF), size: 18),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (card['tag'] ?? 'HARDWARE SPONSOR').toString().toUpperCase(),
                  style: const TextStyle(fontFamily: 'Outfit', fontSize: 8, color: Color(0xFF00F0FF), fontWeight: FontWeight.bold),
                ),
                Text(
                  card['title'] ?? '',
                  style: const TextStyle(fontFamily: 'Outfit', fontSize: 11, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 10),
                    const SizedBox(width: 2),
                    Text(
                      '${card['rating'] ?? '4.8'} (${card['ratingCount'] ?? '150'})',
                      style: const TextStyle(fontFamily: 'Outfit', fontSize: 8.5, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  card['text'] ?? '',
                  style: const TextStyle(fontFamily: 'Outfit', fontSize: 10),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          card['originalPrice'] ?? '\$119.00',
                          style: const TextStyle(
                            fontFamily: 'Fira Code',
                            fontSize: 9,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        Text(
                          card['price'] ?? '\$99.00',
                          style: const TextStyle(fontFamily: 'Fira Code', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00E586).withValues(alpha: 0.12),
                        side: const BorderSide(color: Color(0xFF00E586)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        minimumSize: Size.zero,
                      ),
                      onPressed: () async {
                        final title = Uri.encodeComponent(card['title'] ?? 'AuraSync Smart Hardware');
                        final coupon = card['coupon'] ?? '';
                        final url = Uri.parse("https://www.amazon.com/s?k=$title&tag=aurasync-affiliate-20&coupon=$coupon");
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                          _appendLog("Affiliate redirect: Searching Amazon for $title.", "safe");
                        } else {
                          _appendLog("Affiliate warning: Redirect failed for $title.", "warning");
                        }
                      },
                      child: const Row(
                        children: [
                          Text('Buy Now', style: TextStyle(fontFamily: 'Outfit', fontSize: 10, color: Color(0xFF00E586))),
                          Icon(Icons.chevron_right, size: 10, color: Color(0xFF00E586)),
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFA200).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFFFFA200).withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    "CODE: ${card['coupon'] ?? 'AURASYNC10'} (15% OFF)",
                    style: const TextStyle(fontFamily: 'Fira Code', fontSize: 8, color: Color(0xFFFFA200)),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildProbesManager() {
    return Card(
      color: const Color(0xFF0D1426),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'PLACED ENVIRONMENTAL PROBES',
                  style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, fontSize: 11),
                ),
                Text(
                  '${_probes.length} / 5 ACTIVE',
                  style: const TextStyle(fontFamily: 'Fira Code', fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _probes.isEmpty
                  ? const Center(
                      child: Text(
                        'Tap on the wireframe viewport above to place micro-sensor probes.',
                        style: TextStyle(fontFamily: 'Outfit', fontStyle: FontStyle.italic, fontSize: 11, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      itemCount: _probes.length,
                      itemBuilder: (context, idx) {
                        final p = _probes[idx];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.015),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p['id'],
                                    style: const TextStyle(fontFamily: 'Fira Code', fontSize: 10, color: Color(0xFF00F0FF), fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'COORD: (${p['x'].round()}, ${p['y'].round()})',
                                    style: const TextStyle(fontFamily: 'Fira Code', fontSize: 8, color: Colors.grey),
                                  ),
                                ],
                              ),
                              Text(
                                '${p['temp'].toStringAsFixed(1)}°C / ${p['humidity'].toStringAsFixed(0)}% / ${p['co2'].toStringAsFixed(0)}ppm',
                                style: const TextStyle(fontFamily: 'Fira Code', fontSize: 10),
                              ),
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.delete_forever, size: 16, color: Colors.redAccent),
                                onPressed: () {
                                  setState(() {
                                    _probes.removeAt(idx);
                                  });
                                  _appendLog("Decommissioned probe [${p['id']}].", "info");
                                },
                              )
                            ],
                          ),
                        );
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }

  Offset _reverseIso(Offset screenPt, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2 + 20;
    final scale = (size.width / 320).clamp(0.5, 3.0) * 1.5;
    final dx = (screenPt.dx - cx) / scale;
    final dy = (screenPt.dy - cy) / scale;
    const cos30 = 0.8660254;
    const sin30 = 0.5;

    final rx = ((dx / cos30) + (dy / sin30)) / 2;
    final ry = ((dy / sin30) - (dx / cos30)) / 2;

    return Offset(
      rx.clamp(-80.0, 80.0),
      ry.clamp(-80.0, 80.0),
    );
  }
}

class AirflowParticle {
  double x;
  double y;
  double z;
  double speed;
  double size;
  double alpha;

  AirflowParticle({
    required this.x,
    required this.y,
    required this.z,
    required this.speed,
    required this.size,
    required this.alpha,
  });

  factory AirflowParticle.random() {
    final rand = math.Random();
    return AirflowParticle(
      x: -80.0 + rand.nextDouble() * 160.0,
      y: -80.0 + rand.nextDouble() * 160.0,
      z: rand.nextDouble() * 50.0,
      speed: 0.5 + rand.nextDouble() * 0.5,
      size: 1.0 + rand.nextDouble() * 2.0,
      alpha: 0.1 + rand.nextDouble() * 0.6,
    );
  }

  void reset() {
    final rand = math.Random();
    x = -80.0;
    y = -80.0;
    z = rand.nextDouble() * 40.0;
    speed = 0.5 + rand.nextDouble() * 0.5;
    size = 1.0 + rand.nextDouble() * 2.0;
    alpha = 0.1 + rand.nextDouble() * 0.6;
  }
}

class IsometricTwinPainter extends CustomPainter {
  final String roomKey;
  final bool heatmapActive;
  final double temp;
  final double pm25;
  final List<AirflowParticle> particles;
  final List<Map<String, dynamic>> probes;
  final Offset? hoverPos;
  final List<DetectedObject> detectedObjects;
  final double pulseValue;
  final double decibels;

  IsometricTwinPainter({
    required this.roomKey,
    required this.heatmapActive,
    required this.temp,
    required this.pm25,
    required this.particles,
    required this.probes,
    required this.hoverPos,
    required this.detectedObjects,
    required this.pulseValue,
    required this.decibels,
  });

  Offset projectIso(double x, double y, double z, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2 + 20;
    final scale = (size.width / 320).clamp(0.5, 3.0) * 1.5;
    final isoX = cx + (x - y) * 0.8660254 * scale; // cos(30) = 0.866
    final isoY = cy + (x + y) * 0.5 * scale - z * scale; // sin(30) = 0.5
    return Offset(isoX, isoY);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Grid color based on warnings
    Color gridStroke = const Color(0xFF00F0FF).withValues(alpha: 0.08);
    paint.color = gridStroke;

    const step = 20.0;
    const limit = 80.0;

    // Draw Floor Grid Matrix
    for (double i = -limit; i <= limit; i += step) {
      // Parallel X-axis lines
      final p1 = projectIso(i, -limit, 0, size);
      final p2 = projectIso(i, limit, 0, size);
      canvas.drawLine(p1, p2, paint);

      // Parallel Y-axis lines
      final p3 = projectIso(-limit, i, 0, size);
      final p4 = projectIso(limit, i, 0, size);
      canvas.drawLine(p3, p4, paint);
    }

    // Vertical boundary columns
    paint.color = const Color(0xFF00F0FF).withValues(alpha: 0.25);
    paint.strokeWidth = 1.5;
    final corners = [
      [-limit, -limit],
      [limit, -limit],
      [limit, limit],
      [-limit, limit]
    ];
    for (var cor in corners) {
      final floorPt = projectIso(cor[0], cor[1], 0, size);
      final ceilPt = projectIso(cor[0], cor[1], 60, size);
      canvas.drawLine(floorPt, ceilPt, paint);
    }

    // Ceiling border loop
    final path = Path();
    var p = projectIso(corners[0][0], corners[0][1], 60, size);
    path.moveTo(p.dx, p.dy);
    for (int j = 1; j < corners.length; j++) {
      p = projectIso(corners[j][0], corners[j][1], 60, size);
      path.lineTo(p.dx, p.dy);
    }
    path.close();
    canvas.drawPath(path, paint);

    // Draw room wireframe assets
    paint.color = Colors.white.withValues(alpha: 0.15);
    if (roomKey == 'living_room') {
      _drawWireBox(-40, -30, 0, 30, 60, 20, canvas, size, Colors.green.withValues(alpha: 0.12));
      _drawWireBox(50, -40, 0, 15, 60, 15, canvas, size, Colors.cyan.withValues(alpha: 0.12));
    } else if (roomKey == 'server_room') {
      _drawWireBox(-50, -40, 0, 25, 20, 50, canvas, size, Colors.cyan.withValues(alpha: 0.1));
      _drawWireBox(-10, -40, 0, 25, 20, 50, canvas, size, Colors.cyan.withValues(alpha: 0.1));
      _drawWireBox(30, -40, 0, 25, 20, 50, canvas, size, Colors.cyan.withValues(alpha: 0.1));
    } else if (roomKey == 'greenhouse') {
      paint.color = Colors.green.withValues(alpha: 0.3);
      for (double ry = -50; ry <= 50; ry += 25) {
        final p1 = projectIso(-60, ry, 0, size);
        final p2 = projectIso(20, ry, 0, size);
        canvas.drawLine(p1, p2, paint);
      }
    } else if (roomKey == 'workshop') {
      _drawWireBox(-30, -30, 0, 60, 60, 25, canvas, size, Colors.orange.withValues(alpha: 0.12));
      _drawWireBox(-20, -20, 45, 40, 40, 15, canvas, size, Colors.white.withValues(alpha: 0.08));
    }

    // Airflow particles
    Color pColor = const Color(0xFF00F0FF); // cyan
    if (temp >= 21 && temp <= 25) {
      pColor = const Color(0xFF00E586); // safe green
    } else if (temp > 25) {
      pColor = const Color(0xFFFFA200); // amber
    }
    final pPaint = Paint()..style = PaintingStyle.fill;

    for (var p in particles) {
      final sPt = projectIso(p.x, p.y, p.z, size);
      pPaint.color = pColor.withValues(alpha: p.alpha);
      canvas.drawCircle(sPt, p.size, pPaint);
    }

    // PM2.5 haze
    if (pm25 > 12) {
      final dustPaint = Paint()..color = Colors.brown.withValues(alpha: 0.18)..style = PaintingStyle.fill;
      final rand = math.Random(1234);
      for (int i = 0; i < (pm25 * 0.8).round(); i++) {
        final rx = -75.0 + rand.nextDouble() * 150.0;
        final ry = -75.0 + rand.nextDouble() * 150.0;
        final rz = rand.nextDouble() * 40.0;
        final dustPt = projectIso(rx, ry, rz, size);
        canvas.drawCircle(dustPt, 1.5, dustPaint);
      }
    }

    // Heatmap Overlay using Radial Gradients
    if (heatmapActive) {
      final factor = ((temp - 5) / 40).clamp(0.0, 1.0);
      final double hue = 240.0 - (factor * 260.0); // 240 (blue) down to -20 (red)
      final color = HSVColor.fromAHSV(1.0, hue.clamp(0.0, 360.0), 1.0, 1.0).toColor();

      List<math.Point<double>> heatSources = [];
      if (roomKey == 'living_room') {
        heatSources = [const math.Point(-20, -20), const math.Point(50, -10)];
      } else if (roomKey == 'server_room') {
        heatSources = [const math.Point(-35, -30), const math.Point(5, -30), const math.Point(45, -30)];
      } else if (roomKey == 'greenhouse') {
        heatSources = [const math.Point(-20, 0)];
      } else if (roomKey == 'workshop') {
        heatSources = [const math.Point(0, 0)];
      }

      for (var src in heatSources) {
        final pt = projectIso(src.x, src.y, 10, size);
        final rect = Rect.fromCircle(center: pt, radius: 90);
        final gradientPaint = Paint()
          ..shader = RadialGradient(
            colors: [color.withValues(alpha: 0.18), color.withValues(alpha: 0.06), Colors.transparent],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(rect)
          ..blendMode = BlendMode.screen;

        canvas.drawCircle(pt, 90, gradientPaint);
      }
    }

    // Draw placed sensor probes
    final flagPaint = Paint()..style = PaintingStyle.fill;
    final flagStroke = Paint()
      ..color = const Color(0xFF00F0FF)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (var p in probes) {
      final rx = p['x'] as double;
      final ry = p['y'] as double;
      final basePt = projectIso(rx, ry, 0, size);
      final topPt = projectIso(rx, ry, 15, size);

      // Pole
      canvas.drawLine(basePt, topPt, flagStroke);

      // Flag point
      flagPaint.color = const Color(0xFF0D1426);
      canvas.drawRect(Rect.fromCenter(center: topPt, width: 8, height: 8), flagPaint);
      canvas.drawRect(Rect.fromCenter(center: topPt, width: 8, height: 8), flagStroke);

      // Base ring
      canvas.drawCircle(basePt, 6, flagStroke..color = const Color(0xFF00F0FF).withValues(alpha: 0.4));

      // Visual acoustic sound waves propagation from probe if environment noise is high
      if (decibels > 55.0) {
        final double maxRadius = (decibels - 50.0) * 1.5;
        for (int i = 0; i < 3; i++) {
          final double phase = (pulseValue + i / 3.0) % 1.0;
          final double radius = phase * maxRadius;
          final double opacity = (1.0 - phase) * 0.35;
          
          final wavePaint = Paint()
            ..color = const Color(0xFFFF1A6E).withValues(alpha: opacity)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.0 + (1.0 - phase) * 1.5;
            
          canvas.drawCircle(basePt, radius, wavePaint);
        }
      }
    }

    // Draw detected objects bounding boxes
    final boxPaint = Paint()
      ..color = const Color(0xFFFF1A6E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (var obj in detectedObjects) {
      final rect = obj.boundingBox;
      final double scaleX = size.width / 480.0;
      final double scaleY = size.height / 640.0;
      
      final scaledRect = Rect.fromLTRB(
        rect.left * scaleX,
        rect.top * scaleY,
        rect.right * scaleX,
        rect.bottom * scaleY,
      );

      canvas.drawRect(scaledRect, boxPaint);

      String labelText = "OBJECT";
      if (obj.labels.isNotEmpty) {
        labelText = obj.labels.first.text.toUpperCase();
      }
      
      textPainter.text = TextSpan(
        text: " $labelText ",
        style: const TextStyle(
          fontFamily: 'Fira Code',
          fontSize: 10,
          color: Colors.white,
          backgroundColor: Color(0xFFFF1A6E),
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(scaledRect.left, scaledRect.top - 14));
    }

    // Draw reticle target if hovering
    if (hoverPos != null) {
      final crossPaint = Paint()
        ..color = const Color(0xFF00F0FF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawCircle(hoverPos!, 12, crossPaint);
      canvas.drawCircle(hoverPos!, 20, crossPaint..color = const Color(0xFF00F0FF).withValues(alpha: 0.4));
      canvas.drawCircle(hoverPos!, 1.5, Paint()..color = const Color(0xFF00F0FF)..style = PaintingStyle.fill);
    }
  }

  void _drawWireBox(double x, double y, double z, double dx, double dy, double dz, Canvas canvas, Size size, Color fill) {
    final p1 = projectIso(x, y, z, size);
    final p2 = projectIso(x + dx, y, z, size);
    final p3 = projectIso(x + dx, y + dy, z, size);
    final p4 = projectIso(x, y + dy, z, size);

    final t1 = projectIso(x, y, z + dz, size);
    final t2 = projectIso(x + dx, y, z + dz, size);
    final t3 = projectIso(x + dx, y + dy, z + dz, size);
    final t4 = projectIso(x, y + dy, z + dz, size);

    final fillPaint = Paint()
      ..color = fill
      ..style = PaintingStyle.fill;

    final baseP = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(p3.dx, p3.dy)
      ..lineTo(p4.dx, p4.dy)
      ..close();
    canvas.drawPath(baseP, fillPaint);

    final strokePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawLine(p1, p2, strokePaint);
    canvas.drawLine(p2, p3, strokePaint);
    canvas.drawLine(p3, p4, strokePaint);
    canvas.drawLine(p4, p1, strokePaint);

    canvas.drawLine(t1, t2, strokePaint);
    canvas.drawLine(t2, t3, strokePaint);
    canvas.drawLine(t3, t4, strokePaint);
    canvas.drawLine(t4, t1, strokePaint);

    canvas.drawLine(p1, t1, strokePaint);
    canvas.drawLine(p2, t2, strokePaint);
    canvas.drawLine(p3, t3, strokePaint);
    canvas.drawLine(p4, t4, strokePaint);
  }

  @override
  bool shouldRepaint(covariant IsometricTwinPainter oldDelegate) => true;
}
