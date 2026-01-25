import '../../../domain/entities/user_settings.dart';
import '../../../domain/repositories/settings_repository.dart';
import '../datasources/local/hive_service.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  @override
  UserSettings getSettings() => HiveService.getSettings();

  @override
  Future<void> saveSettings(UserSettings settings) =>
      HiveService.saveSettings(settings);
}