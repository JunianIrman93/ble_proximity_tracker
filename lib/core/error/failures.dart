import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  const Failure();

  String get message;

  @override
  List<Object?> get props => [];
}

final class PermissionFailure extends Failure {
  const PermissionFailure({required this.permanentlyDenied});

  final bool permanentlyDenied;

  @override
  String get message => permanentlyDenied
      ? 'Bluetooth permission is blocked. Allow it in app settings.'
      : 'Bluetooth permission is required to find nearby devices.';

  @override
  List<Object?> get props => [permanentlyDenied];
}

final class BluetoothOffFailure extends Failure {
  const BluetoothOffFailure();

  @override
  String get message => 'Bluetooth is turned off.';
}

final class BluetoothUnsupportedFailure extends Failure {
  const BluetoothUnsupportedFailure();

  @override
  String get message => 'This device does not support Bluetooth Low Energy.';
}

final class ScanThrottledFailure extends Failure {
  const ScanThrottledFailure(this.retryAfter);

  final Duration retryAfter;

  @override
  String get message =>
      'Android allows 5 scan starts per 30 seconds. '
      'Try again in ${retryAfter.inSeconds + 1}s.';

  @override
  List<Object?> get props => [retryAfter];
}

final class UnexpectedFailure extends Failure {
  const UnexpectedFailure(this.details);

  final String details;

  @override
  String get message => details;

  @override
  List<Object?> get props => [details];
}
