import 'package:flutter/material.dart';

import 'package:ble_proximity_tracker/core/signal/signal_zone.dart';

abstract final class AppColors {
  static const darkBase = Color(0xFF2A2E35);
  static const darkHighlight = Color(0x2EFFFFFF);
  static const darkShadow = Color(0xB3121417);
  static const darkOnSurface = Color(0xFFE4E8EE);
  static const darkOnSurfaceVariant = Color(0xFF9BA4B1);
  static const darkOutline = Color(0xFF4A515C);
  static const darkPrimary = Color(0xFF7FA8D4);
  static const darkOnPrimary = Color(0xFF13263A);
  static const darkError = Color(0xFFE07A72);

  static const lightBase = Color(0xFFE0E5EC);
  static const lightHighlight = Color(0xE6FFFFFF);
  static const lightShadow = Color(0xB3A3B1C6);
  static const lightOnSurface = Color(0xFF2E3640);
  static const lightOnSurfaceVariant = Color(0xFF5B6573);
  static const lightOutline = Color(0xFFB4BECC);
  static const lightPrimary = Color(0xFF2F5F8F);
  static const lightOnPrimary = Color(0xFFFFFFFF);
  static const lightError = Color(0xFFA83A34);

  static const lightLcdFace = Color(0xFFC5D0B0);
  static const lightLcdInk = Color(0xFF1E2A1A);
  static const lightLcdLabel = Color(0xFF4A5A40);
  static const darkLcdFace = Color(0xFF141B16);
  static const darkLcdInk = Color(0xFF8FD58A);
  static const darkLcdLabel = Color(0xFF6E9A68);

  static Color zone(SignalZone zone) => switch (zone) {
    SignalZone.veryStrong => const Color(0xFF2D7F55),
    SignalZone.strong => const Color(0xFF5B9A68),
    SignalZone.fair => const Color(0xFFD49A3D),
    SignalZone.weak => const Color(0xFFCC6B3B),
    SignalZone.veryWeak => const Color(0xFFB84841),
    SignalZone.lost => const Color(0xFF79828F),
  };
}

extension SignalZoneStyle on SignalZone {
  Color get color => AppColors.zone(this);

  Color textColor(Brightness brightness) => brightness == Brightness.light
      ? Color.lerp(color, Colors.black, 0.4)!
      : Color.lerp(color, Colors.white, 0.35)!;

  IconData get icon => switch (this) {
    SignalZone.veryStrong || SignalZone.strong => Icons.signal_cellular_alt,
    SignalZone.fair => Icons.signal_cellular_alt_2_bar,
    SignalZone.weak => Icons.signal_cellular_alt_1_bar,
    SignalZone.veryWeak => Icons.signal_cellular_0_bar,
    SignalZone.lost => Icons.signal_cellular_off,
  };
}
