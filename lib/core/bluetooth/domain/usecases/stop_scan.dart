import 'package:ble_proximity_tracker/core/error/failures.dart';
import 'package:ble_proximity_tracker/core/error/result.dart';

import '../repositories/bluetooth_repository.dart';

class StopScan {
  const StopScan(this._repository);

  final BluetoothRepository _repository;

  Future<Result<void>> call() async {
    try {
      await _repository.stopScan();
      return const Ok(null);
    } catch (e) {
      return Err(UnexpectedFailure('Could not stop scanning: $e'));
    }
  }
}
