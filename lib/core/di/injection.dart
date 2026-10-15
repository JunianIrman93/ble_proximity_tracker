import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ble_proximity_tracker/core/bluetooth/data/datasources/ble_data_source.dart';
import 'package:ble_proximity_tracker/core/bluetooth/data/repositories/bluetooth_repository_impl.dart';
import 'package:ble_proximity_tracker/core/bluetooth/domain/entities/scanned_device.dart';
import 'package:ble_proximity_tracker/core/bluetooth/domain/repositories/bluetooth_repository.dart';
import 'package:ble_proximity_tracker/core/bluetooth/domain/usecases/bluetooth_status_usecases.dart';
import 'package:ble_proximity_tracker/core/bluetooth/domain/usecases/start_scan.dart';
import 'package:ble_proximity_tracker/core/bluetooth/domain/usecases/stop_scan.dart';
import 'package:ble_proximity_tracker/core/bluetooth/domain/usecases/watch_advertisements.dart';
import 'package:ble_proximity_tracker/core/utils/clock.dart';
import 'package:ble_proximity_tracker/features/history/data/datasources/app_database.dart';
import 'package:ble_proximity_tracker/features/history/data/datasources/device_history_dao.dart';
import 'package:ble_proximity_tracker/features/history/data/repositories/history_repository_impl.dart';
import 'package:ble_proximity_tracker/features/history/domain/repositories/history_repository.dart';
import 'package:ble_proximity_tracker/features/history/domain/usecases/history_usecases.dart';
import 'package:ble_proximity_tracker/features/history/presentation/cubit/history_cubit.dart';
import 'package:ble_proximity_tracker/features/radar/domain/usecases/track_device_proximity.dart';
import 'package:ble_proximity_tracker/features/radar/presentation/bloc/radar_bloc.dart';
import 'package:ble_proximity_tracker/features/scanner/domain/usecases/filter_nearby_devices.dart';
import 'package:ble_proximity_tracker/features/scanner/presentation/bloc/scanner_bloc.dart';
import 'package:ble_proximity_tracker/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:ble_proximity_tracker/features/settings/domain/repositories/settings_repository.dart';
import 'package:ble_proximity_tracker/features/settings/domain/usecases/theme_usecases.dart';
import 'package:ble_proximity_tracker/features/settings/presentation/cubit/theme_cubit.dart';

final sl = GetIt.instance;

typedef RadarArgs = ({
  String deviceId,
  ScannedDevice? lastKnown,
  String? knownName,
});

void configureDependencies() {
  sl.registerLazySingleton<Clock>(() => systemClock);

  sl
    ..registerLazySingleton<BleDataSource>(BleDataSource.new)
    ..registerLazySingleton<AppDatabase>(AppDatabase.new)
    ..registerLazySingleton<DeviceHistoryDao>(
      () => sl<AppDatabase>().deviceHistoryDao,
    );

  sl
    ..registerLazySingleton<BluetoothRepository>(
      () => BluetoothRepositoryImpl(sl(), sl()),
    )
    ..registerLazySingleton<HistoryRepository>(
      () => HistoryRepositoryImpl(sl()),
    )
    ..registerLazySingleton<SettingsRepository>(
      () => SettingsRepositoryImpl(SharedPreferencesAsync()),
    );

  sl
    ..registerLazySingleton(() => StartScan(sl(), sl()))
    ..registerLazySingleton(() => StopScan(sl()))
    ..registerLazySingleton(() => WatchAdvertisements(sl()))
    ..registerLazySingleton(() => WatchBluetoothStatus(sl()))
    ..registerLazySingleton(() => GetBluetoothStatus(sl()))
    ..registerLazySingleton(() => CheckScanPermission(sl()))
    ..registerLazySingleton(() => EnableBluetooth(sl()))
    ..registerLazySingleton(() => OpenAppSettings(sl()))
    ..registerLazySingleton(() => const FilterNearbyDevices())
    ..registerLazySingleton(() => RecordSightings(sl()))
    ..registerLazySingleton(() => WatchHistory(sl()))
    ..registerLazySingleton(() => ClearHistory(sl()))
    ..registerLazySingleton(() => GetThemePreference(sl()))
    ..registerLazySingleton(() => SaveThemePreference(sl()))
    ..registerFactory(() => TrackDeviceProximity(sl()));

  sl
    ..registerFactory(
      () => ScannerBloc(
        startScan: sl(),
        stopScan: sl(),
        watchAdvertisements: sl(),
        watchBluetoothStatus: sl(),
        getBluetoothStatus: sl(),
        checkScanPermission: sl(),
        enableBluetooth: sl(),
        openAppSettings: sl(),
        recordSightings: sl(),
        filterNearbyDevices: sl(),
        clock: sl(),
      ),
    )
    ..registerFactoryParam<RadarBloc, RadarArgs, void>(
      (args, _) => RadarBloc(
        deviceId: args.deviceId,
        lastKnown: args.lastKnown,
        knownName: args.knownName,
        trackProximity: sl(),
        clock: sl(),
      ),
    )
    ..registerFactory(
      () => HistoryCubit(watchHistory: sl(), clearHistory: sl()),
    )
    ..registerFactory(
      () => ThemeCubit(getThemePreference: sl(), saveThemePreference: sl()),
    );
}
