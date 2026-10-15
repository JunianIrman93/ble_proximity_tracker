import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:ble_proximity_tracker/features/settings/domain/entities/theme_preference.dart';
import 'package:ble_proximity_tracker/features/settings/domain/usecases/theme_usecases.dart';
import 'package:ble_proximity_tracker/features/settings/presentation/cubit/theme_cubit.dart';

import '../../helpers/fakes.dart';

void main() {
  late MockSettingsRepository repo;

  setUpAll(() => registerFallbackValue(ThemePreference.dark));

  setUp(() {
    repo = MockSettingsRepository();
    when(() => repo.saveThemePreference(any())).thenAnswer((_) async {});
  });

  ThemeCubit build() => ThemeCubit(
    getThemePreference: GetThemePreference(repo),
    saveThemePreference: SaveThemePreference(repo),
  );

  test('system is the default', () {
    expect(build().state, ThemePreference.system);
    expect(ThemePreference.parse(null), ThemePreference.system);
  });

  blocTest<ThemeCubit, ThemePreference>(
    'loads the saved preference',
    setUp: () =>
        when(() => repo.themePreference())
            .thenAnswer((_) async => ThemePreference.light),
    build: build,
    act: (cubit) => cubit.load(),
    expect: () => [ThemePreference.light],
  );

  blocTest<ThemeCubit, ThemePreference>(
    'saves a new selection',
    build: build,
    act: (cubit) => cubit.select(ThemePreference.light),
    expect: () => [ThemePreference.light],
    verify: (_) =>
        verify(() => repo.saveThemePreference(ThemePreference.light)).called(1),
  );
}
