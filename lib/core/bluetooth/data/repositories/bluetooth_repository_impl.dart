import 'package:flutter/foundation.dart';
import 'package:universal_ble/universal_ble.dart' show AvailabilityState;

import 'package:ble_proximity_tracker/core/utils/clock.dart';

import '../../domain/entities/bluetooth_status.dart';
import '../../domain/entities/scanned_device.dart';
import '../../domain/repositories/bluetooth_repository.dart';
import '../datasources/ble_data_source.dart';

class BluetoothRepositoryImpl implements BluetoothRepository {
  BluetoothRepositoryImpl(this._source, this._clock);

  final BleDataSource _source;
  final Clock _clock;

  static const int _missingRssi = -127;

  @override
  Stream<BluetoothStatus> watchStatus() => _source.availability.map(_mapStatus);

  @override
  Future<BluetoothStatus> currentStatus() async =>
      _mapStatus(await _source.currentAvailability());

  @override
  Stream<ScannedDevice> watchAdvertisements() =>
      _source.advertisements.map(_mapAdvertisement);

  @override
  Future<ScanPermission> requestPermissions() async {
    try {
      await _source.requestPermissions();
      return ScanPermission.granted;
    } catch (e) {
      debugPrint('Bluetooth permission denied: $e');
      return await _source.isPermanentlyDenied()
          ? ScanPermission.permanentlyDenied
          : ScanPermission.denied;
    }
  }

  @override
  Future<ScanPermission> checkPermissions() async {
    try {
      if (await _source.hasPermissions()) return ScanPermission.granted;
      return await _source.isPermanentlyDenied()
          ? ScanPermission.permanentlyDenied
          : ScanPermission.denied;
    } catch (e) {
      debugPrint('Could not check Bluetooth permission: $e');
      return ScanPermission.denied;
    }
  }

  @override
  Future<void> startScan() => _source.startScan();

  @override
  Future<void> stopScan() => _source.stopScan();

  @override
  Future<bool> enableBluetooth() => _source.enableBluetooth();

  @override
  Future<void> openAppSettings() => _source.openAppSettings();

  ScannedDevice _mapAdvertisement(RawAdvertisement raw) {
    final rssi = raw.rssi;
    return ScannedDevice(
      id: raw.id,
      name: raw.name,
      rssi: (rssi == null || rssi >= 0) ? _missingRssi : rssi,
      seenAt: _clock(),
    );
  }

  static BluetoothStatus _mapStatus(AvailabilityState state) => switch (state) {
    AvailabilityState.poweredOn => BluetoothStatus.on,
    AvailabilityState.poweredOff => BluetoothStatus.off,
    AvailabilityState.unauthorized => BluetoothStatus.unauthorized,
    AvailabilityState.unsupported => BluetoothStatus.unsupported,
    _ => BluetoothStatus.unknown,
  };
}
