import 'package:ble_proximity_tracker/core/bluetooth/domain/entities/scanned_device.dart';

import '../entities/device_filter.dart';

class FilterNearbyDevices {
  const FilterNearbyDevices();

  List<ScannedDevice> call(
    Iterable<ScannedDevice> devices,
    DeviceFilter filter,
  ) => devices.where(filter.matches).toList()
    ..sort((a, b) {
      final byRssi = b.rssi.compareTo(a.rssi);
      return byRssi != 0 ? byRssi : a.id.compareTo(b.id);
    });
}
