import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ble_proximity_tracker/core/signal/signal_zone.dart';
import 'package:ble_proximity_tracker/core/widgets/neu.dart';

import '../bloc/scanner_bloc.dart';

Future<void> showFilterSheet(BuildContext context) {
  final bloc = context.read<ScannerBloc>();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => BlocProvider.value(value: bloc, child: const FilterSheet()),
  );
}

class FilterSheet extends StatelessWidget {
  const FilterSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bloc = context.read<ScannerBloc>();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: BlocBuilder<ScannerBloc, ScannerState>(
          buildWhen: (p, c) => p.filter != c.filter,
          builder: (context, state) {
            final filter = state.filter;
            final minRssi = filter.minRssi;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Filters', style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Minimum signal'),
                  subtitle: Text(
                    minRssi == null
                        ? 'Showing every device'
                        : '≥ $minRssi dBm · '
                              '${SignalZone.fromRssi(minRssi).label} or stronger',
                  ),
                  value: minRssi != null,
                  onChanged: (on) => bloc.add(MinRssiChanged(on ? -80 : null)),
                ),
                if (minRssi != null)
                  Slider(
                    value: minRssi.toDouble(),
                    min: -100,
                    max: -30,
                    divisions: 70,
                    label: '$minRssi dBm',
                    onChanged: (v) => bloc.add(MinRssiChanged(v.round())),
                  ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Named devices only'),
                  subtitle: const Text('Hide devices without a broadcast name'),
                  value: filter.namedOnly,
                  onChanged: (v) => bloc.add(NamedOnlyChanged(v)),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: NeuButton(
                        label: 'Reset',
                        color: theme.colorScheme.onSurfaceVariant,
                        onPressed: filter.hasSignalOrNameFilter
                            ? () => bloc.add(const FiltersCleared())
                            : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: NeuButton(
                        label: 'Done',
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
