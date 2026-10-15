import '../entities/bluetooth_status.dart';
import '../entities/scanned_device.dart';

abstract interface class BluetoothRepository {
  Stream<BluetoothStatus> watchStatus();

  Future<BluetoothStatus> currentStatus();

  Future<ScanPermission> requestPermissions();

  Future<ScanPermission> checkPermissions();

  Stream<ScannedDevice> watchAdvertisements();

  Future<void> startScan();

  Future<void> stopScan();

  Future<bool> enableBluetooth();

  Future<void> openAppSettings();
}
