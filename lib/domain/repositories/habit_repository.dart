import '../entities/habit.dart';
import '../entities/habit_completion.dart';

abstract class HabitRepository {
  Future<void> saveHabit(Habit habit);

  List<Habit> getAllHabits();

  Habit? getHabit(String id);

  Future<void> deleteHabit(String id);

  Future<void> saveCompletion(HabitCompletion completion);

  Future<void> deleteCompletion(String id);

  List<HabitCompletion> getCompletionsForHabit(String habitId);

  List<HabitCompletion> getCompletionsForDate(String date);

  HabitCompletion? getCompletionForHabitAndDate(String habitId, String date);

  List<HabitCompletion> getAllCompletions();

  Future<void> clearAllData();
}