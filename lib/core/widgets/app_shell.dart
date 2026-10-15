import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'neu.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  static const _destinations = [
    (Icons.bluetooth_searching, 'Scan'),
    (Icons.history, 'History'),
    (Icons.tune, 'Settings'),
  ];

  List<Widget> _items() => [
    for (final (i, (icon, label)) in _destinations.indexed)
      _NavItem(
        icon: icon,
        label: label,
        selected: i == shell.currentIndex,
        onTap: () =>
            shell.goBranch(i, initialLocation: i == shell.currentIndex),
      ),
  ];

  @override
  Widget build(BuildContext context) {
    final landscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;

    return Scaffold(
      body: Row(
        children: [
          if (landscape)
            SafeArea(
              right: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
                child: NeuBox(
                  radius: 24,
                  padding: const EdgeInsets.all(8),
                  child: SizedBox(
                    width: 84,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 8,
                      children: _items(),
                    ),
                  ),
                ),
              ),
            ),
          Expanded(key: const ValueKey('content'), child: shell),
        ],
      ),
      bottomNavigationBar: landscape
          ? null
          : SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: NeuBox(
                  radius: 24,
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      for (final item in _items()) Expanded(child: item),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = selected
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurfaceVariant;

    return Semantics(
      selected: selected,
      button: true,
      child: NeuBox(
        inset: selected,
        depth: selected ? 4 : 0,
        radius: 18,
        onTap: onTap,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 3),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
