import '../entities/scanned_device.dart';
import '../repositories/bluetooth_repository.dart';

class WatchAdvertisements {
  const WatchAdvertisements(this._repository);

  final BluetoothRepository _repository;

  Stream<ScannedDevice> call({String? deviceId}) {
    final stream = _repository.watchAdvertisements();
    return deviceId == null
        ? stream
        : stream.where((device) => device.id == deviceId);
  }
}
