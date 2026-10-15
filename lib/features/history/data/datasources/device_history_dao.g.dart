// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_history_dao.dart';

// ignore_for_file: type=lint
mixin _$DeviceHistoryDaoMixin on DatabaseAccessor<AppDatabase> {
  $DeviceHistoryTable get deviceHistory => attachedDatabase.deviceHistory;
  DeviceHistoryDaoManager get managers => DeviceHistoryDaoManager(this);
}

class DeviceHistoryDaoManager {
  final _$DeviceHistoryDaoMixin _db;
  DeviceHistoryDaoManager(this._db);
  $$DeviceHistoryTableTableManager get deviceHistory =>
      $$DeviceHistoryTableTableManager(_db.attachedDatabase, _db.deviceHistory);
}
