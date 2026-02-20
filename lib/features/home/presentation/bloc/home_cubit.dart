import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../models/habit.dart';
import '../../../../models/habit_completion.dart';
import '../../../../services/hive_service.dart';
import '../../../../services/streak_service.dart';

class HomeState {
  final List<Habit> habits;
  final Map<String, bool> completions;
  final int completedToday;
  final int totalHabits;
  final double completionPercentage;
  final int activeStreaks;
  final bool isLoading;

  const HomeState({
    this.habits = const [],
    this.completions = const {},
    this.completedToday = 0,
    this.totalHabits = 0,
    this.completionPercentage = 0,
    this.activeStreaks = 0,
    this.isLoading = true,
  });

  HomeState copyWith({
    List<Habit>? habits,
    Map<String, bool>? completions,
    int? completedToday,
    int? totalHabits,
    double? completionPercentage,
    int? activeStreaks,
    bool? isLoading,
  }) {
    return HomeState(
      habits: habits ?? this.habits,
      completions: completions ?? this.completions,
      completedToday: completedToday ?? this.completedToday,
      totalHabits: totalHabits ?? this.totalHabits,
      completionPercentage: completionPercentage ?? this.completionPercentage,
      activeStreaks: activeStreaks ?? this.activeStreaks,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeState());

  void loadData() {
    final habits = HiveService.getAllHabits();
    final now = DateTime.now();
    final today =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final completions = <String, bool>{};
    int completedToday = 0;
    int activeStreaks = 0;

    for (var habit in habits) {
      final isCompleted =
          HiveService.getCompletionForHabitAndDate(habit.id, today) != null;
      completions[habit.id] = isCompleted;
      if (isCompleted) completedToday++;

      final streak = StreakService.calculateCurrentStreak(habit);
      if (streak > 0) activeStreaks++;
    }

    final totalHabits = habits.length;
    final percentage = totalHabits > 0 ? (completedToday / totalHabits) * 100 : 0.0;

    emit(
      state.copyWith(
        habits: habits,
        completions: completions,
        completedToday: completedToday,
        totalHabits: totalHabits,
        completionPercentage: percentage,
        activeStreaks: activeStreaks,
        isLoading: false,
      ),
    );
  }

  Future<void> toggleCompletion(String habitId) async {
    final now = DateTime.now();
    final today =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final existingCompletion =
        HiveService.getCompletionForHabitAndDate(habitId, today);

    if (existingCompletion != null) {
      await HiveService.deleteCompletion(existingCompletion.id);
    } else {
      final completion = HabitCompletion(
        id: '${habitId}_$today',
        habitId: habitId,
        completedAt: now,
        date: today,
      );
      await HiveService.saveCompletion(completion);
    }

    loadData();
  }
}