part of 'radar_bloc.dart';

class RadarState extends Equatable {
  const RadarState({
    required this.deviceId,
    required this.snapshot,
    required this.now,
    this.name,
  });

  final String deviceId;
  final String? name;
  final ProximitySnapshot snapshot;

  final DateTime now;

  String get displayName =>
      (name?.trim().isNotEmpty ?? false) ? name!.trim() : 'Unknown device';

  Duration? get sinceLastSeen {
    final seen = snapshot.lastSeen;
    if (seen == null) return null;
    final diff = now.difference(seen);
    return diff.isNegative ? Duration.zero : diff;
  }

  RadarState copyWith({
    String? name,
    ProximitySnapshot? snapshot,
    DateTime? now,
  }) => RadarState(
    deviceId: deviceId,
    name: name ?? this.name,
    snapshot: snapshot ?? this.snapshot,
    now: now ?? this.now,
  );

  @override
  List<Object?> get props => [deviceId, name, snapshot, now];
}
