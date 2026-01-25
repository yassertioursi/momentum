import '../../../domain/entities/habit.dart';
import '../../../domain/entities/habit_completion.dart';
import '../../../domain/repositories/habit_repository.dart';
import '../datasources/local/hive_service.dart';

class HabitRepositoryImpl implements HabitRepository {
  @override
  Future<void> saveHabit(Habit habit) => HiveService.saveHabit(habit);

  @override
  List<Habit> getAllHabits() => HiveService.getAllHabits();

  @override
  Habit? getHabit(String id) => HiveService.getHabit(id);

  @override
  Future<void> deleteHabit(String id) => HiveService.deleteHabit(id);

  @override
  Future<void> saveCompletion(HabitCompletion completion) =>
      HiveService.saveCompletion(completion);

  @override
  Future<void> deleteCompletion(String id) =>
      HiveService.deleteCompletion(id);

  @override
  List<HabitCompletion> getCompletionsForHabit(String habitId) =>
      HiveService.getCompletionsForHabit(habitId);

  @override
  List<HabitCompletion> getCompletionsForDate(String date) =>
      HiveService.getCompletionsForDate(date);

  @override
  HabitCompletion? getCompletionForHabitAndDate(String habitId, String date) =>
      HiveService.getCompletionForHabitAndDate(habitId, date);

  @override
  List<HabitCompletion> getAllCompletions() =>
      HiveService.getAllCompletions();

  @override
  Future<void> clearAllData() => HiveService.clearAllData();
}