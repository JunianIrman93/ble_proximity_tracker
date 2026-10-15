import 'package:flutter/material.dart';

import 'package:ble_proximity_tracker/core/signal/signal_zone.dart';

class SignalChart extends StatelessWidget {
  const SignalChart({
    super.key,
    required this.samples,
    required this.capacity,
    required this.color,
  });

  final List<int> samples;
  final int capacity;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 120,
      width: double.infinity,
      child: TweenAnimationBuilder<Color?>(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOutCubic,
        tween: ColorTween(end: color),
        builder: (context, animatedColor, _) => CustomPaint(
          painter: _ChartPainter(
            samples: samples,
            capacity: capacity,
            lineColor: animatedColor ?? color,
            gridColor: scheme.outlineVariant,
          ),
        ),
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  _ChartPainter({
    required this.samples,
    required this.capacity,
    required this.lineColor,
    required this.gridColor,
  });

  final List<int> samples;
  final int capacity;
  final Color lineColor;
  final Color gridColor;

  static const _minDbm = -100.0;
  static const _maxDbm = -20.0;

  double _y(num dbm, Size size) {
    final v = dbm.clamp(_minDbm, _maxDbm).toDouble();
    return size.height * (1 - (v - _minDbm) / (_maxDbm - _minDbm));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (final zone in SignalZone.values) {
      final bound = zone.lowerBoundDbm;
      if (bound == null) continue;
      final y = _y(bound, size);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    if (samples.length < 2 || capacity < 2) return;
    final offset = capacity - samples.length;
    final path = Path();
    for (var i = 0; i < samples.length; i++) {
      final x = size.width * (i + offset) / (capacity - 1);
      final y = _y(samples[i], size);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }

    final startX = size.width * offset / (capacity - 1);
    final endX = size.width;
    final fillPath = Path.from(path)
      ..lineTo(endX, size.height)
      ..lineTo(startX, size.height)
      ..close();
    canvas.drawPath(
      fillPath,
      Paint()..color = lineColor.withValues(alpha: 0.08),
    );

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round
        ..color = lineColor,
    );
  }

  @override
  bool shouldRepaint(_ChartPainter old) =>
      old.samples != samples ||
      old.lineColor != lineColor ||
      old.gridColor != gridColor;
}
