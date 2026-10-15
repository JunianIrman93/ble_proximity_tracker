import 'package:flutter/material.dart';

import 'package:ble_proximity_tracker/app.dart';
import 'package:ble_proximity_tracker/core/di/injection.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  runApp(const BleTrackerApp());
}
