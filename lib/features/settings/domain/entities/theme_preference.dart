enum ThemePreference {
  dark,
  light,
  system;

  static const fallback = ThemePreference.system;

  static ThemePreference parse(String? value) => ThemePreference.values
      .firstWhere((p) => p.name == value, orElse: () => fallback);
}
