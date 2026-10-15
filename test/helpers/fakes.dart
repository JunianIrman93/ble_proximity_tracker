import 'dart:async';

import 'package:mocktail/mocktail.dart';

import 'package:ble_proximity_tracker/core/bluetooth/domain/entities/bluetooth_status.dart';
import 'package:ble_proximity_tracker/core/bluetooth/domain/entities/scanned_device.dart';
import 'package:ble_proximity_tracker/core/bluetooth/domain/repositories/bluetooth_repository.dart';
import 'package:ble_proximity_tracker/features/history/domain/repositories/history_repository.dart';
import 'package:ble_proximity_tracker/features/settings/domain/repositories/settings_repository.dart';

class FakeBluetoothRepository implements BluetoothRepository {
  final _status = StreamController<BluetoothStatus>.broadcast();
  final _ads = StreamController<ScannedDevice>.broadcast();

  BluetoothStatus status = BluetoothStatus.on;
  ScanPermission permission = ScanPermission.granted;
  int startCalls = 0;
  int stopCalls = 0;

  void emitStatus(BluetoothStatus next) {
    status = next;
    _status.add(next);
  }

  void emitAdvertisement(ScannedDevice device) => _ads.add(device);

  @override
  Stream<BluetoothStatus> watchStatus() => _status.stream;

  @override
  Future<BluetoothStatus> currentStatus() async => status;

  @override
  Future<ScanPermission> requestPermissions() async => permission;

  @override
  Future<ScanPermission> checkPermissions() async => permission;

  @override
  Stream<ScannedDevice> watchAdvertisements() => _ads.stream;

  @override
  Future<void> startScan() async => startCalls++;

  @override
  Future<void> stopScan() async => stopCalls++;

  @override
  Future<bool> enableBluetooth() async {
    emitStatus(BluetoothStatus.on);
    return true;
  }

  @override
  Future<void> openAppSettings() async {}
}

class MockHistoryRepository extends Mock implements HistoryRepository {}

class MockSettingsRepository extends Mock implements SettingsRepository {}

Future<void> pump([int times = 20]) async {
  for (var i = 0; i < times; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}
