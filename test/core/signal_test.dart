import 'package:flutter_test/flutter_test.dart';

import 'package:ble_proximity_tracker/core/signal/scan_throttle_guard.dart';
import 'package:ble_proximity_tracker/core/signal/signal_smoothing.dart';
import 'package:ble_proximity_tracker/core/signal/signal_zone.dart';

void main() {
  group('SignalZone.fromRssi follows the study-case table', () {
    const cases = {
      -10: SignalZone.veryStrong,
      -30: SignalZone.veryStrong,
      -31: SignalZone.strong,
      -50: SignalZone.strong,
      -51: SignalZone.fair,
      -70: SignalZone.fair,
      -71: SignalZone.weak,
      -80: SignalZone.weak,
      -81: SignalZone.veryWeak,
      -90: SignalZone.veryWeak,
      -91: SignalZone.lost,
      -127: SignalZone.lost,
    };
    cases.forEach((rssi, zone) {
      test('$rssi dBm -> ${zone.name}', () {
        expect(SignalZone.fromRssi(rssi), zone);
      });
    });
  });

  group('estimateDistanceMeters agrees with the table', () {
    test('-30 dBm is under 1 m', () {
      expect(estimateDistanceMeters(-30), lessThan(1));
    });
    test('-50 dBm is about 3 m', () {
      expect(estimateDistanceMeters(-50), closeTo(3, 0.3));
    });
    test('-70 dBm is about 10 m', () {
      expect(estimateDistanceMeters(-70), closeTo(10, 0.5));
    });
    test('-80 dBm is within 10–20 m', () {
      expect(estimateDistanceMeters(-80), inInclusiveRange(10, 20));
    });
    test('-90 dBm is beyond 20 m', () {
      expect(estimateDistanceMeters(-90), greaterThan(20));
    });
  });

  test('RssiSmoother applies an exponential moving average', () {
    final smoother = RssiSmoother(alpha: 0.3);
    expect(smoother.add(-60), -60);
    expect(smoother.add(-70), closeTo(-63, 0.001));
  });

  test('ZoneHysteresis ignores small dips across a boundary', () {
    final h = ZoneHysteresis(marginDb: 3);
    expect(h.update(-49), SignalZone.strong);
    expect(h.update(-51), SignalZone.strong, reason: 'within 3 dB margin');
    expect(h.update(-54), SignalZone.fair, reason: 'clearly past boundary');
    expect(h.update(-48), SignalZone.fair, reason: 'within margin again');
    expect(h.update(-46), SignalZone.strong);
  });

  test('ScanThrottleGuard blocks the 6th start within 30 s', () {
    final guard = ScanThrottleGuard();
    final t0 = DateTime(2026, 1, 1);
    for (var i = 0; i < 5; i++) {
      final t = t0.add(Duration(seconds: i));
      expect(guard.waitBeforeNextStart(t), isNull);
      guard.recordStart(t);
    }
    expect(
      guard.waitBeforeNextStart(t0.add(const Duration(seconds: 10))),
      const Duration(seconds: 20),
    );
    expect(
      guard.waitBeforeNextStart(t0.add(const Duration(seconds: 30))),
      isNull,
    );
  });
}
