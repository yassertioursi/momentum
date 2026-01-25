import '../../core/constants/app_constants.dart';

class UserSettings {
  bool isDarkMode;
  bool hasCompletedOnboarding;
  bool notificationsEnabled;
  String? defaultReminderTime;
  int themeTypeIndex;

  UserSettings({
    this.isDarkMode = false,
    this.hasCompletedOnboarding = false,
    this.notificationsEnabled = false,
    this.defaultReminderTime,
    this.themeTypeIndex = 0,
  });

  AppThemeType get themeType => AppThemeType.values[themeTypeIndex];

  UserSettings copyWith({
    bool? isDarkMode,
    bool? hasCompletedOnboarding,
    bool? notificationsEnabled,
    String? defaultReminderTime,
    int? themeTypeIndex,
  }) {
    return UserSettings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      defaultReminderTime: defaultReminderTime ?? this.defaultReminderTime,
      themeTypeIndex: themeTypeIndex ?? this.themeTypeIndex,
    );
  }
}