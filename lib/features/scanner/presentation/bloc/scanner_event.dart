part of 'scanner_bloc.dart';

sealed class ScannerEvent {
  const ScannerEvent();
}

final class ScannerStarted extends ScannerEvent {
  const ScannerStarted();
}

sealed class ScanControlEvent extends ScannerEvent {
  const ScanControlEvent();
}

final class ScanStartRequested extends ScanControlEvent {
  const ScanStartRequested();
}

final class ScanStopRequested extends ScanControlEvent {
  const ScanStopRequested([this.reason = StopReason.user]);

  final StopReason reason;
}

final class ScanToggled extends ScanControlEvent {
  const ScanToggled();
}

enum StopReason { user, background, bluetoothOff, error }

final class AppLifecycleChanged extends ScannerEvent {
  const AppLifecycleChanged(this.state);

  final AppLifecycleState state;
}

final class BluetoothEnableRequested extends ScannerEvent {
  const BluetoothEnableRequested();
}

final class AppSettingsRequested extends ScannerEvent {
  const AppSettingsRequested();
}

final class SearchQueryChanged extends ScannerEvent {
  const SearchQueryChanged(this.query);

  final String query;
}

final class MinRssiChanged extends ScannerEvent {
  const MinRssiChanged(this.minRssi);

  final int? minRssi;
}

final class NamedOnlyChanged extends ScannerEvent {
  const NamedOnlyChanged(this.namedOnly);

  final bool namedOnly;
}

final class FiltersCleared extends ScannerEvent {
  const FiltersCleared();
}

final class _BluetoothStatusChanged extends ScannerEvent {
  const _BluetoothStatusChanged(this.status);

  final BluetoothStatus status;
}

final class _StatusRefreshRequested extends ScannerEvent {
  const _StatusRefreshRequested();
}

final class _ResultsFlushed extends ScannerEvent {
  const _ResultsFlushed();
}
