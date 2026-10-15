import 'package:drift/drift.dart';

import 'app_database.dart';

part 'device_history_dao.g.dart';

typedef DeviceSighting = ({String id, String? name, int rssi, DateTime seenAt});

@DriftAccessor(tables: [DeviceHistory])
class DeviceHistoryDao extends DatabaseAccessor<AppDatabase>
    with _$DeviceHistoryDaoMixin {
  DeviceHistoryDao(super.attachedDatabase);

  static const _upsertSql = '''
INSERT INTO device_history (id, name, last_rssi, best_rssi, first_seen, last_seen)
VALUES (?, ?, ?, ?, ?, ?)
ON CONFLICT(id) DO UPDATE SET
  name = COALESCE(excluded.name, device_history.name),
  last_rssi = excluded.last_rssi,
  best_rssi = MAX(device_history.best_rssi, excluded.best_rssi),
  last_seen = excluded.last_seen
''';

  Future<void> upsertSightings(List<DeviceSighting> sightings) async {
    if (sightings.isEmpty) return;
    await transaction(() async {
      for (final s in sightings) {
        await customInsert(
          _upsertSql,
          variables: [
            Variable.withString(s.id),
            Variable<String>(s.name),
            Variable.withInt(s.rssi),
            Variable.withInt(s.rssi),
            Variable.withDateTime(s.seenAt),
            Variable.withDateTime(s.seenAt),
          ],
          updates: {deviceHistory},
        );
      }
    });
  }

  Stream<List<DeviceHistoryRow>> watchAll() => (select(
    deviceHistory,
  )..orderBy([(t) => OrderingTerm.desc(t.lastSeen)])).watch();

  Future<int> clearAll() => delete(deviceHistory).go();
}
