import '../entities/theme_preference.dart';
import '../repositories/settings_repository.dart';

class GetThemePreference {
  const GetThemePreference(this._repository);

  final SettingsRepository _repository;

  Future<ThemePreference> call() => _repository.themePreference();
}

class SaveThemePreference {
  const SaveThemePreference(this._repository);

  final SettingsRepository _repository;

  Future<void> call(ThemePreference preference) =>
      _repository.saveThemePreference(preference);
}
