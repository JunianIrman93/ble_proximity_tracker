part of 'scanner_bloc.dart';

class ScannerMessage extends Equatable {
  const ScannerMessage(this.id, this.text);

  final int id;
  final String text;

  @override
  List<Object?> get props => [id];
}

class ScannerState extends Equatable {
  const ScannerState({
    this.btStatus = BluetoothStatus.unknown,
    this.permission,
    this.isScanning = false,
    this.isStarting = false,
    this.devices = const {},
    this.visibleDevices = const [],
    this.filter = const DeviceFilter(),
    this.message,
  });

  final BluetoothStatus btStatus;

  final ScanPermission? permission;
  final bool isScanning;
  final bool isStarting;

  final Map<String, ScannedDevice> devices;

  final List<ScannedDevice> visibleDevices;
  final DeviceFilter filter;
  final ScannerMessage? message;

  ScannedDevice? get strongest => devices.values.fold<ScannedDevice?>(
    null,
    (best, d) => best == null || d.rssi > best.rssi ? d : best,
  );

  static const _unset = Object();

  ScannerState copyWith({
    BluetoothStatus? btStatus,
    Object? permission = _unset,
    bool? isScanning,
    bool? isStarting,
    Map<String, ScannedDevice>? devices,
    List<ScannedDevice>? visibleDevices,
    DeviceFilter? filter,
    ScannerMessage? message,
  }) => ScannerState(
    btStatus: btStatus ?? this.btStatus,
    permission: identical(permission, _unset)
        ? this.permission
        : permission as ScanPermission?,
    isScanning: isScanning ?? this.isScanning,
    isStarting: isStarting ?? this.isStarting,
    devices: devices ?? this.devices,
    visibleDevices: visibleDevices ?? this.visibleDevices,
    filter: filter ?? this.filter,
    message: message ?? this.message,
  );

  @override
  List<Object?> get props => [
    btStatus,
    permission,
    isScanning,
    isStarting,
    devices,
    visibleDevices,
    filter,
    message,
  ];
}
