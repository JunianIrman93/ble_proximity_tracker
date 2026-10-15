import 'package:flutter/material.dart';

import 'package:ble_proximity_tracker/core/signal/signal_zone.dart';
import 'package:ble_proximity_tracker/core/theme/app_colors.dart';
import 'package:ble_proximity_tracker/core/widgets/neu.dart';

class ZonePill extends StatelessWidget {
  const ZonePill(this.zone, {super.key});

  final SignalZone zone;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return NeuBox(
      inset: true,
      depth: 2,
      radius: 10,
      padding: const EdgeInsets.fromLTRB(8, 4, 10, 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 320),
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: zone.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            zone.label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: zone.textColor(brightness),
            ),
          ),
        ],
      ),
    );
  }
}

class SignalMeter extends StatelessWidget {
  const SignalMeter({super.key, required this.rssi, this.height = 10});

  final int rssi;
  final double height;

  @override
  Widget build(BuildContext context) {
    final zone = SignalZone.fromRssi(rssi);
    final inner = height - 4;

    return NeuBox(
      inset: true,
      depth: 2,
      radius: height / 2,
      padding: const EdgeInsets.all(2),
      child: SizedBox(
        height: inner,
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 360),
          curve: Curves.easeOutCubic,
          tween: Tween(end: signalStrengthFraction(rssi)),
          builder: (context, fraction, _) => FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: fraction.clamp(0.0, 1.0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 360),
              decoration: BoxDecoration(
                color: zone.color,
                borderRadius: BorderRadius.circular(inner / 2),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
