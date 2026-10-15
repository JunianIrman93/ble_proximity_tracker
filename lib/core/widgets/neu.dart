import 'package:flutter/material.dart';

import 'package:ble_proximity_tracker/core/theme/app_colors.dart';

class NeuPalette {
  const NeuPalette._(this.base, this.highlight, this.shadow);

  final Color base;
  final Color highlight;
  final Color shadow;

  static const _dark = NeuPalette._(
    AppColors.darkBase,
    AppColors.darkHighlight,
    AppColors.darkShadow,
  );
  static const _light = NeuPalette._(
    AppColors.lightBase,
    AppColors.lightHighlight,
    AppColors.lightShadow,
  );

  static NeuPalette of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? _dark : _light;
}

class NeuBox extends StatefulWidget {
  const NeuBox({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.radius = 20,
    this.circle = false,
    this.inset = false,
    this.depth = 6,
    this.color,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final bool circle;

  final bool inset;

  final double depth;

  final Color? color;
  final VoidCallback? onTap;

  @override
  State<NeuBox> createState() => _NeuBoxState();
}

class _NeuBoxState extends State<NeuBox> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final palette = NeuPalette.of(context);
    final shape = widget.circle
        ? const CircleBorder()
        : RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(widget.radius),
          );

    Widget content = widget.padding == null
        ? widget.child
        : Padding(padding: widget.padding!, child: widget.child);

    if (widget.onTap != null) {
      content = Material(
        type: MaterialType.transparency,
        child: InkWell(
          customBorder: shape,
          onTap: widget.onTap,
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          onHighlightChanged: (v) => setState(() => _pressed = v),
          child: content,
        ),
      );
    }

    final box = TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOut,
      tween: Tween(end: widget.inset || _pressed ? 1 : 0),
      builder: (context, t, child) => CustomPaint(
        painter: _NeuPainter(
          t: t,
          depth: widget.depth,
          radius: widget.radius,
          circle: widget.circle,
          color: widget.color ?? palette.base,
          highlight: palette.highlight,
          shadow: palette.shadow,
        ),
        child: child,
      ),
      child: content,
    );

    return widget.margin == null
        ? box
        : Padding(padding: widget.margin!, child: box);
  }
}

class _NeuPainter extends CustomPainter {
  _NeuPainter({
    required this.t,
    required this.depth,
    required this.radius,
    required this.circle,
    required this.color,
    required this.highlight,
    required this.shadow,
  });

  final double t;
  final double depth;
  final double radius;
  final bool circle;
  final Color color;
  final Color highlight;
  final Color shadow;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(circle ? size.shortestSide / 2 : radius),
    );
    final outer = depth * (1 - t);
    final inner = depth * t;

    if (outer > 0.1) {
      final blur = _blur(outer * 2);
      canvas
        ..drawRRect(
          rrect.shift(Offset(outer, outer)),
          Paint()
            ..color = shadow
            ..maskFilter = blur,
        )
        ..drawRRect(
          rrect.shift(Offset(-outer, -outer)),
          Paint()
            ..color = highlight
            ..maskFilter = blur,
        );
    }

    canvas.drawRRect(rrect, Paint()..color = color);

    if (inner > 0.1) {
      canvas
        ..save()
        ..clipRRect(rrect);
      _innerShadow(canvas, rrect, shadow, Offset(inner, inner));
      _innerShadow(canvas, rrect, highlight, Offset(-inner, -inner));
      canvas.restore();
    }
  }

  void _innerShadow(Canvas canvas, RRect rrect, Color color, Offset offset) {
    final spread = offset.distance * 4;
    final frame = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(rrect.outerRect.inflate(spread))
      ..addRRect(rrect.shift(offset));
    canvas.drawPath(
      frame,
      Paint()
        ..color = color
        ..maskFilter = _blur(offset.dx.abs() * 2),
    );
  }

  static MaskFilter _blur(double radius) =>
      MaskFilter.blur(BlurStyle.normal, Shadow.convertRadiusToSigma(radius));

  @override
  bool shouldRepaint(_NeuPainter old) =>
      old.t != t ||
      old.depth != depth ||
      old.radius != radius ||
      old.circle != circle ||
      old.color != color ||
      old.highlight != highlight ||
      old.shadow != shadow;
}

class NeuButton extends StatelessWidget {
  const NeuButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.latched = false,
    this.compact = false,
    this.color,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool latched;
  final bool compact;

  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = onPressed != null;
    final fg = enabled
        ? color ?? theme.colorScheme.primary
        : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5);

    return Semantics(
      button: true,
      enabled: enabled,
      toggled: latched ? true : null,
      child: NeuBox(
        onTap: onPressed,
        inset: latched,
        depth: enabled ? (compact ? 4 : 6) : 0,
        radius: compact ? 12 : 16,
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 14 : 20,
          vertical: compact ? 9 : 16,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: compact ? 18 : 22, color: fg),
              const SizedBox(width: 8),
            ],
            Text(
              label.toUpperCase(),
              style:
                  (compact
                          ? theme.textTheme.labelMedium
                          : theme.textTheme.labelLarge)
                      ?.copyWith(color: fg, letterSpacing: 1.2),
            ),
          ],
        ),
      ),
    );
  }
}

class NeuIconButton extends StatelessWidget {
  const NeuIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.size = 44,
  });

  final Widget icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final enabled = onPressed != null;
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        enabled: enabled,
        child: NeuBox(
          circle: true,
          depth: enabled ? 4 : 0,
          onTap: onPressed,
          child: SizedBox.square(
            dimension: size,
            child: IconTheme(
              data: IconThemeData(
                size: 20,
                color: enabled
                    ? scheme.onSurface
                    : scheme.onSurfaceVariant.withValues(alpha: 0.4),
              ),
              child: Center(child: icon),
            ),
          ),
        ),
      ),
    );
  }
}
