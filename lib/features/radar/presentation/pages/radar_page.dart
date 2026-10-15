import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ble_proximity_tracker/core/bluetooth/domain/entities/bluetooth_status.dart';
import 'package:ble_proximity_tracker/core/di/injection.dart';
import 'package:ble_proximity_tracker/core/signal/signal_zone.dart';
import 'package:ble_proximity_tracker/core/theme/app_colors.dart';
import 'package:ble_proximity_tracker/core/widgets/digital_readout.dart';
import 'package:ble_proximity_tracker/core/widgets/neu.dart';
import 'package:ble_proximity_tracker/core/widgets/section_label.dart';
import 'package:ble_proximity_tracker/core/widgets/zone_pill.dart';
import 'package:ble_proximity_tracker/features/scanner/presentation/bloc/scanner_bloc.dart';

import '../bloc/radar_bloc.dart';
import '../widgets/radar_view.dart';
import '../widgets/signal_chart.dart';
import '../widgets/zone_scale.dart';

class RadarPage extends StatelessWidget {
  const RadarPage({super.key, required this.deviceId, this.knownName});

  final String deviceId;
  final String? knownName;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final scanner = context.read<ScannerBloc>();
        if (!scanner.state.isScanning) scanner.add(const ScanStartRequested());
        return sl<RadarBloc>(
          param1: (
            deviceId: deviceId,
            lastKnown: scanner.state.devices[deviceId],
            knownName: knownName,
          ),
        )..add(const RadarStarted());
      },
      child: const _RadarView(),
    );
  }
}

class _RadarView extends StatelessWidget {
  const _RadarView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RadarBloc, RadarState>(
      builder: (context, state) => Scaffold(
        appBar: AppBar(
          leadingWidth: 72,
          leading: Center(
            child: NeuIconButton(
              tooltip: 'Back',
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.maybePop(context),
            ),
          ),
          title: Text(state.displayName),
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final details = _Details(state: state);
              const banner = _ScanPausedBanner();

              if (constraints.maxWidth > constraints.maxHeight) {
                return Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 8, 16),
                        child: NeuBox(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Expanded(
                                child: Center(child: _RadarDish(state: state)),
                              ),
                              const SizedBox(height: 16),
                              ZoneScale(current: state.snapshot.zone),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(8, 8, 16, 16),
                        children: [
                          banner,
                          NeuBox(
                            padding: const EdgeInsets.all(20),
                            child: _DistanceSection(state: state),
                          ),
                          const SizedBox(height: 28),
                          details,
                        ],
                      ),
                    ),
                  ],
                );
              }
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  banner,
                  _RadarCard(state: state),
                  const SizedBox(height: 28),
                  details,
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _RadarCard extends StatelessWidget {
  const _RadarCard({required this.state});

  final RadarState state;

  @override
  Widget build(BuildContext context) {
    return NeuBox(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DistanceSection(state: state),
          const SizedBox(height: 24),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: _RadarDish(state: state),
            ),
          ),
          const SizedBox(height: 24),
          ZoneScale(current: state.snapshot.zone),
        ],
      ),
    );
  }
}

class _DistanceSection extends StatelessWidget {
  const _DistanceSection({required this.state});

  final RadarState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final snapshot = state.snapshot;
    final zone = snapshot.zone;
    final distance = snapshot.distanceMeters;
    final lost = snapshot.isLost || distance == null;
    final lcd = LcdColors.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            ZonePill(zone),
            const Spacer(),
            Text(
              zone == SignalZone.lost
                  ? zone.proximity
                  : '${zone.proximity} · ${zone.distanceRange}',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        LcdPanel(
          depth: 4,
          radius: 16,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                lost
                    ? 'Move closer or check that the device is on.'
                    : 'Estimated distance',
                style: theme.textTheme.labelSmall?.copyWith(color: lcd.label),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: lost
                    ? Text(
                        'SIGNAL LOST',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: lcd.ink,
                          letterSpacing: 2,
                        ),
                      )
                    : _DistanceReadout(meters: distance),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RadarDish extends StatelessWidget {
  const _RadarDish({required this.state});

  final RadarState state;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: NeuBox(
        circle: true,
        depth: 8,
        padding: const EdgeInsets.all(12),
        child: NeuBox(
          circle: true,
          inset: true,
          depth: 6,
          padding: const EdgeInsets.all(6),
          child: RadarView(
            zone: state.snapshot.zone,
            distanceMeters: state.snapshot.distanceMeters,
          ),
        ),
      ),
    );
  }
}

