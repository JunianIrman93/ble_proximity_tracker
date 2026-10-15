import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:ble_proximity_tracker/core/di/injection.dart';
import 'package:ble_proximity_tracker/core/router/app_router.dart';
import 'package:ble_proximity_tracker/core/utils/clock.dart';
import 'package:ble_proximity_tracker/core/utils/time_format.dart';
import 'package:ble_proximity_tracker/core/widgets/empty_view.dart';
import 'package:ble_proximity_tracker/core/widgets/neu.dart';
import 'package:ble_proximity_tracker/core/widgets/section_label.dart';

import '../../domain/entities/history_entry.dart';
import '../cubit/history_cubit.dart';
import '../widgets/history_tile.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HistoryCubit>()..load(),
      child: const _HistoryView(),
    );
  }
}

class _HistoryView extends StatelessWidget {
  const _HistoryView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HistoryCubit, HistoryState>(
      listenWhen: (p, c) => c.error != null && p.error != c.error,
      listener: (context, state) =>
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.error!))),
      builder: (context, state) {
        final entries = state.visibleEntries;
        return Scaffold(
          appBar: AppBar(
            title: const Text('History'),
            actions: [
              NeuIconButton(
                tooltip: 'Clear history',
                icon: const Icon(Icons.delete_outline),
                onPressed: state.entries.isEmpty
                    ? null
                    : () => _confirmClear(context),
              ),
              const SizedBox(width: 16),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                child: NeuBox(
                  inset: true,
                  depth: 4,
                  radius: 16,
                  child: TextField(
                    onChanged: context.read<HistoryCubit>().queryChanged,
                    textInputAction: TextInputAction.search,
                    decoration: const InputDecoration(
                      hintText: 'Search name or MAC address',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                  children: _content(context, state, entries),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _content(
    BuildContext context,
    HistoryState state,
    List<HistoryEntry> entries,
  ) {
    if (state.status == HistoryStatus.loading) {
      return const [
        EmptyView(
          icon: Icons.hourglass_empty,
          title: 'Loading history',
          message: 'Reading saved devices…',
        ),
      ];
    }
    if (state.status == HistoryStatus.failure && state.entries.isEmpty) {
      return [
        EmptyView(
          icon: Icons.error_outline,
          title: 'Could not load history',
          message: state.error ?? 'Unknown error',
        ),
      ];
    }
    if (entries.isEmpty) {
      return [
        state.entries.isEmpty
            ? const EmptyView(
                icon: Icons.history,
                title: 'No devices yet',
                message: 'Every device found while scanning is saved here.',
              )
            : const EmptyView(
                icon: Icons.search_off,
                title: 'No matches',
                message: 'Try another name or MAC address.',
              ),
      ];
    }

    final now = sl<Clock>()();
    final groups = <String, List<HistoryEntry>>{};
    for (final entry in entries) {
      groups
          .putIfAbsent(formatDayHeader(entry.lastSeen, now), () => [])
          .add(entry);
    }

    var groupIndex = 0;
    return [
      for (final MapEntry(key: day, value: items) in groups.entries) ...[
        TweenAnimationBuilder<double>(
          key: ValueKey<String>(day),
          duration: Duration(milliseconds: 320 + (groupIndex++ * 40)),
          curve: Curves.easeOutCubic,
          tween: Tween<double>(begin: 0.0, end: 1.0),
          builder: (context, value, child) => Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 12 * (1 - value)),
              child: child,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionLabel(day, trailing: Text('${items.length}')),
              for (final item in items) ...[
                HistoryTile(
                  entry: item,
                  now: now,
                  onTap: () =>
                      context.push(AppRoutes.radar(item.id), extra: item.name),
                ),
                const SizedBox(height: 14),
              ],
              const SizedBox(height: 10),
            ],
          ),
        ),
      ],
    ];
  }

  Future<void> _confirmClear(BuildContext context) async {
    final cubit = context.read<HistoryCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear history?'),
        content: const Text('All saved devices will be removed.'),
        actionsPadding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        actions: [
          NeuButton(
            compact: true,
            label: 'Cancel',
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            onPressed: () => Navigator.pop(context, false),
          ),
          const SizedBox(width: 8),
          NeuButton(
            compact: true,
            label: 'Clear',
            color: Theme.of(context).colorScheme.error,
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
    if (confirmed ?? false) await cubit.clear();
  }
}
