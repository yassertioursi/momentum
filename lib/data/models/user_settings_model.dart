import 'package:hive/hive.dart';
import '../../domain/entities/user_settings.dart';

class UserSettingsModel extends UserSettings {
  UserSettingsModel({
    super.isDarkMode,
    super.hasCompletedOnboarding,
    super.notificationsEnabled,
    super.defaultReminderTime,
    super.themeTypeIndex,
  });

  factory UserSettingsModel.fromEntity(UserSettings settings) {
    return UserSettingsModel(
      isDarkMode: settings.isDarkMode,
      hasCompletedOnboarding: settings.hasCompletedOnboarding,
      notificationsEnabled: settings.notificationsEnabled,
      defaultReminderTime: settings.defaultReminderTime,
      themeTypeIndex: settings.themeTypeIndex,
    );
  }
}

class UserSettingsAdapter extends TypeAdapter<UserSettingsModel> {
  @override
  final int typeId = 2;

  @override
  UserSettingsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserSettingsModel(
      isDarkMode: fields[0] as bool? ?? false,
      hasCompletedOnboarding: fields[1] as bool? ?? false,
      notificationsEnabled: fields[2] as bool? ?? true,
      defaultReminderTime: fields[3] as String?,
      themeTypeIndex: fields[4] as int? ?? 0,
    );
  }

  @override
  void write(BinaryWriter writer, UserSettingsModel obj) {
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