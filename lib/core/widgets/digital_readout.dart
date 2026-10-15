import 'package:flutter/material.dart';

import 'package:ble_proximity_tracker/core/theme/app_colors.dart';
import 'package:ble_proximity_tracker/core/theme/app_theme.dart';
import 'package:ble_proximity_tracker/core/widgets/neu.dart';

class LcdColors {
  const LcdColors._(this.face, this.ink, this.label, {required this.backlit});

  final Color face;
  final Color ink;

  final Color label;

  final bool backlit;

  static const _light = LcdColors._(
    AppColors.lightLcdFace,
    AppColors.lightLcdInk,
    AppColors.lightLcdLabel,
    backlit: false,
  );
  static const _dark = LcdColors._(
    AppColors.darkLcdFace,
    AppColors.darkLcdInk,
    AppColors.darkLcdLabel,
    backlit: true,
  );

  static LcdColors of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? _dark : _light;
}

class LcdPanel extends StatelessWidget {
  const LcdPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(12),
    this.radius = 14,
    this.depth = 3,
    this.minWidth = 0,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final double depth;

  final double minWidth;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: minWidth),
      child: NeuBox(
        inset: true,
        depth: depth,
        radius: radius,
        color: LcdColors.of(context).face,
        padding: padding,
        child: child,
      ),
    );
  }
}

class DigitalReadout extends StatelessWidget {
  const DigitalReadout(this.value, {super.key, this.unit, this.size = 24});

  final String value;
  final String? unit;
  final double size;

  static final _segmentChars = RegExp('[0-9-]');

  @override
  Widget build(BuildContext context) {
    final lcd = LcdColors.of(context);
    final style = TextStyle(
      fontFamily: AppTheme.digitalFontFamily,
      fontSize: size,
      fontWeight: FontWeight.w700,
      height: 1,
      color: lcd.ink,
      shadows: lcd.backlit
          ? [Shadow(color: lcd.ink.withValues(alpha: 0.45), blurRadius: 8)]
          : null,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Stack(
          alignment: Alignment.centerRight,
          children: [
            ExcludeSemantics(
              child: Text(
                value.replaceAll(_segmentChars, '8'),
                maxLines: 1,
                style: style.copyWith(
                  color: lcd.ink.withValues(alpha: 0.08),
                  shadows: const [],
                ),
              ),
            ),
            Text(value, maxLines: 1, style: style),
          ],
        ),
        if (unit != null) ...[
          SizedBox(width: size * 0.25),
          Text(
            unit!,
            maxLines: 1,
            style: Theme.of(context).textTheme.labelMedium
                ?.copyWith(color: lcd.label),
          ),
        ],
      ],
    );
  }
}
