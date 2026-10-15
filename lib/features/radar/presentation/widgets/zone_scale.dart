import 'package:flutter/material.dart';

import 'package:ble_proximity_tracker/core/signal/signal_zone.dart';
import 'package:ble_proximity_tracker/core/theme/app_colors.dart';
import 'package:ble_proximity_tracker/core/widgets/neu.dart';

class ZoneScale extends StatelessWidget {
  const ZoneScale({super.key, required this.current});

  final SignalZone current;

  static const _zones = [
    SignalZone.veryStrong,
    SignalZone.strong,
    SignalZone.fair,
    SignalZone.weak,
    SignalZone.veryWeak,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final caption = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Column(
      children: [
        Row(
          children: [
            for (final zone in _zones) ...[
              Expanded(
                child: NeuBox(
                  inset: true,
                  depth: 2,
                  radius: 6,
                  padding: const EdgeInsets.all(2.5),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeInOutCubic,
                    height: 7,
                    decoration: BoxDecoration(
                      color: zone == current ? zone.color : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              if (zone != _zones.last) const SizedBox(width: 8),
            ],
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Very close', style: caption),
            Text('Edge of range', style: caption),
          ],
        ),
      ],
    );
  }
}
