import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'device_history_dao.dart';

part 'app_database.g.dart';

@DataClassName('DeviceHistoryRow')
class DeviceHistory extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().nullable()();
  IntColumn get lastRssi => integer()();
  IntColumn get bestRssi => integer()();
  DateTimeColumn get firstSeen => dateTime()();
  DateTimeColumn get lastSeen => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [DeviceHistory], daos: [DeviceHistoryDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'ble_tracker'));

  @override
  int get schemaVersion => 1;
}
