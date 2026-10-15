import 'package:equatable/equatable.dart';

class HistoryEntry extends Equatable {
  const HistoryEntry({
    required this.id,
    required this.lastRssi,
    required this.bestRssi,
    required this.firstSeen,
    required this.lastSeen,
    this.name,
  });

  final String id;
  final String? name;
  final int lastRssi;
  final int bestRssi;
  final DateTime firstSeen;
  final DateTime lastSeen;

  bool get hasName => name?.trim().isNotEmpty ?? false;

  String get displayName => hasName ? name!.trim() : 'Unknown device';

  @override
  List<Object?> get props => [
    id,
    name,
    lastRssi,
    bestRssi,
    firstSeen,
    lastSeen,
  ];
}
