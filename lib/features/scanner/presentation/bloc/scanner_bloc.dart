import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show AppLifecycleState;
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ble_proximity_tracker/core/bluetooth/domain/entities/bluetooth_status.dart';
import 'package:ble_proximity_tracker/core/bluetooth/domain/entities/scanned_device.dart';
import 'package:ble_proximity_tracker/core/bluetooth/domain/usecases/bluetooth_status_usecases.dart';
import 'package:ble_proximity_tracker/core/bluetooth/domain/usecases/start_scan.dart';
import 'package:ble_proximity_tracker/core/bluetooth/domain/usecases/stop_scan.dart';
import 'package:ble_proximity_tracker/core/bluetooth/domain/usecases/watch_advertisements.dart';
import 'package:ble_proximity_tracker/core/error/failures.dart';
import 'package:ble_proximity_tracker/core/error/result.dart';
import 'package:ble_proximity_tracker/core/utils/clock.dart';
import 'package:ble_proximity_tracker/features/history/domain/usecases/history_usecases.dart';

import '../../domain/entities/device_filter.dart';
import '../../domain/usecases/filter_nearby_devices.dart';

part 'scanner_event.dart';
part 'scanner_state.dart';

class ScannerBloc extends Bloc<ScannerEvent, ScannerState> {
  ScannerBloc({
    required this._startScan,
    required this._stopScan,
    required this._watchAdvertisements,
    required this._watchBluetoothStatus,
    required this._getBluetoothStatus,
    required this._checkScanPermission,
    required this._enableBluetooth,
    required this._openAppSettings,
    required this._recordSightings,
    required FilterNearbyDevices filterNearbyDevices,
    required this._clock,
    this.flushInterval = const Duration(milliseconds: 500),
    this.staleAfter = const Duration(seconds: 15),
  }) : _filter = filterNearbyDevices,
       super(const ScannerState()) {
    on<ScannerStarted>(_onStarted);
    on<ScanControlEvent>(_onScanControl, transformer: sequential());
    on<_BluetoothStatusChanged>(_onBluetoothStatusChanged);
    on<_StatusRefreshRequested>(_onStatusRefreshRequested);
    on<AppLifecycleChanged>(_onAppLifecycleChanged);
    on<BluetoothEnableRequested>(_onBluetoothEnableRequested);
    on<AppSettingsRequested>((event, emit) => _openAppSettings());
    on<SearchQueryChanged>(
      (event, emit) =>
          _emitFilter(emit, state.filter.copyWith(query: event.query)),
    );
    on<MinRssiChanged>(
      (event, emit) =>
          _emitFilter(emit, state.filter.copyWith(minRssi: event.minRssi)),
    );
    on<NamedOnlyChanged>(
      (event, emit) =>
          _emitFilter(emit, state.filter.copyWith(namedOnly: event.namedOnly)),
    );
    on<FiltersCleared>(
      (event, emit) =>
          _emitFilter(emit, DeviceFilter(query: state.filter.query)),
    );
    on<_ResultsFlushed>(_onResultsFlushed);
  }

  final StartScan _startScan;
  final StopScan _stopScan;
  final WatchAdvertisements _watchAdvertisements;
  final WatchBluetoothStatus _watchBluetoothStatus;
  final GetBluetoothStatus _getBluetoothStatus;
  final CheckScanPermission _checkScanPermission;
  final EnableBluetooth _enableBluetooth;
  final OpenAppSettings _openAppSettings;
  final RecordSightings _recordSightings;
  final FilterNearbyDevices _filter;
  final Clock _clock;

  final Duration flushInterval;

  final Duration staleAfter;

  final _pending = <String, ScannedDevice>{};
  StreamSubscription<ScannedDevice>? _resultsSub;
  StreamSubscription<BluetoothStatus>? _statusSub;
  Timer? _flushTimer;
  int _messageId = 0;

  bool _resumeOnForeground = false;

  bool _restartWhenBluetoothOn = false;

  @visibleForTesting
  void flush() => add(const _ResultsFlushed());

  Future<void> _onStarted(
    ScannerStarted event,
    Emitter<ScannerState> emit,
  ) async {
    _statusSub ??= _watchBluetoothStatus().listen(
      (status) => add(_BluetoothStatusChanged(status)),
    );
    await _refreshStatus(emit);
  }

  Future<void> _onScanControl(
    ScanControlEvent event,
    Emitter<ScannerState> emit,
  ) async {
    switch (event) {
      case ScanStartRequested():
        await _start(emit);
      case ScanStopRequested(:final reason):
        await _stop(emit, reason);
      case ScanToggled():
        if (state.isScanning) {
          await _stop(emit, StopReason.user);
        } else {
          await _start(emit);
        }
    }
  }

  Future<void> _start(Emitter<ScannerState> emit) async {
    if (state.isScanning) return;
    emit(state.copyWith(isStarting: true));

    final result = await _startScan();
    switch (result) {
      case Ok():
        _resumeOnForeground = false;
        _restartWhenBluetoothOn = false;
        await _resultsSub?.cancel();
        _resultsSub = _watchAdvertisements().listen(
          _buffer,
          onError: (Object _) => add(const ScanStopRequested(StopReason.error)),
        );
        _flushTimer?.cancel();
        _flushTimer = Timer.periodic(
          flushInterval,
          (_) => add(const _ResultsFlushed()),
        );
        emit(
          state.copyWith(
            isStarting: false,
            isScanning: true,
            permission: ScanPermission.granted,
            btStatus: BluetoothStatus.on,
          ),
        );
      case Err(:final failure):
        _emitFailure(emit, failure);
    }
  }

