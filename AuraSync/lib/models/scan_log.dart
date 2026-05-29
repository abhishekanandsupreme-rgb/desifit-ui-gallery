import 'package:isar/isar.dart';

part 'scan_log.g.dart';

@collection
class ScanLog {
  Id id = Isar.autoIncrement;

  late DateTime timestamp;
  late String roomName;

  late double temperature;
  late double humidity;
  late double co2;
  late double voc;
  late double pm25;
  late double light;
  late double score;
  late double decibel;

  late List<String> warnings;
}
