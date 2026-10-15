import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ble_proximity_tracker/core/bluetooth/domain/entities/scanned_device.dart';
import 'package:ble_proximity_tracker/core/bluetooth/domain/usecases/watch_advertisements.dart';
import 'package:ble_proximity_tracker/core/signal/signal_zone.dart';
import 'package:ble_proximity_tracker/features/radar/domain/usecases/track_device_proximity.dart';
import 'package:ble_proximity_tracker/features/radar/presentation/bloc/radar_bloc.dart';

import '../../helpers/fakes.dart';

void main() {
  late FakeBluetoothRepository ble;
  late DateTime now;

  setUp(() {
    ble = FakeBluetoothRepository();
    now = DateTime(2026, 10, 15, 10);
  });

  ScannedDevice reading(String id, int rssi, {String? name}) =>
      ScannedDevice(id: id, name: name, rssi: rssi, seenAt: now);

  group('TrackDeviceProximity', () {
    test('smooths readings and maps them to a zone', () {
      final track = TrackDeviceProximity(WatchAdvertisements(ble));
      final s1 = track.addReading(reading('AA', -60));
      expect(s1.zone, SignalZone.fair);
      expect(s1.distanceMeters, closeTo(5.4, 0.3));

      final s2 = track.addReading(reading('AA', -70));
      expect(s2.smoothedRssi, closeTo(-63, 0.001));
      expect(s2.samples, [-60, -70]);
      expect(s2.sampleCount, 2);
    });

    test('marks the device lost after 5 s and recovers on the next packet', () {
      final track = TrackDeviceProximity(WatchAdvertisements(ble));
      track.addReading(reading('AA', -60));

      expect(
        track.checkLost(now.add(const Duration(seconds: 4))).isLost,
        isFalse,
      );
      now = now.add(const Duration(seconds: 6));
      expect(track.checkLost(now).isLost, isTrue);

      expect(track.addReading(reading('AA', -45)).zone, SignalZone.strong);
    });

    test('only emits readings of the tracked device', () async {
      final track = TrackDeviceProximity(WatchAdvertisements(ble));
      final updates = <ProximityUpdate>[];
      final sub = track('AA').listen(updates.add);
      addTearDown(sub.cancel);

      ble
        ..emitAdvertisement(reading('BB', -40))
        ..emitAdvertisement(reading('AA', -60, name: 'Tag'));
      await pump();

      expect(updates, hasLength(1));
      expect(updates.single.device.name, 'Tag');
    });
  });

  group('RadarBloc', () {
    RadarBloc build() => RadarBloc(
      deviceId: 'AA',
      trackProximity: TrackDeviceProximity(WatchAdvertisements(ble)),
      clock: () => now,
      tickInterval: const Duration(hours: 1),
    );

    blocTest<RadarBloc, RadarState>(
      'shows live readings for the selected device',
      build: build,
      act: (bloc) async {
        bloc.add(const RadarStarted());
        await pump();
        ble.emitAdvertisement(reading('AA', -60, name: 'Tag'));
      },
      wait: const Duration(milliseconds: 10),
      verify: (bloc) {
        expect(bloc.state.displayName, 'Tag');
        expect(bloc.state.snapshot.rawRssi, -60);
        expect(bloc.state.snapshot.zone, SignalZone.fair);
      },
    );

    blocTest<RadarBloc, RadarState>(
      'switches to lost when the device goes silent',
      build: build,
      act: (bloc) async {
        bloc.add(const RadarStarted());
        await pump();
        ble.emitAdvertisement(reading('AA', -60));
        await pump();
        now = now.add(const Duration(seconds: 6));
        bloc.tick();
      },
      wait: const Duration(milliseconds: 10),
      verify: (bloc) => expect(bloc.state.snapshot.isLost, isTrue),
    );

    test('starts from the last known reading', () {
      final bloc = RadarBloc(
        deviceId: 'AA',
        lastKnown: reading('AA', -45, name: 'Watch'),
        trackProximity: TrackDeviceProximity(WatchAdvertisements(ble)),
        clock: () => now,
      );
      addTearDown(bloc.close);
      expect(bloc.state.displayName, 'Watch');
      expect(bloc.state.snapshot.zone, SignalZone.strong);
    });
  });
}