class _DistanceReadout extends StatelessWidget {
  const _DistanceReadout({required this.meters});

  final double meters;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final [value, unit] = formatDistance(meters).split(' ');
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          '≈ ',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: LcdColors.of(context).label,
          ),
        ),
        DigitalReadout(value, unit: unit, size: 36),
      ],
    );
  }
}

class _Details extends StatelessWidget {
  const _Details({required this.state});

  final RadarState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = state.snapshot;
    final stability = s.stabilityDb;
    final since = state.sinceLastSeen;

    final metrics = [
      _Metric('Raw RSSI', s.rawRssi?.toString(), unit: 'dBm'),
      _Metric('Smoothed', s.smoothedRssi?.toStringAsFixed(1), unit: 'dBm'),
      _Metric('Last seen', since?.inSeconds.toString(), unit: 's ago'),
      _Metric(
        stability == null
            ? 'Stability'
            : 'Stability · ${_stabilityLabel(stability)}',
        stability?.toStringAsFixed(1),
        unit: '±dB',
      ),
      _Metric('Zone range', s.zone.dbmRange, digital: false),
      _Metric('Packets', '${s.sampleCount}'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel('Connection'),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          clipBehavior: Clip.none,
          childAspectRatio: 2.2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          children: [for (final m in metrics) _MetricTile(metric: m)],
        ),
        const SizedBox(height: 28),
        const SectionLabel('Signal history'),
        NeuBox(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NeuBox(
                inset: true,
                depth: 4,
                radius: 14,
                padding: const EdgeInsets.all(12),
                child: SignalChart(
                  samples: s.samples,
                  capacity: 60,
                  color: s.zone.color,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Last 60 readings · lines mark zone boundaries',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        const SectionLabel('Device'),
        NeuBox(
          child: ListTile(
            contentPadding: const EdgeInsets.fromLTRB(16, 6, 12, 6),
            title: const Text('Identifier'),
            subtitle: SelectableText(state.deviceId),
            trailing: NeuIconButton(
              tooltip: 'Copy',
              size: 40,
              icon: const Icon(Icons.copy_rounded),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: state.deviceId));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Identifier copied')),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Distance is an estimate. Walls, people and phone orientation '
          'shift RSSI by several dB.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  static String _stabilityLabel(double db) => switch (db) {
    < 3 => 'stable',
    < 6 => 'moderate',
    _ => 'unstable',
  };
}

class _Metric {
  const _Metric(this.label, this.value, {this.unit, this.digital = true});

  final String label;

  final String? value;
  final String? unit;

  final bool digital;
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.metric});

  final _Metric metric;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lcd = LcdColors.of(context);
    final value = metric.value ?? '--';
    return LcdPanel(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            metric.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(color: lcd.label),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: metric.digital
                  ? DigitalReadout(value, unit: metric.unit, size: 18)
                  : Text(
                      value,
                      maxLines: 1,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: lcd.ink,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanPausedBanner extends StatelessWidget {
  const _ScanPausedBanner();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScannerBloc, ScannerState>(
      buildWhen: (p, c) =>
          p.isScanning != c.isScanning ||
          p.isStarting != c.isStarting ||
          p.btStatus != c.btStatus,
      builder: (context, state) {
        if (state.isScanning || state.isStarting) {
          return const SizedBox.shrink();
        }
        final theme = Theme.of(context);
        final btOff = state.btStatus == BluetoothStatus.off;
        final bloc = context.read<ScannerBloc>();
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: NeuBox(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                NeuBox(
                  circle: true,
                  inset: true,
                  depth: 3,
                  child: SizedBox.square(
                    dimension: 40,
                    child: Icon(
                      btOff
                          ? Icons.bluetooth_disabled
                          : Icons.pause_circle_outline,
                      size: 20,
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    btOff ? 'Bluetooth is off. Live tracking is paused.' : 'Scanning is paused. Live tracking needs an active scan.',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                const SizedBox(width: 12),
                NeuButton(
                  compact: true,
                  label: btOff ? 'Turn on' : 'Resume',
                  onPressed: () => bloc.add(
                    btOff
                        ? const BluetoothEnableRequested()
                        : const ScanStartRequested(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
