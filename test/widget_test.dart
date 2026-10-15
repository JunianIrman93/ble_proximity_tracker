import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ble_proximity_tracker/core/bluetooth/domain/entities/scanned_device.dart';
import 'package:ble_proximity_tracker/core/theme/app_theme.dart';
import 'package:ble_proximity_tracker/core/widgets/neu.dart';
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

  testWidgets('NeuButton is announced on its own, not with nearby text', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      host(
        ListView(
          children: [
            Column(
              children: [
                const Text('Active devices'),
                NeuButton(label: 'Stop scan', latched: true, onPressed: () {}),
              ],
            ),
          ],
        ),
      ),
    );

    final node = tester.getSemantics(find.byType(NeuButton));
    expect(node.label, 'STOP SCAN');
    expect(node.flagsCollection.isButton, isTrue);
    expect(node.flagsCollection.isToggled, Tristate.none);
    semantics.dispose();
  });

  testWidgets('NeuIconButton is a button labelled by its tooltip', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      host(
        NeuIconButton(
          tooltip: 'Filters',
          icon: const Icon(Icons.tune),
          onPressed: () {},
        ),
      ),
    );

    final node = tester.getSemantics(find.byType(NeuBox));
    expect(node.label, 'Filters');
    expect(node.flagsCollection.isButton, isTrue);
    semantics.dispose();
  });

  testWidgets('DeviceCard falls back to "Unknown device"', (tester) async {
    final device = ScannedDevice(id: 'X', rssi: -40, seenAt: DateTime(2026));
    await tester.pumpWidget(host(DeviceCard(device: device)));
    expect(find.text('Unknown device'), findsOneWidget);
  });
}
