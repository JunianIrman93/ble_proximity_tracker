import 'package:ble_proximity_tracker/core/bluetooth/domain/entities/scanned_device.dart';

import '../../domain/entities/history_entry.dart';
import '../../domain/repositories/history_repository.dart';
import '../datasources/device_history_dao.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  const HistoryRepositoryImpl(this._dao);

  final DeviceHistoryDao _dao;

  @override
  Future<void> recordSightings(List<ScannedDevice> sightings) =>
      _dao.upsertSightings([
        for (final d in sightings)
          (
            id: d.id,
            name: d.hasName ? d.name!.trim() : null,
            rssi: d.rssi,
            seenAt: d.seenAt,
          ),
      ]);

  @override
  Stream<List<HistoryEntry>> watchHistory() => _dao.watchAll().map(
    (rows) => [
      for (final r in rows)
        HistoryEntry(
          id: r.id,
          name: r.name,
          lastRssi: r.lastRssi,
          bestRssi: r.bestRssi,
          firstSeen: r.firstSeen,
          lastSeen: r.lastSeen,
        ),
    ],
  );

  @override
  Future<void> clear() => _dao.clearAll();
}
