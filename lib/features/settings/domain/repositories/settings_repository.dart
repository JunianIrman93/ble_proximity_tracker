import '../entities/theme_preference.dart';

abstract interface class SettingsRepository {
  Future<ThemePreference> themePreference();

  Future<void> saveThemePreference(ThemePreference preference);
}
