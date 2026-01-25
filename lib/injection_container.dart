import 'domain/repositories/habit_repository.dart';
import 'domain/repositories/settings_repository.dart';
import 'domain/services/streak_service.dart';
import 'data/repositories/habit_repository_impl.dart';
import 'data/repositories/settings_repository_impl.dart';

class ServiceLocator {
  ServiceLocator._();

  static final ServiceLocator instance = ServiceLocator._();

  final Map<Type, Object> _instances = {};

  void register<T extends Object>(T instance) {
    _instances[T] = instance;
  }

  T get<T extends Object>() {
    return _instances[T] as T;
  }
}

final sl = ServiceLocator.instance;

void setupDependencies() {
  sl.register<HabitRepository>(HabitRepositoryImpl());
  sl.register<SettingsRepository>(SettingsRepositoryImpl());
  sl.register<StreakService>(
    StreakService(habitRepository: sl.get<HabitRepository>()),
  );
}