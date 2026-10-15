import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:ble_proximity_tracker/core/signal/signal_zone.dart';
import 'package:ble_proximity_tracker/core/theme/app_colors.dart';
import 'package:ble_proximity_tracker/core/theme/app_theme.dart';
import 'package:ble_proximity_tracker/core/widgets/neu.dart';

class RadarView extends StatefulWidget {
  const RadarView({super.key, required this.zone, this.distanceMeters});

  final SignalZone zone;
  final double? distanceMeters;

  @override
  State<RadarView> createState() => _RadarViewState();
}

class _RadarViewState extends State<RadarView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = NeuPalette.of(context);
    final targetFraction = radarFraction(widget.zone, widget.distanceMeters);

    return AspectRatio(
      aspectRatio: 1,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeOutCubic,
            tween: Tween<double>(end: targetFraction),
            builder: (context, smoothFraction, _) {
              return CustomPaint(
                painter: _RadarPainter(
                  zone: widget.zone,
                  fraction: smoothFraction,
                  sweepAngle: _controller.value * 2 * math.pi,
                  pulseFraction: _controller.value,
                  palette: palette,
                  labelColor: scheme.onSurfaceVariant,
                  centerColor: scheme.primary,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

const _bandEdgesMeters = [0.0, 1.0, 3.0, 10.0, 20.0, 40.0];
const _bandLabels = ['1 m', '3 m', '10 m', '20 m', ''];
const _bandCount = 5;

double radarFraction(SignalZone zone, double? meters) {
  if (zone == SignalZone.lost || meters == null) return 1;
  var fraction = 1.0;
  for (var i = 0; i < _bandCount; i++) {
    final lo = _bandEdgesMeters[i];
    final hi = _bandEdgesMeters[i + 1];
    if (meters <= hi) {
      fraction = (i + (meters - lo) / (hi - lo)) / _bandCount;
      break;
    }
  }
  const inset = 0.03;
  final start = zone.index / _bandCount + inset;
  final end = (zone.index + 1) / _bandCount - inset;
  return fraction.clamp(start, end).toDouble();
}

class _RadarPainter extends CustomPainter {
  _RadarPainter({
    required this.zone,
    required this.fraction,
    required this.sweepAngle,
    required this.pulseFraction,
    required this.palette,
    required this.labelColor,
    required this.centerColor,
  });

  final SignalZone zone;
  final double fraction;
  final double sweepAngle;
  final double pulseFraction;
  final NeuPalette palette;
  final Color labelColor;
  final Color centerColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final maxR = size.shortestSide / 2 - 4;
    final isLost = zone == SignalZone.lost;

    if (!isLost) {
      final band = Path()
        ..fillType = PathFillType.evenOdd
        ..addOval(
          Rect.fromCircle(
            center: center,
            radius: maxR * (zone.index + 1) / _bandCount,
          ),
        )
        ..addOval(
          Rect.fromCircle(
            center: center,
            radius: maxR * zone.index / _bandCount,
          ),
        );
      canvas.drawPath(
        band,
        Paint()..color = zone.color.withValues(alpha: 0.14),
      );
    }

    for (final (color, shift) in [
      (palette.highlight, const Offset(1, 1)),
      (palette.shadow, Offset.zero),
    ]) {
      final line = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = color;
      final c = center + shift;
      for (var i = 1; i < _bandCount; i++) {
        canvas.drawCircle(c, maxR * i / _bandCount, line);
      }
      canvas
        ..drawLine(c - Offset(maxR, 0), c + Offset(maxR, 0), line)
        ..drawLine(c - Offset(0, maxR), c + Offset(0, maxR), line);
    }

    if (!isLost) {
      final rippleR = maxR * pulseFraction;
      final rippleAlpha = (1.0 - pulseFraction) * 0.16;
      canvas.drawCircle(
        center,
        rippleR,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = zone.color.withValues(alpha: rippleAlpha),
      );

      final sweepRect = Rect.fromCircle(center: center, radius: maxR);
      final sweepPaint = Paint()
        ..shader = SweepGradient(
          center: Alignment.center,
          startAngle: 0,
          endAngle: math.pi / 2,
          colors: [zone.color.withValues(alpha: 0.08), Colors.transparent],
          transform: GradientRotation(sweepAngle - math.pi / 2),
        ).createShader(sweepRect);
      canvas.drawCircle(center, maxR, sweepPaint);
    }

    for (var i = 0; i < _bandCount; i++) {
      final label = _bandLabels[i];
      if (label.isEmpty) continue;
      final r = maxR * (i + 1) / _bandCount;
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 10,
            color: labelColor,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, center + Offset(6, -r + 3));
      tp.dispose();
    }

    _raisedDot(canvas, center, 9, palette.base);
    canvas.drawCircle(center, 3.5, Paint()..color = centerColor);

    if (isLost) {
      final lostAlpha = 0.25 + 0.35 * (0.5 + 0.5 * math.sin(sweepAngle * 2));
      canvas.drawCircle(
        center,
        maxR,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = zone.color.withValues(alpha: lostAlpha),
      );
      return;
    }

    const angle = -math.pi / 4;
    final r = maxR * fraction;
    final target = center + Offset(math.cos(angle) * r, math.sin(angle) * r);
    final haloRadius = 12.0 + 2.2 * math.sin(sweepAngle * 2);

    canvas.drawCircle(
      target,
      haloRadius,
      Paint()..color = zone.color.withValues(alpha: 0.18),
    );
    _raisedDot(canvas, target, 6.5, zone.color);
    canvas.drawCircle(
      target + const Offset(-2, -2),
      1.8,
      Paint()..color = Colors.white.withValues(alpha: 0.8),
    );
  }

  void _raisedDot(Canvas canvas, Offset c, double r, Color face) {
    final blur = MaskFilter.blur(
      BlurStyle.normal,
      Shadow.convertRadiusToSigma(4),
    );
    canvas
      ..drawCircle(
        c + const Offset(2, 2),
        r,
        Paint()
          ..color = palette.shadow
          ..maskFilter = blur,
      )
      ..drawCircle(
        c - const Offset(2, 2),
        r,
        Paint()
          ..color = palette.highlight
          ..maskFilter = blur,
      )
      ..drawCircle(c, r, Paint()..color = face);
  }

  @override
  bool shouldRepaint(_RadarPainter old) =>
      old.zone != zone ||
      old.fraction != fraction ||
      old.sweepAngle != sweepAngle ||
      old.pulseFraction != pulseFraction ||
      old.palette != palette ||
      old.labelColor != labelColor ||
      old.centerColor != centerColor;
}
