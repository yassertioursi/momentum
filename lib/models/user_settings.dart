import 'package:hive/hive.dart';
import '../core/constants/app_constants.dart';

class UserSettings extends HiveObject {
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
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      defaultReminderTime: defaultReminderTime ?? this.defaultReminderTime,
      themeTypeIndex: themeTypeIndex ?? this.themeTypeIndex,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isDarkMode': isDarkMode,
      'hasCompletedOnboarding': hasCompletedOnboarding,
      'notificationsEnabled': notificationsEnabled,
      'defaultReminderTime': defaultReminderTime,
      'themeTypeIndex': themeTypeIndex,
    };
  }

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      isDarkMode: json['isDarkMode'] as bool? ?? false,
      hasCompletedOnboarding: json['hasCompletedOnboarding'] as bool? ?? false,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      defaultReminderTime: json['defaultReminderTime'] as String?,
      themeTypeIndex: json['themeTypeIndex'] as int? ?? 0,
    );
  }
}

class UserSettingsAdapter extends TypeAdapter<UserSettings> {
  @override
  final int typeId = 2;

  @override
  UserSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserSettings(
      isDarkMode: fields[0] as bool? ?? false,
      hasCompletedOnboarding: fields[1] as bool? ?? false,
      notificationsEnabled: fields[2] as bool? ?? true,
      defaultReminderTime: fields[3] as String?,
      themeTypeIndex: fields[4] as int? ?? 0,
    );
  }

  @override
  void write(BinaryWriter writer, UserSettings obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.isDarkMode)
      ..writeByte(1)
      ..write(obj.hasCompletedOnboarding)
      ..writeByte(2)
      ..write(obj.notificationsEnabled)
      ..writeByte(3)
      ..write(obj.defaultReminderTime)
      ..writeByte(4)
      ..write(obj.themeTypeIndex);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
