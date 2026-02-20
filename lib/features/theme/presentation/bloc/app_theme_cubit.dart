import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../services/hive_service.dart';

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
  AppThemeCubit() : super(const ThemeState()) {
    final settings = HiveService.getSettings();
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
    final settings = HiveService.getSettings();
    await HiveService.saveSettings(settings.copyWith(isDarkMode: value));
  }

  Future<void> setThemeType(AppThemeType type) async {
    AppColors.setTheme(type);
    emit(state.copyWith(themeType: type));
    final settings = HiveService.getSettings();
    await HiveService.saveSettings(
      settings.copyWith(themeTypeIndex: type.index),
    );
  }
}