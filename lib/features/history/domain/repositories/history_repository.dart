import 'package:ble_proximity_tracker/core/bluetooth/domain/entities/scanned_device.dart';

import '../entities/history_entry.dart';

abstract interface class HistoryRepository {
  Future<void> recordSightings(List<ScannedDevice> sightings);

  Stream<List<HistoryEntry>> watchHistory();

  Future<void> clear();
}
