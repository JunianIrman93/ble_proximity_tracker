import 'package:flutter_test/flutter_test.dart';

import 'package:ble_proximity_tracker/core/bluetooth/domain/entities/bluetooth_status.dart';
import 'package:ble_proximity_tracker/core/bluetooth/domain/usecases/start_scan.dart';
import 'package:ble_proximity_tracker/core/error/failures.dart';
import 'package:ble_proximity_tracker/core/error/result.dart';

import '../helpers/fakes.dart';

void main() {
  late FakeBluetoothRepository repo;
  late StartScan startScan;
  final now = DateTime(2026, 10, 15, 10);

  setUp(() {
    repo = FakeBluetoothRepository();
    startScan = StartScan(repo, () => now);
  });

  Failure? failureOf(Result<void> result) =>
      result is Err<void> ? result.failure : null;

  test('starts when permission is granted and Bluetooth is on', () async {
    final result = await startScan();
    expect(result, isA<Ok<void>>());
    expect(repo.startCalls, 1);
  });

  test('maps a denied permission', () async {
    repo.permission = ScanPermission.denied;
    expect(
      failureOf(await startScan()),
      const PermissionFailure(permanentlyDenied: false),
    );
    expect(repo.startCalls, 0);
  });

  test('maps a permanently denied permission', () async {
    repo.permission = ScanPermission.permanentlyDenied;
    expect(
      failureOf(await startScan()),
      const PermissionFailure(permanentlyDenied: true),
    );
  });

  test('fails when Bluetooth is off or unsupported', () async {
    repo.status = BluetoothStatus.off;
    expect(failureOf(await startScan()), const BluetoothOffFailure());

    repo.status = BluetoothStatus.unsupported;
    expect(failureOf(await startScan()), const BluetoothUnsupportedFailure());
    expect(repo.startCalls, 0);
  });

  test('refuses the 6th start within 30 s', () async {
    for (var i = 0; i < 5; i++) {
      expect(await startScan(), isA<Ok<void>>());
    }
    expect(failureOf(await startScan()), isA<ScanThrottledFailure>());
    expect(repo.startCalls, 5);
  });
}
