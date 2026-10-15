import 'package:flutter/material.dart';

import 'package:ble_proximity_tracker/core/signal/signal_zone.dart';
import 'package:ble_proximity_tracker/core/theme/app_colors.dart';
import 'package:ble_proximity_tracker/core/utils/time_format.dart';
import 'package:ble_proximity_tracker/core/widgets/digital_readout.dart';
import 'package:ble_proximity_tracker/core/widgets/neu.dart';

import '../../domain/entities/history_entry.dart';

class HistoryTile extends StatelessWidget {
  const HistoryTile({
    super.key,
    required this.entry,
    required this.now,
    this.onTap,
  });

  final HistoryEntry entry;
  final DateTime now;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final zone = SignalZone.fromRssi(entry.bestRssi);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );

    return NeuBox(
      onTap: onTap,
      radius: 18,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          NeuBox(
            inset: true,
            depth: 3,
            radius: 13,
            child: SizedBox.square(
              dimension: 42,
              child: Icon(Icons.bluetooth, size: 20, color: zone.color),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: entry.hasName ? null : scheme.onSurfaceVariant,
                  ),
                ),
                Text(entry.id, style: muted, maxLines: 1),
                Text(
                  'Last seen ${formatAgo(entry.lastSeen, now)} · '
                  'first ${formatDateTime(entry.firstSeen)}',
                  style: muted,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          LcdPanel(
            radius: 12,
            minWidth: 96,
            padding: const EdgeInsets.fromLTRB(10, 9, 10, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                DigitalReadout('${entry.lastRssi}', unit: 'dBm', size: 16),
                const SizedBox(height: 5),
                Text(
                  'best ${entry.bestRssi}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: LcdColors.of(context).label,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
