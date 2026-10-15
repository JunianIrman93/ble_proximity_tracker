import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ble_proximity_tracker/core/bluetooth/domain/entities/scanned_device.dart';
import 'package:ble_proximity_tracker/core/theme/app_theme.dart';
import 'package:ble_proximity_tracker/features/scanner/presentation/widgets/device_card.dart';

void main() {
  Widget host(Widget child) => MaterialApp(
    theme: AppTheme.dark,
    home: Scaffold(body: child),
  );

  testWidgets('DeviceCard shows name, id, raw RSSI and zone', (tester) async {
    final device = ScannedDevice(
      id: 'AA:BB:CC:11:22:33',
      name: 'Tile Tag',
      rssi: -67,
      seenAt: DateTime(2026),
    );
    await tester.pumpWidget(host(DeviceCard(device: device)));

    expect(find.text('Tile Tag'), findsOneWidget);
    expect(find.text('AA:BB:CC:11:22:33'), findsOneWidget);
    expect(find.text('-67'), findsOneWidget);
    expect(find.text('Fair'), findsOneWidget);
  });

  testWidgets('DeviceCard falls back to "Unknown device"', (tester) async {
    final device = ScannedDevice(id: 'X', rssi: -40, seenAt: DateTime(2026));
    await tester.pumpWidget(host(DeviceCard(device: device)));
    expect(find.text('Unknown device'), findsOneWidget);
  });
}
