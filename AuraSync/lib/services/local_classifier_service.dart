class LocalClassifierService {
  // Decision-tree classifier that returns a list of recommendation cards
  List<Map<String, dynamic>> classify({
    required double temp,
    required double humidity,
    required double co2,
    required double voc,
    required double pm25,
    required double light,
    required double decibel,
    required List<String> detectedLabels,
  }) {
    final List<Map<String, dynamic>> cards = [];

    // Evaluate sensor warnings & severity states
    String tempState = _getTempState(temp);
    String humidityState = _getHumidityState(humidity);
    String co2State = _getCo2State(co2);
    String vocState = _getVocState(voc);
    String pm25State = _getPm25State(pm25);
    String lightState = _getLightState(light);
    String decibelState = _getDecibelState(decibel);

    // Identify the highest priority anomaly to highlight first
    final states = {
      'co2': co2State,
      'pm25': pm25State,
      'voc': vocState,
      'temp': tempState,
      'humidity': humidityState,
      'decibel': decibelState,
      'light': lightState,
    };

    String worstMetric = 'none';
    String worstState = 'safe';

    // Priority ordering of metrics for classification focus
    final checkOrder = ['co2', 'pm25', 'voc', 'decibel', 'temp', 'humidity', 'light'];
    for (var metric in checkOrder) {
      final st = states[metric]!;
      if (st == 'critical') {
        worstState = 'critical';
        worstMetric = metric;
        break;
      } else if (st == 'warning' && worstState != 'critical') {
        worstState = 'warning';
        worstMetric = metric;
      }
    }

    // 1. Build Primary Anomaly/Optimization Card
    if (worstState == 'critical' || worstState == 'warning') {
      if (worstMetric == 'co2') {
        cards.add({
          "type": worstState,
          "tag": "CARBON DIOXIDE ALARM",
          "time": "JUST NOW",
          "title": "Carbon Dioxide Threshold Exceeded",
          "text": "CO2 levels rose to ${co2.toStringAsFixed(0)} ppm. Brain performance and cognitive function is compromised. Activating dampers to swap stale room air.",
          "energyWaste": 45.0
        });
        cards.add({
          "type": "product",
          "tag": "VENTILATION SHIELD",
          "title": "AuraBreeze Smart HRV Vent",
          "text": "Intelligent heat recovery ventilator. Swaps stale indoor air with fresh filtered outdoor air automatically.",
          "price": "\$159.99",
          "originalPrice": "\$189.00",
          "rating": 4.7,
          "ratingCount": 62,
          "coupon": "AURASYNCHRV"
        });
      } else if (worstMetric == 'pm25') {
        cards.add({
          "type": worstState,
          "tag": "PARTICULATE DUST WARNING",
          "time": "JUST NOW",
          "title": "High Dust / Aerosol Load",
          "text": "Particulates are elevated at ${pm25.toStringAsFixed(0)} µg/m³. Boost main HVAC recirculate cycle to HEPA filtration mode immediately to safeguard lungs.",
          "energyWaste": 120.0
        });
        cards.add({
          "type": "product",
          "tag": "HEPA AIR FILTER",
          "title": "AuraShield HEPA-9 Air Purifier",
          "text": "Medical-grade H13 HEPA carbon block filter. Rapidly eradicates aerosol particulate matter and odors.",
          "price": "\$299.00",
          "originalPrice": "\$349.00",
          "rating": 4.9,
          "ratingCount": 312,
          "coupon": "HEPA9SHIELD"
        });
      } else if (worstMetric == 'voc') {
        cards.add({
          "type": worstState,
          "tag": "CHEMICAL VOC SATURATION",
          "time": "JUST NOW",
          "title": "Volatile Gaseous Load Hazard",
          "text": "Volatile chemical matrix saturated at ${voc.toStringAsFixed(0)} ppb. Air purifiers HEPA filters must run at 100% capacity to scrub organic contaminants.",
          "energyWaste": 120.0
        });
        cards.add({
          "type": "product",
          "tag": "HEPA AIR FILTER",
          "title": "AuraShield HEPA-9 Air Purifier",
          "text": "Medical-grade H13 HEPA carbon block filter. Rapidly eradicates aerosol particulate matter and odors.",
          "price": "\$299.00",
          "originalPrice": "\$349.00",
          "rating": 4.9,
          "ratingCount": 312,
          "coupon": "HEPA9SHIELD"
        });
      } else if (worstMetric == 'decibel') {
        cards.add({
          "type": worstState,
          "tag": "ACOUSTIC NOISE POLLUTION",
          "time": "JUST NOW",
          "title": "High Ambient Noise Detected",
          "text": "Sound level reached ${decibel.toStringAsFixed(0)} dBA, exceeding comfortable auditory limits. Check for vibrating appliances or shut windows to minimize stress.",
          "energyWaste": 10.0
        });
        cards.add({
          "type": "product",
          "tag": "ACOUSTIC DAMPENING",
          "title": "AuraQuiet Soundproof Panels",
          "text": "High-density acoustic absorption foam panels. Seamless wall placement prevents ambient noise ingress.",
          "price": "\$49.99",
          "originalPrice": "\$59.99",
          "rating": 4.5,
          "ratingCount": 118,
          "coupon": "QUIETAURA"
        });
      } else if (worstMetric == 'temp') {
        final high = temp > 26.0;
        cards.add({
          "type": worstState,
          "tag": "THERMAL COMFORT EXCURSION",
          "time": "JUST NOW",
          "title": high ? "Extreme Ambient Heat Load" : "Low Room Temperature Detected",
          "text": high
              ? "Thermal payload is critical at ${temp.toStringAsFixed(1)}°C. Trigger secondary cooling compressors and bypass solar gain loops."
              : "Ambient temperature fell to ${temp.toStringAsFixed(1)}°C. Engage auxiliary electrical heater cores and throttle ventilation dampers.",
          "energyWaste": 350.0
        });
        cards.add({
          "type": "product",
          "tag": "HVAC OPTIMIZER",
          "title": "ThermoFlow Smart Zone AC Unit",
          "text": "Multi-zone cooling with whisper quiet variable compressor. Syncs automatically with digital twin telemetry.",
          "price": "\$429.00",
          "originalPrice": "\$499.00",
          "rating": 4.8,
          "ratingCount": 184,
          "coupon": "FLOWTEMP"
        });
      } else if (worstMetric == 'humidity') {
        final dry = humidity < 30.0;
        cards.add({
          "type": worstState,
          "tag": "HYGROMETER ANOMALY LAYER",
          "time": "JUST NOW",
          "title": dry ? "Dry Ambient Air Risk" : "Moisture Saturation Warning",
          "text": dry
              ? "Hygrometer reports dry humidity levels at ${humidity.toStringAsFixed(0)}%. Static build-up risk. Trigger ultrasonic humidifier vaporizer loops."
              : "Ambient moisture level is saturated at ${humidity.toStringAsFixed(0)}%. Vapor condensation hazard. Engage heavy duty condenser dryers.",
          "energyWaste": 80.0
        });
        cards.add({
          "type": "product",
          "tag": "AIR MOISTURE UNIT",
          "title": "HumidiSync Smart Humidifier",
          "text": "Ultrasonic cool mist generator. Prevents static discharges and keeps optimal room microclimate balance.",
          "price": "\$99.99",
          "originalPrice": "\$119.00",
          "rating": 4.6,
          "ratingCount": 95,
          "coupon": "HUMIDISYNC20"
        });
      } else {
        // Light
        final dark = light < 150.0;
        cards.add({
          "type": worstState,
          "tag": "LUMINOUS ENERGY DEVIATION",
          "time": "JUST NOW",
          "title": dark ? "Luminous Deficiency Detected" : "Extreme Visual Glare Warn",
          "text": dark
              ? "Photosensor reports only ${light.toStringAsFixed(0)} lux. Switch on task lighting channels to ensure optical productivity."
              : "Over-illumination detected at ${light.toStringAsFixed(0)} lux. Lower blinds and scale back adaptive LED panels to prevent glare.",
          "energyWaste": 60.0
        });
        cards.add({
          "type": "product",
          "tag": "SMART ILLUMINATOR",
          "title": "AuraGlow Smart LED Ceiling Panel",
          "text": "Full daylight spectrum smart lights with circadian sync controls and automatic ambient adjustment.",
          "price": "\$149.00",
          "originalPrice": "\$179.00",
          "rating": 4.7,
          "ratingCount": 140,
          "coupon": "GLOWLIGHT"
        });
      }
    } else {
      // Nominal / Optimal State
      cards.add({
        "type": "safe",
        "tag": "OPTIMIZED RUNTIME",
        "time": "JUST NOW",
        "title": "All systems operating efficiently",
        "text": "All environmental metrics are inside safe zones. Twin controller running in eco power-savings mode. Energy overhead lowered by 14.5%."
      });
      cards.add({
        "type": "cyan",
        "tag": "MAINTENANCE SCHEDULE",
        "time": "JUST NOW",
        "title": "Filter Maintenance Reminder",
        "text": "HEPA filter operates at 85% clean index. Screen cleaning/replacement recommended in 12 days to maintain ventilation velocity."
      });
    }

    // 2. Computer Vision Object Context Recommendations
    for (var label in detectedLabels) {
      final normalizedLabel = label.toLowerCase();
      if (normalizedLabel.contains('goods') ||
          normalizedLabel.contains('furniture') ||
          normalizedLabel.contains('appliance') ||
          normalizedLabel.contains('electronic')) {
        
        cards.insert(0, {
          "type": "cyan",
          "tag": "CV DIGITAL MATRIX",
          "time": "JUST NOW",
          "title": "Appliance Standby Power Detection",
          "text": "Detected [$normalizedLabel] anchor cell in camera view bounds. Standby energy leakage audit active. Smart Plug auto-mitigation suggested.",
          "energyWaste": 15.0
        });

        bool hasProduct = cards.any((c) => c['type'] == 'product');
        if (!hasProduct) {
          cards.add({
            "type": "product",
            "tag": "SMART HARDWARE",
            "title": "AuraPlug Energy Auditor",
            "text": "Smart power outlet plug with live Wi-Fi telemetry and automatic scheduled shut-off timers to prevent standby waste.",
            "price": "\$24.99",
            "originalPrice": "\$29.99",
            "rating": 4.8,
            "ratingCount": 420,
            "coupon": "AURAPLUG10"
          });
        }
        break; // Only inject one CV node recommendation
      }
    }

    // Guarantee we have at least 2 cards
    if (cards.length < 2) {
      cards.add({
        "type": "safe",
        "tag": "ECO SYSTEMS CONTROL",
        "time": "1M AGO",
        "title": "Energy Saving Loops Engaged",
        "text": "Variable fan controls dynamically throttling between 40% and 65% capacity depending on room load factors."
      });
    }

    return cards;
  }

  String _getTempState(double value) {
    if (value < 10.0 || value > 32.0) return 'critical';
    if (value < 16.0 || value > 26.0) return 'warning';
    return 'safe';
  }

  String _getHumidityState(double value) {
    if (value < 20.0 || value > 80.0) return 'critical';
    if (value < 30.0 || value > 70.0) return 'warning';
    return 'safe';
  }

  String _getCo2State(double value) {
    if (value > 1500.0) return 'critical';
    if (value > 800.0) return 'warning';
    return 'safe';
  }

  String _getVocState(double value) {
    if (value > 1000.0) return 'critical';
    if (value > 300.0) return 'warning';
    return 'safe';
  }

  String _getPm25State(double value) {
    if (value > 35.0) return 'critical';
    if (value > 12.0) return 'warning';
    return 'safe';
  }

  String _getLightState(double value) {
    if (value < 50.0 || value > 2000.0) return 'critical';
    if (value < 150.0 || value > 1500.0) return 'warning';
    return 'safe';
  }

  String _getDecibelState(double value) {
    if (value > 70.0) return 'critical';
    if (value > 55.0) return 'warning';
    return 'safe';
  }
}
