import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:ble_proximity_tracker/core/widgets/app_shell.dart';
import 'package:ble_proximity_tracker/features/history/presentation/pages/history_page.dart';
import 'package:ble_proximity_tracker/features/radar/presentation/pages/radar_page.dart';
import 'package:ble_proximity_tracker/features/scanner/presentation/pages/scanner_page.dart';
import 'package:ble_proximity_tracker/features/settings/presentation/pages/settings_page.dart';

abstract final class AppRoutes {
  static const scan = '/scan';
  static const history = '/history';
  static const settings = '/settings';

  static String radar(String deviceId) =>
      '/radar/${Uri.encodeComponent(deviceId)}';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.scan,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => AppShell(shell: shell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.scan,
              builder: (context, state) => const ScannerPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.history,
              builder: (context, state) => const HistoryPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.settings,
              builder: (context, state) => const SettingsPage(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/radar/:id',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: RadarPage(
          deviceId: state.pathParameters['id']!,
          knownName: state.extra is String ? state.extra! as String : null,
        ),
        transitionDuration: const Duration(milliseconds: 360),
        reverseTransitionDuration: const Duration(milliseconds: 280),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curve = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          return FadeTransition(
            opacity: curve,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.05),
                end: Offset.zero,
              ).animate(curve),
              child: child,
            ),
          );
        },
      ),
    ),
  ],
  errorBuilder: (context, state) =>
      const Scaffold(body: Center(child: Text('Page not found'))),
);
