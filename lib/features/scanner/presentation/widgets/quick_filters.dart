import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ble_proximity_tracker/core/widgets/neu.dart';

import '../../domain/entities/device_filter.dart';
import '../bloc/scanner_bloc.dart';

class QuickFilters extends StatelessWidget {
  const QuickFilters({super.key, required this.filter});

  final DeviceFilter filter;

  static const _thresholds = <int?>[null, -50, -70, -80];

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ScannerBloc>();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        spacing: 10,
        children: [
          for (final t in _thresholds)
            _FilterKey(
              label: t == null ? 'All signals' : '≥ $t dBm',
              selected: filter.minRssi == t,
              onTap: () => bloc.add(MinRssiChanged(t)),
            ),
          _FilterKey(
            label: 'Named only',
            selected: filter.namedOnly,
            onTap: () => bloc.add(NamedOnlyChanged(!filter.namedOnly)),
          ),
        ],
      ),
    );
  }
}

class _FilterKey extends StatelessWidget {
  const _FilterKey({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      container: true,
      selected: selected,
      button: true,
      child: NeuBox(
        inset: selected,
        depth: 3,
        radius: 12,
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