  void _emitFailure(Emitter<ScannerState> emit, Failure failure) {
    switch (failure) {
      case PermissionFailure(:final permanentlyDenied):
        emit(
          state.copyWith(
            isStarting: false,
            permission: permanentlyDenied
                ? ScanPermission.permanentlyDenied
                : ScanPermission.denied,
          ),
        );
      case BluetoothOffFailure():
        _restartWhenBluetoothOn = true;
        emit(state.copyWith(isStarting: false, btStatus: BluetoothStatus.off));
      case BluetoothUnsupportedFailure():
        emit(
          state.copyWith(
            isStarting: false,
            btStatus: BluetoothStatus.unsupported,
          ),
        );
      case ScanThrottledFailure() || UnexpectedFailure():
        emit(
          state.copyWith(isStarting: false, message: _message(failure.message)),
        );
    }
  }

  Future<void> _stop(Emitter<ScannerState> emit, StopReason reason) async {
    if (reason == StopReason.user) {
      _resumeOnForeground = false;
      _restartWhenBluetoothOn = false;
    }
    if (!state.isScanning) return;

    switch (reason) {
      case StopReason.background:
        _resumeOnForeground = true;
      case StopReason.bluetoothOff:
        _restartWhenBluetoothOn = true;
      case StopReason.user:
      case StopReason.error:
        break;
    }

    _flushTimer?.cancel();
    _flushTimer = null;
    await _resultsSub?.cancel();
    _resultsSub = null;
    final devices = _mergePending();

    emit(
      state.copyWith(
        isScanning: false,
        devices: devices,
        visibleDevices: _filter(devices.values, state.filter),
        message: switch (reason) {
          StopReason.bluetoothOff => _message(
            'Bluetooth is off. Scanning resumes when it is back on.',
          ),
          StopReason.error => _message('Scanning stopped unexpectedly.'),
          StopReason.user || StopReason.background => null,
        },
      ),
    );

    final result = await _stopScan();
    if (result case Err(:final failure)) debugPrint(failure.message);
  }

  void _buffer(ScannedDevice device) {
    final previous = _pending[device.id] ?? state.devices[device.id];
    _pending[device.id] = previous == null ? device : previous.merge(device);
  }

  void _onResultsFlushed(_ResultsFlushed event, Emitter<ScannerState> emit) {
    if (!state.isScanning) return;
    final devices = _mergePending();
    emit(
      state.copyWith(
        devices: devices,
        visibleDevices: _filter(devices.values, state.filter),
      ),
    );
  }

  Map<String, ScannedDevice> _mergePending() {
    final now = _clock();
    final batch = _pending.values.toList();
    _pending.clear();

    final next = Map<String, ScannedDevice>.of(state.devices);
    for (final device in batch) {
      next[device.id] = device;
    }
    next.removeWhere((_, d) => now.difference(d.seenAt) > staleAfter);

    if (batch.isNotEmpty) unawaited(_record(batch));
    return next;
  }

  Future<void> _record(List<ScannedDevice> batch) async {
    final result = await _recordSightings(batch);
    if (result case Err(:final failure)) debugPrint(failure.message);
  }

  void _onBluetoothStatusChanged(
    _BluetoothStatusChanged event,
    Emitter<ScannerState> emit,
  ) {
    emit(state.copyWith(btStatus: event.status));
    if (event.status == BluetoothStatus.on) {
      if (_restartWhenBluetoothOn) {
        _restartWhenBluetoothOn = false;
        add(const ScanStartRequested());
      }
    } else if (state.isScanning) {
      add(const ScanStopRequested(StopReason.bluetoothOff));
    }
  }

  void _onAppLifecycleChanged(
    AppLifecycleChanged event,
    Emitter<ScannerState> emit,
  ) {
    switch (event.state) {
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        if (state.isScanning) {
          add(const ScanStopRequested(StopReason.background));
        }
      case AppLifecycleState.resumed:
        if (_resumeOnForeground) {
          _resumeOnForeground = false;
          add(const ScanStartRequested());
        } else {
          add(const _StatusRefreshRequested());
        }
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        break;
    }
  }

  Future<void> _onStatusRefreshRequested(
    _StatusRefreshRequested event,
    Emitter<ScannerState> emit,
  ) => _refreshStatus(emit);

  Future<void> _refreshStatus(Emitter<ScannerState> emit) async {
    try {
      final status = await _getBluetoothStatus();
      final permission = state.permission == null
          ? null
          : await _checkScanPermission();
      emit(state.copyWith(btStatus: status, permission: permission));
    } catch (e) {
      debugPrint('Could not read Bluetooth state: $e');
    }
  }

  Future<void> _onBluetoothEnableRequested(
    BluetoothEnableRequested event,
    Emitter<ScannerState> emit,
  ) async {
    _restartWhenBluetoothOn = true;
    final enabled = await _enableBluetooth();
    if (!enabled) {
      emit(
        state.copyWith(
          message: _message('Turn on Bluetooth from system settings.'),
        ),
      );
    }
  }

  void _emitFilter(Emitter<ScannerState> emit, DeviceFilter filter) => emit(
    state.copyWith(
      filter: filter,
      visibleDevices: _filter(state.devices.values, filter),
    ),
  );

  ScannerMessage _message(String text) => ScannerMessage(++_messageId, text);

  @override
  Future<void> close() async {
    _flushTimer?.cancel();
    await _resultsSub?.cancel();
    await _statusSub?.cancel();
    if (state.isScanning) await _stopScan();
    return super.close();
  }
}
