import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/theme_preference.dart';
import '../../domain/usecases/theme_usecases.dart';

class ThemeCubit extends Cubit<ThemePreference> {
  ThemeCubit({
    required GetThemePreference getThemePreference,
    required SaveThemePreference saveThemePreference,
  }) : _get = getThemePreference,
       _save = saveThemePreference,
       super(ThemePreference.fallback);

  final GetThemePreference _get;
  final SaveThemePreference _save;

  Future<void> load() async {
    try {
      emit(await _get());
    } catch (_) {}
  }

  Future<void> select(ThemePreference preference) async {
    emit(preference);
    await _save(preference);
  }
}

extension ThemePreferenceMode on ThemePreference {
  ThemeMode get themeMode => switch (this) {
    ThemePreference.dark => ThemeMode.dark,
    ThemePreference.light => ThemeMode.light,
    ThemePreference.system => ThemeMode.system,
  };
}
