import 'package:ble_proximity_tracker/core/error/failures.dart';
import 'package:ble_proximity_tracker/core/error/result.dart';
import 'package:ble_proximity_tracker/core/signal/scan_throttle_guard.dart';
import 'package:ble_proximity_tracker/core/utils/clock.dart';

import '../entities/bluetooth_status.dart';
import '../repositories/bluetooth_repository.dart';

class StartScan {
  StartScan(this._repository, this._clock, [ScanThrottleGuard? guard])
    : _guard = guard ?? ScanThrottleGuard();

  final BluetoothRepository _repository;
  final Clock _clock;
  final ScanThrottleGuard _guard;

  Future<Result<void>> call() async {
    final wait = _guard.waitBeforeNextStart(_clock());
    if (wait != null) return Err(ScanThrottledFailure(wait));

    final permission = await _repository.requestPermissions();
    switch (permission) {
      case ScanPermission.denied:
        return const Err(PermissionFailure(permanentlyDenied: false));
      case ScanPermission.permanentlyDenied:
        return const Err(PermissionFailure(permanentlyDenied: true));
      case ScanPermission.granted:
        break;
    }

    final status = await _repository.currentStatus();
    switch (status) {
      case BluetoothStatus.unsupported:
        return const Err(BluetoothUnsupportedFailure());
      case BluetoothStatus.unauthorized:
        return const Err(PermissionFailure(permanentlyDenied: false));
      case BluetoothStatus.off:
      case BluetoothStatus.unknown:
        return const Err(BluetoothOffFailure());
      case BluetoothStatus.on:
        break;
    }

    try {
      _guard.recordStart(_clock());
      await _repository.startScan();
      return const Ok(null);
    } catch (e) {
      return Err(UnexpectedFailure('Could not start scanning: $e'));
    }
  }
}
