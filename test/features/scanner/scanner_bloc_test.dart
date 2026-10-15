import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/widgets.dart' show AppLifecycleState;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:ble_proximity_tracker/core/bluetooth/domain/entities/bluetooth_status.dart';
import 'package:ble_proximity_tracker/core/bluetooth/domain/entities/scanned_device.dart';
import 'package:ble_proximity_tracker/core/bluetooth/domain/usecases/bluetooth_status_usecases.dart';
import 'package:ble_proximity_tracker/core/bluetooth/domain/usecases/start_scan.dart';
import 'package:ble_proximity_tracker/core/bluetooth/domain/usecases/stop_scan.dart';
import 'package:ble_proximity_tracker/core/bluetooth/domain/usecases/watch_advertisements.dart';
import 'package:ble_proximity_tracker/features/history/domain/usecases/history_usecases.dart';
import 'package:ble_proximity_tracker/features/scanner/domain/entities/device_filter.dart';
import 'package:ble_proximity_tracker/features/scanner/domain/usecases/filter_nearby_devices.dart';
import 'package:ble_proximity_tracker/features/scanner/presentation/bloc/scanner_bloc.dart';

import '../../helpers/fakes.dart';

void main() {
  late FakeBluetoothRepository ble;
  late MockHistoryRepository history;
  late DateTime now;

  setUpAll(() => registerFallbackValue(<ScannedDevice>[]));

  setUp(() {
    ble = FakeBluetoothRepository();
    history = MockHistoryRepository();
    when(() => history.recordSightings(any())).thenAnswer((_) async {});
    now = DateTime(2026, 10, 15, 10);
  });

  ScannerBloc buildBloc() => ScannerBloc(
    startScan: StartScan(ble, () => now),
    stopScan: StopScan(ble),
    watchAdvertisements: WatchAdvertisements(ble),
    watchBluetoothStatus: WatchBluetoothStatus(ble),
    getBluetoothStatus: GetBluetoothStatus(ble),
    checkScanPermission: CheckScanPermission(ble),
    enableBluetooth: EnableBluetooth(ble),
    openAppSettings: OpenAppSettings(ble),
    recordSightings: RecordSightings(history),
    filterNearbyDevices: const FilterNearbyDevices(),
    clock: () => now,
    flushInterval: const Duration(hours: 1),
  );

  ScannedDevice device(String id, int rssi, {String? name}) =>
      ScannedDevice(id: id, name: name, rssi: rssi, seenAt: now);

  Future<ScannerBloc> scanningBloc() async {
    final bloc = buildBloc()..add(const ScannerStarted());
    addTearDown(bloc.close);
    bloc.add(const ScanStartRequested());
    await pump();
    return bloc;
  }

  test('lists devices strongest first and records them to history', () async {
    final bloc = await scanningBloc();
    expect(bloc.state.isScanning, isTrue);

    ble
      ..emitAdvertisement(device('AA', -80, name: 'Tag'))
      ..emitAdvertisement(device('BB', -45))
      ..emitAdvertisement(device('CC', -60, name: 'Watch'));
    await pump();
    bloc.flush();
    await pump();

    expect(bloc.state.visibleDevices.map((d) => d.id), ['BB', 'CC', 'AA']);
    final saved =
        verify(() => history.recordSightings(captureAny())).captured.single
            as List<ScannedDevice>;
    expect(saved.map((d) => d.id), containsAll(['AA', 'BB', 'CC']));
  });

  test('applies minimum RSSI, named-only and search filters', () async {
    final bloc = await scanningBloc();
    ble
      ..emitAdvertisement(device('AA:01', -85, name: 'Tag'))
      ..emitAdvertisement(device('BB:02', -45))
      ..emitAdvertisement(device('CC:03', -60, name: 'Watch'));
    await pump();
    bloc
      ..flush()
      ..add(const MinRssiChanged(-80));
    await pump();
    expect(bloc.state.visibleDevices.map((d) => d.id), ['BB:02', 'CC:03']);

    bloc.add(const NamedOnlyChanged(true));
    await pump();
    expect(bloc.state.visibleDevices.map((d) => d.id), ['CC:03']);

    bloc
      ..add(const FiltersCleared())
      ..add(const SearchQueryChanged('bb02'));
    await pump();
    expect(bloc.state.visibleDevices.map((d) => d.id), ['BB:02']);
  });

  test('keeps the last known name when a packet has none', () async {
    final bloc = await scanningBloc();
    ble.emitAdvertisement(device('AA', -70, name: 'Tag'));
    await pump();
    bloc.flush();
    await pump();
    ble.emitAdvertisement(device('AA', -60));
    await pump();
    bloc.flush();
    await pump();

    expect(bloc.state.devices['AA']!.name, 'Tag');
    expect(bloc.state.devices['AA']!.rssi, -60);
  });

  test('prunes devices that stopped advertising', () async {
    final bloc = await scanningBloc();
    ble.emitAdvertisement(device('AA', -70));
    await pump();
    bloc.flush();
    await pump();
    expect(bloc.state.devices, contains('AA'));

    now = now.add(const Duration(seconds: 16));
    bloc.flush();
    await pump();
    expect(bloc.state.devices, isEmpty);
  });

  blocTest<ScannerBloc, ScannerState>(
    'does not scan when permission is permanently denied',
    setUp: () => ble.permission = ScanPermission.permanentlyDenied,
    build: buildBloc,
    act: (bloc) => bloc.add(const ScanStartRequested()),
    expect: () => [
      const ScannerState(isStarting: true),
      const ScannerState(permission: ScanPermission.permanentlyDenied),
    ],
    verify: (_) => expect(ble.startCalls, 0),
  );

  test('keeps a denied permission when the app resumes', () async {
    ble.permission = ScanPermission.denied;
    final bloc = buildBloc();
    addTearDown(bloc.close);

    bloc
      ..add(const ScanStartRequested())
      ..add(const AppLifecycleChanged(AppLifecycleState.resumed));
    await pump();

    expect(bloc.state.permission, ScanPermission.denied);
    expect(ble.startCalls, 0);
  });

  test('clears the denied state once granted in settings', () async {
    ble.permission = ScanPermission.permanentlyDenied;
    final bloc = buildBloc();
    addTearDown(bloc.close);
    bloc.add(const ScanStartRequested());
    await pump();
    expect(bloc.state.permission, ScanPermission.permanentlyDenied);

    ble.permission = ScanPermission.granted;
    bloc.add(const AppLifecycleChanged(AppLifecycleState.resumed));
    await pump();

    expect(bloc.state.permission, ScanPermission.granted);
  });

  test(
    'stops when Bluetooth turns off and resumes when it is back on',
    () async {
      final bloc = await scanningBloc();

      ble.emitStatus(BluetoothStatus.off);
      await pump();
      expect(bloc.state.isScanning, isFalse);
      expect(bloc.state.btStatus, BluetoothStatus.off);
      expect(bloc.state.message?.text, contains('Bluetooth is off'));

      ble.emitStatus(BluetoothStatus.on);
      await pump();
      expect(bloc.state.isScanning, isTrue);
      expect(ble.startCalls, 2);
    },
  );

  test('pauses in background and resumes in foreground', () async {
    final bloc = await scanningBloc();

    bloc
      ..add(const AppLifecycleChanged(AppLifecycleState.hidden))
      ..add(const AppLifecycleChanged(AppLifecycleState.paused));
    await pump();
    expect(bloc.state.isScanning, isFalse);

    bloc.add(const AppLifecycleChanged(AppLifecycleState.resumed));
    await pump();
    expect(bloc.state.isScanning, isTrue);
  });

  test('does not auto-resume a scan the user stopped', () async {
    final bloc = await scanningBloc();
    bloc.add(const ScanStopRequested());
    await pump();

    bloc
      ..add(const AppLifecycleChanged(AppLifecycleState.paused))
      ..add(const AppLifecycleChanged(AppLifecycleState.resumed));
    await pump();

    expect(bloc.state.isScanning, isFalse);
    expect(ble.startCalls, 1);
  });

  test('shows a message instead of a 6th start within 30 s', () async {
    final bloc = buildBloc();
    addTearDown(bloc.close);
    for (var i = 0; i < 5; i++) {
      bloc
        ..add(const ScanStartRequested())
        ..add(const ScanStopRequested());
    }
    bloc.add(const ScanStartRequested());
    await pump(60);

    expect(ble.startCalls, 5);
    expect(bloc.state.isScanning, isFalse);
    expect(bloc.state.message?.text, contains('Try again'));
  });

  blocTest<ScannerBloc, ScannerState>(
    'filter changes update the filter state',
    build: buildBloc,
    act: (bloc) => bloc.add(const MinRssiChanged(-70)),
    expect: () => [const ScannerState(filter: DeviceFilter(minRssi: -70))],
  );
}
