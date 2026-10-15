import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:universal_ble/universal_ble.dart' as ub;

typedef RawAdvertisement = ({String id, String? name, int? rssi});

class BleDataSource {
  Stream<ub.AvailabilityState> get availability =>
      ub.UniversalBle.availabilityStream;

  Future<ub.AvailabilityState> currentAvailability() =>
      ub.UniversalBle.getBluetoothAvailabilityState();

  Stream<RawAdvertisement> get advertisements => ub.UniversalBle.scanStream.map(
    (d) => (id: d.deviceId, name: d.name, rssi: d.rssi),
  );

  Future<void> requestPermissions() =>
      ub.UniversalBle.requestPermissions(withAndroidFineLocation: false);

  Future<bool> hasPermissions() =>
      ub.UniversalBle.hasPermissions(withAndroidFineLocation: false);

  Future<bool> isPermanentlyDenied() async {
    if (!Platform.isAndroid) return true;
    final scan = ph.Permission.bluetoothScan;
    final blocking = await scan.status.isGranted
        ? ph.Permission.locationWhenInUse
        : scan;
    return !await blocking.shouldShowRequestRationale;
  }

  Future<void> startScan() => ub.UniversalBle.startScan(
    platformConfig: ub.PlatformConfig(
      android: ub.AndroidOptions(
        scanMode: ub.AndroidScanMode.lowLatency,
        requestLocationPermission: false,
      ),
    ),
  );

  Future<void> stopScan() => ub.UniversalBle.stopScan();

  Future<bool> enableBluetooth() async {
    try {
      await ub.UniversalBle.enableBluetooth();
      return true;
    } catch (e) {
      debugPrint('enableBluetooth failed: $e');
      return false;
    }
  }

  Future<void> openAppSettings() => ph.openAppSettings();
}
