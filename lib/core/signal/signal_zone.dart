import 'dart:math' as math;

enum SignalZone {
  veryStrong('Very strong', 'Very close', '< 1 m', -30),
  strong('Strong', 'Close', '1–3 m', -50),
  fair('Fair', 'Good', '3–10 m', -70),
  weak('Weak', 'Weak', '10–20 m', -80),
  veryWeak('Very weak', 'Intermittent', '> 20 m', -90),
  lost('Lost', 'Out of range', 'Out of range', null);

  const SignalZone(
    this.label,
    this.proximity,
    this.distanceRange,
    this.lowerBoundDbm,
  );

  final String label;
  final String proximity;
  final String distanceRange;

  final int? lowerBoundDbm;

  String get dbmRange => switch (this) {
    veryStrong => '≥ −30 dBm',
    strong => '−31 to −50 dBm',
    fair => '−51 to −70 dBm',
    weak => '−71 to −80 dBm',
    veryWeak => '−81 to −90 dBm',
    lost => '< −90 dBm',
  };

  static SignalZone fromRssi(num rssi) {
    for (final zone in values) {
      final bound = zone.lowerBoundDbm;
      if (bound != null && rssi >= bound) return zone;
    }
    return lost;
  }
}

const int kMeasuredPowerDbm = -32;

const double kPathLossExponent = 3.8;

double estimateDistanceMeters(
  num rssi, {
  int measuredPower = kMeasuredPowerDbm,
  double pathLossExponent = kPathLossExponent,
}) {
  final meters = math
      .pow(10, (measuredPower - rssi) / (10 * pathLossExponent))
      .toDouble();
  return meters.clamp(0.1, 100.0).toDouble();
}

String formatDistance(double meters) => meters < 1
    ? '${(meters * 100).round()} cm'
    : '${meters.toStringAsFixed(1)} m';

double signalStrengthFraction(num rssi) =>
    ((rssi + 100) / 70).clamp(0.0, 1.0).toDouble();
