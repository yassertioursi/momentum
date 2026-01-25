import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../domain/entities/user_settings.dart';
import '../../../../domain/repositories/settings_repository.dart';

class ThemeState {
  final bool isDarkMode;
  final AppThemeType themeType;

  const ThemeState({
    this.isDarkMode = false,
    this.themeType = AppThemeType.violet,
  });

  ThemeState copyWith({
    bool? isDarkMode,
    AppThemeType? themeType,
  }) {
    return ThemeState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      themeType: themeType ?? this.themeType,
    );
  }
}

class AppThemeCubit extends Cubit<ThemeState> {
  final SettingsRepository _settingsRepository;

  AppThemeCubit({required SettingsRepository settingsRepository})
      : _settingsRepository = settingsRepository,
        super(const ThemeState()) {
    final settings = _settingsRepository.getSettings();
    AppColors.setTheme(settings.themeType);
    emit(
      ThemeState(
        isDarkMode: settings.isDarkMode,
        themeType: settings.themeType,
      ),
    );
  }

  Future<void> setDarkMode(bool value) async {
    emit(state.copyWith(isDarkMode: value));
    final settings = _settingsRepository.getSettings();
    await _settingsRepository.saveSettings(
      settings.copyWith(isDarkMode: value),
    );
  }

  Future<void> setThemeType(AppThemeType type) async {
    AppColors.setTheme(type);
    emit(state.copyWith(themeType: type));
    final settings = _settingsRepository.getSettings();
    await _settingsRepository.saveSettings(
      settings.copyWith(themeTypeIndex: type.index),
    );
  }

  Future<void> completeOnboarding() async {
    final settings = _settingsRepository.getSettings();
    await _settingsRepository.saveSettings(
      settings.copyWith(hasCompletedOnboarding: true),
    );
  }

  UserSettings get settings => _settingsRepository.getSettings();
}