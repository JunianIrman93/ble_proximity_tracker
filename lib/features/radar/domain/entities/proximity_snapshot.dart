import 'dart:math' as math;

import 'package:equatable/equatable.dart';

import 'package:ble_proximity_tracker/core/signal/signal_zone.dart';

class ProximitySnapshot extends Equatable {
  const ProximitySnapshot({
    this.rawRssi,
    this.smoothedRssi,
    this.zone = SignalZone.lost,
    this.distanceMeters,
    this.lastSeen,
    this.samples = const [],
    this.sampleCount = 0,
  });

  final int? rawRssi;
  final double? smoothedRssi;

  final SignalZone zone;
  final double? distanceMeters;
  final DateTime? lastSeen;

  final List<int> samples;
  final int sampleCount;

  bool get isLost => zone == SignalZone.lost;

  double? get stabilityDb {
    final recent = samples.length > 20
        ? samples.sublist(samples.length - 20)
        : samples;
    if (recent.length < 3) return null;
    final mean = recent.reduce((a, b) => a + b) / recent.length;
    final variance =
        recent.map((v) => (v - mean) * (v - mean)).reduce((a, b) => a + b) /
        recent.length;
    return math.sqrt(variance);
  }

  ProximitySnapshot copyWith({SignalZone? zone}) => ProximitySnapshot(
    rawRssi: rawRssi,
    smoothedRssi: smoothedRssi,
    zone: zone ?? this.zone,
    distanceMeters: distanceMeters,
    lastSeen: lastSeen,
    samples: samples,
    sampleCount: sampleCount,
  );

  @override
  List<Object?> get props => [
    rawRssi,
    smoothedRssi,
    zone,
    distanceMeters,
    lastSeen,
    samples,
    sampleCount,
  ];
}
