import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/scan_log.dart';

class DatabaseService {
  static Isar? _isar;

  // Initialize Isar Database
  Future<void> init() async {
    if (_isar != null) return;

    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [ScanLogSchema],
      directory: dir.path,
    );
  }

  // Save a new environmental scan log
  Future<void> saveScanLog(ScanLog log) async {
    final isar = _isar;
    if (isar == null) return;

    await isar.writeTxn(() async {
      await isar.scanLogs.put(log);
    });
  }

  // Retrieve all logs, sorted by latest first
  Future<List<ScanLog>> getAllScanLogs() async {
    final isar = _isar;
    if (isar == null) return [];

    return await isar.scanLogs.where().sortByTimestampDesc().findAll();
  }

  // Clear all scan logs from history
  Future<void> clearAllLogs() async {
    final isar = _isar;
    if (isar == null) return;

    await isar.writeTxn(() async {
      await isar.scanLogs.clear();
    });
  }
}
