import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/scan_log.dart';

class HistoryChartsWidget extends StatefulWidget {
  final List<ScanLog> scanLogs;

  const HistoryChartsWidget({super.key, required this.scanLogs});

  @override
  State<HistoryChartsWidget> createState() => _HistoryChartsWidgetState();
}

class _HistoryChartsWidgetState extends State<HistoryChartsWidget> {
  int _activeTab = 0; // 0: Score, 1: Temp & Humidity, 2: CO2 & VOC, 3: PM2.5 & Light

  @override
  Widget build(BuildContext context) {
    if (widget.scanLogs.isEmpty) {
      return Container(
        height: 180,
        decoration: BoxDecoration(
          color: const Color(0xFF0D1426).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: const Center(
          child: Text(
            "No telemetry logs to plot.\nPerform a scan to seed charts.",
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Outfit', color: Colors.grey, fontSize: 12),
          ),
        ),
      );
    }

    // Take latest 7 items and reverse them to show chronologically (left to right)
    final displayLogs = widget.scanLogs.take(7).toList().reversed.toList();

    return Column(
      children: [
        // Tab buttons
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTabButton(0, "SCORE"),
              _buildTabButton(1, "TEMP/HUMID"),
              _buildTabButton(2, "CO2/VOC"),
              _buildTabButton(3, "AQI/LIGHT"),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Chart Area
        Container(
          height: 160,
          padding: const EdgeInsets.only(right: 18, left: 6, top: 10, bottom: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF070B16),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: LineChart(
            _getChartData(displayLogs),
          ),
        ),
      ],
    );
  }

  Widget _buildTabButton(int index, String label) {
    final active = _activeTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeTab = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF00F0FF).withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? const Color(0xFF00F0FF) : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: active ? const Color(0xFF00F0FF) : Colors.grey,
          ),
        ),
      ),
    );
  }

  LineChartData _getChartData(List<ScanLog> logs) {
    List<FlSpot> spots1 = [];
    List<FlSpot> spots2 = [];
    Color color1 = const Color(0xFF00F0FF);
    Color color2 = const Color(0xFF00E586);

    for (int i = 0; i < logs.length; i++) {
      final log = logs[i];
      final double idx = i.toDouble();
      if (_activeTab == 0) {
        spots1.add(FlSpot(idx, log.score));
      } else if (_activeTab == 1) {
        spots1.add(FlSpot(idx, log.temperature));
        spots2.add(FlSpot(idx, log.humidity));
        color1 = const Color(0xFFFFA200); // temp
        color2 = const Color(0xFF00E586); // humidity
      } else if (_activeTab == 2) {
        spots1.add(FlSpot(idx, log.co2));
        spots2.add(FlSpot(idx, log.voc));
        color1 = const Color(0xFFFF1A6E); // CO2
        color2 = const Color(0xFF00F0FF); // VOC
      } else if (_activeTab == 3) {
        spots1.add(FlSpot(idx, log.pm25));
        spots2.add(FlSpot(idx, log.light / 10.0)); // normalize light lux to range
        color1 = const Color(0xFFFFA200); // PM2.5
        color2 = const Color(0xFF00E586); // Light
      }
    }

    final List<LineChartBarData> barData = [];
    
    barData.add(LineChartBarData(
      spots: spots1,
      isCurved: true,
      color: color1,
      barWidth: 2,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: true),
      belowBarData: BarAreaData(
        show: true,
        color: color1.withValues(alpha: 0.08),
      ),
    ));

    if (spots2.isNotEmpty) {
      barData.add(LineChartBarData(
        spots: spots2,
        isCurved: true,
        color: color2,
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: true),
        belowBarData: BarAreaData(
          show: true,
          color: color2.withValues(alpha: 0.08),
        ),
      ));
    }

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: _activeTab == 2 ? 500 : 20,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.white.withValues(alpha: 0.03),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: Colors.white.withValues(alpha: 0.03),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 22,
            interval: 1,
            getTitlesWidget: (value, meta) {
              final int index = value.toInt();
              if (index >= 0 && index < logs.length) {
                final time = logs[index].timestamp;
                final timeStr = "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
                return Text(
                  timeStr,
                  style: const TextStyle(
                    fontFamily: 'Fira Code',
                    fontSize: 8,
                    color: Colors.grey,
                  ),
                );
              }
              return const Text('');
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: _activeTab == 2 ? 500 : (_activeTab == 0 ? 25 : 15),
            getTitlesWidget: (value, meta) {
              return Text(
                value.toInt().toString(),
                style: const TextStyle(
                  fontFamily: 'Fira Code',
                  fontSize: 8,
                  color: Colors.grey,
                ),
              );
            },
            reservedSize: 28,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      lineBarsData: barData,
    );
  }
}
