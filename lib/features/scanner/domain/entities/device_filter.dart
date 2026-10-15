import 'package:equatable/equatable.dart';

import 'package:ble_proximity_tracker/core/bluetooth/domain/entities/scanned_device.dart';

class DeviceFilter extends Equatable {
  const DeviceFilter({this.query = '', this.minRssi, this.namedOnly = false});

  final String query;

  final int? minRssi;

  final bool namedOnly;

  bool get hasSignalOrNameFilter => minRssi != null || namedOnly;

  bool get isActive => query.trim().isNotEmpty || hasSignalOrNameFilter;

  bool matches(ScannedDevice device) {
    final min = minRssi;
    if (min != null && device.rssi < min) return false;
    if (namedOnly && !device.hasName) return false;

    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    if (device.name?.toLowerCase().contains(q) ?? false) return true;
    return _normalizeId(device.id).contains(_normalizeId(q));
  }

  static String _normalizeId(String value) =>
      value.toLowerCase().replaceAll(RegExp('[:-]'), '');

  static const _unset = Object();

  DeviceFilter copyWith({
    String? query,
    Object? minRssi = _unset,
    bool? namedOnly,
  }) => DeviceFilter(
    query: query ?? this.query,
    minRssi: identical(minRssi, _unset) ? this.minRssi : minRssi as int?,
    namedOnly: namedOnly ?? this.namedOnly,
  );

  @override
  List<Object?> get props => [query, minRssi, namedOnly];
}
