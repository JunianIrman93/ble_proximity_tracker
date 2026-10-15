import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/theme_preference.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._prefs);

  final SharedPreferencesAsync _prefs;

  static const _themeKey = 'theme_preference';

  @override
  Future<ThemePreference> themePreference() async =>
      ThemePreference.parse(await _prefs.getString(_themeKey));

  @override
  Future<void> saveThemePreference(ThemePreference preference) =>
      _prefs.setString(_themeKey, preference.name);
}
