import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ble_proximity_tracker/core/di/injection.dart';
import 'package:ble_proximity_tracker/core/router/app_router.dart';
import 'package:ble_proximity_tracker/core/theme/app_theme.dart';
import 'package:ble_proximity_tracker/features/scanner/presentation/bloc/scanner_bloc.dart';
import 'package:ble_proximity_tracker/features/settings/domain/entities/theme_preference.dart';
import 'package:ble_proximity_tracker/features/settings/presentation/cubit/theme_cubit.dart';

class BleTrackerApp extends StatelessWidget {
  const BleTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<ScannerBloc>()..add(const ScannerStarted()),
        ),
        BlocProvider(create: (_) => sl<ThemeCubit>()..load()),
      ],
      child: const _LifecycleBridge(child: _ThemedApp()),
    );
  }
}

class _ThemedApp extends StatelessWidget {
  const _ThemedApp();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemePreference>(
      builder: (context, preference) => MaterialApp.router(
        title: 'BLE Proximity',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: preference.themeMode,
        routerConfig: appRouter,
        builder: (context, child) {
          final theme = Theme.of(context);
          final dark = theme.brightness == Brightness.dark;
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value:
                (dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
                    .copyWith(
                      statusBarColor: Colors.transparent,
                      systemNavigationBarColor: theme.colorScheme.surface,
                      systemNavigationBarDividerColor:
                          theme.colorScheme.surface,
                    ),
            child: child!,
          );
        },
      ),
    );
  }
}

class _LifecycleBridge extends StatefulWidget {
  const _LifecycleBridge({required this.child});

  final Widget child;

  @override
  State<_LifecycleBridge> createState() => _LifecycleBridgeState();
}

class _LifecycleBridgeState extends State<_LifecycleBridge> {
  late final AppLifecycleListener _listener;

  @override
  void initState() {
    super.initState();
    _listener = AppLifecycleListener(
      onStateChange: (state) =>
          context.read<ScannerBloc>().add(AppLifecycleChanged(state)),
    );
  }

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
