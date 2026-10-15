import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ble_proximity_tracker/core/bluetooth/domain/entities/bluetooth_status.dart';
import 'package:ble_proximity_tracker/core/signal/signal_zone.dart';
import 'package:ble_proximity_tracker/core/theme/app_colors.dart';
import 'package:ble_proximity_tracker/core/widgets/digital_readout.dart';
import 'package:ble_proximity_tracker/core/widgets/neu.dart';

import '../bloc/scanner_bloc.dart';

class ScanControlCard extends StatelessWidget {
  const ScanControlCard({super.key, required this.state});

  final ScannerState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final (label, dotColor) = _status(scheme);
    final strongest = state.strongest;

    return NeuBox(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: NeuBox(
              inset: true,
              depth: 2,
              radius: 12,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _StatusDot(color: dotColor, isPulsing: state.isScanning),
                  const SizedBox(width: 8),
                  Text(
                    label.toUpperCase(),
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _Stat(
                  label: 'Active devices',
                  value: '${state.devices.length}',
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _Stat(
                  label: 'Strongest signal',
                  value: strongest == null ? '--' : '${strongest.rssi}',
                  unit: 'dBm',
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          _ScanButton(state: state),
        ],
      ),
    );
  }

  (String, Color) _status(ColorScheme scheme) {
    if (state.isStarting) return ('Starting…', scheme.outline);
    if (state.isScanning) return ('Scanning', SignalZone.veryStrong.color);
    return switch (state.btStatus) {
      BluetoothStatus.off => ('Bluetooth off', scheme.error),
      BluetoothStatus.unsupported => ('BLE not supported', scheme.error),
      _ => ('Idle', scheme.outline),
    };
  }
}

class _StatusDot extends StatefulWidget {
  const _StatusDot({required this.color, required this.isPulsing});

  final Color color;
  final bool isPulsing;

  @override
  State<_StatusDot> createState() => _StatusDotState();
}

class _StatusDotState extends State<_StatusDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    if (widget.isPulsing) _controller.repeat();
  }

  @override
  void didUpdateWidget(_StatusDot old) {
    super.didUpdateWidget(old);
    if (widget.isPulsing != old.isPulsing) {
      if (widget.isPulsing) {
        _controller.repeat();
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 12,
      height: 12,
      child: Center(
        child: widget.isPulsing
            ? AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  final val = _controller.value;
                  final scale = 1.0 + 0.8 * val;
                  final alpha = (1.0 - val) * 0.45;
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: widget.color.withValues(alpha: alpha),
                          ),
                        ),
                      ),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: widget.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  );
                },
              )
            : Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: widget.color,
                  shape: BoxShape.circle,
                ),
              ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, this.unit});

  final String label;
  final String value;
  final String? unit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LcdPanel(
      depth: 4,
      radius: 16,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: LcdColors.of(context).label,
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: DigitalReadout(value, unit: unit, size: 26),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanButton extends StatelessWidget {
  const _ScanButton({required this.state});

  final ScannerState state;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ScannerBloc>();
    if (state.isStarting) {
      return const NeuButton(label: 'Starting…', onPressed: null);
    }
    if (state.isScanning) {
      return NeuButton(
        label: 'Stop scan',
        icon: Icons.stop_rounded,
        latched: true,
        color: Theme.of(context).colorScheme.error,
        onPressed: () => bloc.add(const ScanStopRequested()),
      );
    }
    return NeuButton(
      label: 'Start scan',
      icon: Icons.play_arrow_rounded,
      onPressed: state.btStatus == BluetoothStatus.unsupported
          ? null
          : () => bloc.add(const ScanStartRequested()),
    );
  }
}
