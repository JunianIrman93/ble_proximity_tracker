import 'package:ble_proximity_tracker/core/bluetooth/domain/entities/scanned_device.dart';
import 'package:ble_proximity_tracker/core/bluetooth/domain/usecases/watch_advertisements.dart';
import 'package:ble_proximity_tracker/core/signal/signal_smoothing.dart';
import 'package:ble_proximity_tracker/core/signal/signal_zone.dart';

import '../entities/proximity_snapshot.dart';

typedef ProximityUpdate = ({ScannedDevice device, ProximitySnapshot snapshot});

class TrackDeviceProximity {
  TrackDeviceProximity(
    this._watchAdvertisements, {
    this.lostAfter = const Duration(seconds: 5),
    this.historyLength = 60,
  });

  final WatchAdvertisements _watchAdvertisements;
  final Duration lostAfter;
  final int historyLength;

  final _smoother = RssiSmoother(alpha: 0.3);
  final _hysteresis = ZoneHysteresis(marginDb: 3);
  ProximitySnapshot _snapshot = const ProximitySnapshot();

  ProximitySnapshot get snapshot => _snapshot;

  Stream<ProximityUpdate> call(String deviceId) =>
      _watchAdvertisements(deviceId: deviceId)
          .map((device) => (device: device, snapshot: addReading(device)));

  ProximitySnapshot addReading(ScannedDevice device) {
    final smoothed = _smoother.add(device.rssi);
    final zone = _hysteresis.update(smoothed);
    final samples = [..._snapshot.samples, device.rssi];
    if (samples.length > historyLength) {
      samples.removeRange(0, samples.length - historyLength);
    }
    return _snapshot = ProximitySnapshot(
      rawRssi: device.rssi,
      smoothedRssi: smoothed,
      zone: zone,
      distanceMeters: estimateDistanceMeters(smoothed),
      lastSeen: device.seenAt,
      samples: samples,
      sampleCount: _snapshot.sampleCount + 1,
    );
  }

  ProximitySnapshot checkLost(DateTime now) {
    final seen = _snapshot.lastSeen;
    if (_snapshot.isLost || seen == null) return _snapshot;
    if (now.difference(seen) <= lostAfter) return _snapshot;

    _hysteresis.forceLost();
    _smoother.reset();
    return _snapshot = _snapshot.copyWith(zone: SignalZone.lost);
  }
}
