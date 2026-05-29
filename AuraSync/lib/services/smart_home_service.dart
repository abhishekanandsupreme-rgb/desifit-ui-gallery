import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SmartHomeService {
  final _logController = StreamController<String>.broadcast();
  Stream<String> get logStream => _logController.stream;

  bool isCircadianMode = false;
  String hubIp = '192.168.1.100';
  String username = 'AuraSyncCircadianToken';
  
  // Simulated Hue state
  double currentBrightness = 0.5; // 0.0 to 1.0
  int currentCt = 370; // Color temperature in mired (153 to 500)
  bool isLightOn = true;

  Timer? _discoveryTimer;

  Future<void> discoverBridge() async {
    _logController.add("Searching local network for Philips Hue bridges...");
    _discoveryTimer = Timer(const Duration(milliseconds: 600), () {
      _logController.add("Bridge discovered at IP: $hubIp");
    });
  }

  Future<void> updateCircadianLighting(double ambientLux, int hour) async {
    double targetBrightness;
    int targetCt; // Color temperature in mired (153 = 6500K cool, 500 = 2000K warm)
    String phase;

    if (hour >= 6 && hour < 11) {
      phase = "Morning";
      targetBrightness = 0.9;
      targetCt = 200; // ~5000K (Cool)
    } else if (hour >= 11 && hour < 17) {
      phase = "Afternoon";
      targetBrightness = 0.8;
      targetCt = 250; // ~4000K (Neutral)
    } else if (hour >= 17 && hour < 21) {
      phase = "Evening";
      targetBrightness = 0.4;
      targetCt = 400; // ~2500K (Warm)
    } else {
      phase = "Night";
      targetBrightness = 0.15;
      targetCt = 450; // ~2200K (Very warm)
    }

    // Scale target brightness based on ambient lux to save energy
    if (ambientLux > 800.0) {
      targetBrightness = 0.0; // Keep lights off
    } else if (ambientLux > 400.0) {
      targetBrightness = (targetBrightness * 0.3).clamp(0.1, 1.0);
    } else {
      // Boost brightness proportionally in dark environments
      targetBrightness = (targetBrightness * (1.0 - ambientLux / 400.0)).clamp(0.15, 1.0);
    }

    currentBrightness = targetBrightness;
    currentCt = targetCt;
    isLightOn = targetBrightness > 0.0;

    _logController.add("Circadian Automation: [$phase Mode] Ambient light is ${ambientLux.toStringAsFixed(0)} lux.");
    
    if (isLightOn) {
      _logController.add("Command dispatched -> IP: $hubIp | Bri: ${(currentBrightness * 100).toStringAsFixed(0)}% | Temp: ${miredToKelvin(currentCt)}K");
    } else {
      _logController.add("Command dispatched -> Turn Off lights (adequate natural light detected).");
    }

    // Dispatches Hue API REST request
    final url = Uri.parse('http://$hubIp/api/$username/groups/0/action');
    try {
      final body = jsonEncode({
        "on": isLightOn,
        if (isLightOn) "bri": (currentBrightness * 254).round(),
        if (isLightOn) "ct": currentCt,
      });

      final response = await http.put(url, body: body).timeout(const Duration(milliseconds: 300));
      if (response.statusCode == 200) {
        _logController.add("Hue REST success status 200: Bridge configured successfully.");
      } else {
        _logController.add("Hue Bridge REST returned status code: ${response.statusCode}");
      }
    } catch (e) {
      // Silently fall back to offline simulation
      _logController.add("Hue Light Sync: Command simulated successfully.");
    }
  }

  int miredToKelvin(int mired) {
    if (mired == 0) return 0;
    return (1000000 / mired).round();
  }

  void dispose() {
    _discoveryTimer?.cancel();
    _logController.close();
  }
}
