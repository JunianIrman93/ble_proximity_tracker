import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ble_proximity_tracker/core/signal/signal_zone.dart';
import 'package:ble_proximity_tracker/core/theme/app_colors.dart';
import 'package:ble_proximity_tracker/core/widgets/neu.dart';
import 'package:ble_proximity_tracker/core/widgets/section_label.dart';

import '../../domain/entities/theme_preference.dart';
import '../cubit/theme_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static const _themeOptions = [
    (ThemePreference.dark, Icons.dark_mode_outlined, 'Dark'),
    (ThemePreference.light, Icons.light_mode_outlined, 'Light'),
    (ThemePreference.system, Icons.phone_android_outlined, 'System'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          const SectionLabel('Appearance'),
          NeuBox(
            padding: const EdgeInsets.all(14),
            child: BlocBuilder<ThemeCubit, ThemePreference>(
              builder: (context, preference) => Row(
                children: [
                  for (final (i, (value, icon, label))
                      in _themeOptions.indexed) ...[
                    if (i > 0) const SizedBox(width: 12),
                    Expanded(
                      child: _ThemeOption(
                        icon: icon,
                        label: label,
                        selected: preference == value,
                        onTap: () => context.read<ThemeCubit>().select(value),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          const SectionLabel('Signal zones'),
          NeuBox(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              children: [
                for (final zone in SignalZone.values) ...[
                  if (zone != SignalZone.values.first)
                    const Divider(indent: 52, endIndent: 16),
                  ListTile(
                    dense: true,
                    leading: NeuBox(
                      circle: true,
                      inset: true,
                      depth: 2,
                      padding: const EdgeInsets.all(3),
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: zone.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    minLeadingWidth: 16,
                    title: Text(zone.label, style: theme.textTheme.titleSmall),
                    subtitle: Text(zone.dbmRange, style: muted),
                    trailing: Text(
                      zone.distanceRange,
                      style: theme.textTheme.labelMedium,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 28),
          const SectionLabel('Distance estimate'),
          NeuBox(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Distance uses the log-distance path loss model '
              'd = 10^((A − RSSI) / 10n) with A = $kMeasuredPowerDbm dBm and '
              'n = $kPathLossExponent, calibrated to the zone table above. '
              'RSSI is smoothed and zones change only after a 3 dB margin '
              'to avoid flicker.',
              style: muted,
            ),
          ),
          const SizedBox(height: 28),
          Center(child: Text('BLE Proximity Tracker · v1.0.0', style: muted)),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
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
      container: true,
      selected: selected,
      button: true,
      child: NeuBox(
        inset: selected,
        depth: 4,
        radius: 14,
        onTap: onTap,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 4),
            Text(
              label.toUpperCase(),
              style: theme.textTheme.labelMedium?.copyWith(
                color: color,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
