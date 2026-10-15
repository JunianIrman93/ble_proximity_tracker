import '../entities/bluetooth_status.dart';
import '../repositories/bluetooth_repository.dart';

class WatchBluetoothStatus {
  const WatchBluetoothStatus(this._repository);

  final BluetoothRepository _repository;

  Stream<BluetoothStatus> call() => _repository.watchStatus();
}

class GetBluetoothStatus {
  const GetBluetoothStatus(this._repository);

  final BluetoothRepository _repository;

  Future<BluetoothStatus> call() => _repository.currentStatus();
}

class CheckScanPermission {
  const CheckScanPermission(this._repository);

  final BluetoothRepository _repository;

  Future<ScanPermission> call() => _repository.checkPermissions();
}

class EnableBluetooth {
  const EnableBluetooth(this._repository);

  final BluetoothRepository _repository;

  Future<bool> call() => _repository.enableBluetooth();
}

class OpenAppSettings {
  const OpenAppSettings(this._repository);

  final BluetoothRepository _repository;

  Future<void> call() => _repository.openAppSettings();
}
