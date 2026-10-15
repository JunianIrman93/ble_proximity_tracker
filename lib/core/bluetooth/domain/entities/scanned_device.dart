import 'package:equatable/equatable.dart';

import 'package:ble_proximity_tracker/core/signal/signal_zone.dart';

class ScannedDevice extends Equatable {
  const ScannedDevice({
    required this.id,
    required this.rssi,
    required this.seenAt,
    this.name,
  });

  final String id;
  final String? name;
  final int rssi;
  final DateTime seenAt;

  bool get hasName => name != null && name!.trim().isNotEmpty;

  String get displayName => hasName ? name!.trim() : 'Unknown device';

  SignalZone get zone => SignalZone.fromRssi(rssi);

  double get estimatedDistanceMeters => estimateDistanceMeters(rssi);

  ScannedDevice merge(ScannedDevice newer) => ScannedDevice(
    id: id,
    rssi: newer.rssi,
    seenAt: newer.seenAt,
    name: newer.hasName ? newer.name : name,
  );

  @override
  List<Object?> get props => [id, name, rssi, seenAt];
}
