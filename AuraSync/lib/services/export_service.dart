import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/scan_log.dart';

class ExportService {
  // Export list of logs to CSV format and share
  Future<bool> exportAndShareCSV(List<ScanLog> logs) async {
    try {
      final buffer = StringBuffer();
      
      // Write Header
      buffer.writeln("Timestamp,Room Name,Eco Score,Temperature (C),Humidity (%),CO2 (ppm),VOC (ppb),PM2.5 (ug/m3),Light (lux),Noise (dB),Warnings");
      
      // Write Rows
      for (var log in logs) {
        final timestampStr = log.timestamp.toIso8601String();
        final warningsStr = '"${log.warnings.join(' | ')}"';
        buffer.writeln(
          "$timestampStr,"
          "${log.roomName},"
          "${log.score.toStringAsFixed(1)},"
          "${log.temperature.toStringAsFixed(1)},"
          "${log.humidity.toStringAsFixed(1)},"
          "${log.co2.toStringAsFixed(1)},"
          "${log.voc.toStringAsFixed(1)},"
          "${log.pm25.toStringAsFixed(1)},"
          "${log.light.toStringAsFixed(1)},"
          "${log.decibel.toStringAsFixed(1)},"
          "$warningsStr"
        );
      }
      
      final tempDir = await getTemporaryDirectory();
      final file = File("${tempDir.path}/aurasync_telemetry_export.csv");
      await file.writeAsString(buffer.toString());
      
      final xFile = XFile(file.path, mimeType: "text/csv");
      await Share.shareXFiles([xFile], text: "AuraSync Environmental Digital Twin CSV Telemetry Export");
      
      return true;
    } catch (e) {
      return false;
    }
  }

  // Export list of logs to JSON format and share
  Future<bool> exportAndShareJSON(List<ScanLog> logs) async {
    try {
      final List<Map<String, dynamic>> dataList = logs.map((log) => {
        "timestamp": log.timestamp.toIso8601String(),
        "roomName": log.roomName,
        "score": log.score,
        "temperature": log.temperature,
        "humidity": log.humidity,
        "co2": log.co2,
        "voc": log.voc,
        "pm25": log.pm25,
        "light": log.light,
        "decibel": log.decibel,
        "warnings": log.warnings,
      }).toList();
      
      final jsonString = const JsonEncoder.withIndent("  ").convert(dataList);
      
      final tempDir = await getTemporaryDirectory();
      final file = File("${tempDir.path}/aurasync_telemetry_export.json");
      await file.writeAsString(jsonString);
      
      final xFile = XFile(file.path, mimeType: "application/json");
      await Share.shareXFiles([xFile], text: "AuraSync Environmental Digital Twin JSON Telemetry Export");
      
      return true;
    } catch (e) {
      return false;
    }
  }

  // Generate an Environmental Health Audit HTML Report and share
  Future<bool> exportAndShareHTMLReport(List<ScanLog> logs, double utilityRate) async {
    try {
      if (logs.isEmpty) return false;
      
      // Calculate averages
      double avgScore = 0.0;
      double avgTemp = 0.0;
      double avgCo2 = 0.0;
      double avgNoise = 0.0;
      int totalWarnings = 0;
      
      for (var log in logs) {
        avgScore += log.score;
        avgTemp += log.temperature;
        avgCo2 += log.co2;
        avgNoise += log.decibel;
        totalWarnings += log.warnings.length;
      }
      
      avgScore /= logs.length;
      avgTemp /= logs.length;
      avgCo2 /= logs.length;
      avgNoise /= logs.length;
      
      final buffer = StringBuffer();
      
      buffer.write("""
<!DOCTYPE html>
<html>
<head>
  <meta charset='utf-8'>
  <title>AuraSync Environmental Health Audit</title>
  <style>
    body {
      background-color: #060913;
      color: #E2E8F0;
      font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
      margin: 0;
      padding: 40px 20px;
    }
    .container {
      max-width: 900px;
      margin: 0 auto;
      background-color: #0D1426;
      border: 1px solid rgba(255, 255, 255, 0.08);
      border-radius: 12px;
      padding: 30px;
      box-shadow: 0 8px 32px rgba(0, 0, 0, 0.5);
    }
    .header {
      border-bottom: 2px solid rgba(0, 240, 255, 0.2);
      padding-bottom: 20px;
      margin-bottom: 30px;
      display: flex;
      justify-content: space-between;
      align-items: center;
    }
    .title {
      font-size: 24px;
      font-weight: bold;
      color: #00F0FF;
      letter-spacing: 1.5px;
    }
    .meta {
      font-size: 12px;
      color: #94A3B8;
      text-align: right;
    }
    .grid {
      display: grid;
      grid-template-columns: repeat(4, 1fr);
      gap: 20px;
      margin-bottom: 30px;
    }
    .card {
      background-color: #060913;
      border: 1px solid rgba(255, 255, 255, 0.04);
      border-radius: 8px;
      padding: 15px;
      text-align: center;
    }
    .card-label {
      font-size: 9px;
      color: #94A3B8;
      text-transform: uppercase;
      letter-spacing: 1px;
      margin-bottom: 8px;
    }
    .card-value {
      font-size: 20px;
      font-weight: bold;
      font-family: monospace;
    }
    .score-green { color: #00E586; }
    .score-orange { color: #FFA200; }
    .score-red { color: #FFFF1A6E; }
    
    table {
      width: 100%;
      border-collapse: collapse;
      margin-top: 20px;
      margin-bottom: 30px;
    }
    th, td {
      padding: 12px;
      text-align: left;
      border-bottom: 1px solid rgba(255, 255, 255, 0.04);
    }
    th {
      background-color: #060913;
      color: #00F0FF;
      font-size: 11px;
      text-transform: uppercase;
      letter-spacing: 1px;
    }
    td {
      font-size: 13px;
    }
    tr:hover {
      background-color: rgba(255, 255, 255, 0.02);
    }
    .warning-badge {
      display: inline-block;
      padding: 2px 6px;
      background-color: rgba(255, 26, 110, 0.1);
      border: 1px solid rgba(255, 26, 110, 0.3);
      color: #FFFF1A6E;
      border-radius: 4px;
      font-size: 10px;
      margin-right: 4px;
      margin-bottom: 4px;
    }
    .footer {
      text-align: center;
      font-size: 11px;
      color: #64748B;
      margin-top: 40px;
      border-top: 1px solid rgba(255, 255, 255, 0.04);
      padding-top: 20px;
    }
  </style>
</head>
<body>
  <div class='container'>
    <div class='header'>
      <div>
        <div class='title'>AURASYNC // TWIN AUDIT REPORT</div>
        <div style='font-size: 12px; color: #64748B; margin-top: 4px;'>Environmental Digital Twin & Sustainability Assessment</div>
      </div>
      <div class='meta'>
        <div>Generated: ${DateTime.now().toLocal().toString().substring(0, 19)}</div>
        <div>Total Audited Rooms: ${logs.map((l) => l.roomName).toSet().length}</div>
      </div>
    </div>
    
    <div class='grid'>
      <div class='card'>
        <div class='card-label'>Average Eco Score</div>
        <div class='card-value ${avgScore > 80.0 ? "score-green" : avgScore > 60.0 ? "score-orange" : "score-red"}'>${avgScore.toStringAsFixed(0)}%</div>
      </div>
      <div class='card'>
        <div class='card-label'>Avg Temperature</div>
        <div class='card-value' style='color: #00F0FF;'>${avgTemp.toStringAsFixed(1)} °C</div>
      </div>
      <div class='card'>
        <div class='card-label'>Avg CO2 Load</div>
        <div class='card-value'>${avgCo2.toStringAsFixed(0)} ppm</div>
      </div>
      <div class='card'>
        <div class='card-label'>Avg Noise Level</div>
        <div class='card-value' style='color: ${avgNoise > 55.0 ? "#FFA200" : "#00E586"};'>${avgNoise.toStringAsFixed(0)} dBA</div>
      </div>
    </div>

    <div style='margin-bottom: 30px;'>
      <h3 style='color: #00F0FF; font-size: 14px; border-left: 3px solid #00F0FF; padding-left: 8px; margin-bottom: 12px;'>SUMMARY REPORT & ANOMALIES</h3>
      <p style='font-size: 13px; line-height: 1.6; color: #94A3B8;'>
        AuraSync conducted a series of environmental twin audits across your smart residential spaces. During this sequence, a total of <strong>$totalWarnings</strong> anomalies or environmental excursions were identified. 
        The overall environmental health score is currently resting at <strong>${avgScore.toStringAsFixed(1)}%</strong>, indicating a 
        <strong>${avgScore > 85.0 ? "Healthy & Efficient" : avgScore > 65.0 ? "Moderate Risk" : "High Mitigation Priority"}</strong> status.
      </p>
    </div>

    <div>
      <h3 style='color: #00F0FF; font-size: 14px; border-left: 3px solid #00F0FF; padding-left: 8px; margin-bottom: 12px;'>ROOM SCANS HISTORY LOGS</h3>
      <table>
        <thead>
          <tr>
            <th>Timestamp</th>
            <th>Room</th>
            <th>Eco Score</th>
            <th>Temp / Humid</th>
            <th>CO2 / Noise</th>
            <th>Excursions & Warnings</th>
          </tr>
        </thead>
        <tbody>
""");
      
      for (var log in logs) {
        final timeStr = log.timestamp.toLocal().toString().substring(5, 19);
        final scoreColor = log.score > 80.0 ? 'score-green' : log.score > 60.0 ? 'score-orange' : 'score-red';
        final warningsHtml = log.warnings.isEmpty 
            ? "<span class='score-green' style='font-size: 11px;'>✓ NOMINAL STATE</span>" 
            : log.warnings.map((w) => "<span class='warning-badge'>${w.split(' is ').first}</span>").join();

        buffer.write("""
          <tr>
            <td style='font-family: monospace;'>$timeStr</td>
            <td style='font-weight: bold; color: #00F0FF;'>${log.roomName.toUpperCase()}</td>
            <td class='$scoreColor' style='font-weight: bold;'>${log.score.toStringAsFixed(0)}%</td>
            <td>${log.temperature.toStringAsFixed(1)}°C / ${log.humidity.toStringAsFixed(0)}%</td>
            <td>${log.co2.toStringAsFixed(0)}ppm / ${log.decibel.toStringAsFixed(0)}dB</td>
            <td>$warningsHtml</td>
          </tr>
""");
      }
      
      buffer.write("""
        </tbody>
      </table>
    </div>

    <div class='footer'>
      AuraSync Digital Twin System // Verified Local Security Core. All environment logs are processed strictly on-device.
    </div>
  </div>
</body>
</html>
""");

      final tempDir = await getTemporaryDirectory();
      final file = File("${tempDir.path}/aurasync_health_audit_report.html");
      await file.writeAsString(buffer.toString());
      
      final xFile = XFile(file.path, mimeType: "text/html");
      await Share.shareXFiles([xFile], text: "AuraSync Environmental Health Audit Report");
      
      return true;
    } catch (e) {
      return false;
    }
  }
}
