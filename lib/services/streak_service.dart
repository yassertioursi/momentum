import '../models/habit.dart';
import '../models/habit_completion.dart';
import '../services/hive_service.dart';

class StreakService {
  static int calculateCurrentStreak(Habit habit) {
    final completions = HiveService.getCompletionsForHabit(habit.id);
    if (completions.isEmpty) return 0;

    // Sort completions by date descending
    completions.sort((a, b) => b.date.compareTo(a.date));

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayStr = _formatDate(today);

    // Check if habit is scheduled for today
    if (!_isScheduledForDay(habit, today.weekday)) {
      // Find the most recent scheduled day
      var checkDate = today.subtract(const Duration(days: 1));
      while (!_isScheduledForDay(habit, checkDate.weekday)) {
        checkDate = checkDate.subtract(const Duration(days: 1));
        if (checkDate.difference(today).inDays > 30) break;
      }
      return _calculateStreakFromDate(completions, checkDate);
    }

    // Check if completed today or yesterday
    final lastCompletion = completions.first.date;
    final yesterday = today.subtract(const Duration(days: 1));
    final yesterdayStr = _formatDate(yesterday);

    if (lastCompletion != todayStr && lastCompletion != yesterdayStr) {
      return 0;
    }

    return _calculateStreakFromDate(completions, today);
  }

  static int _calculateStreakFromDate(List<HabitCompletion> completions, DateTime fromDate) {
    if (completions.isEmpty) return 0;

    final completionDates = completions.map((c) => c.date).toSet();
    int streak = 0;
    var checkDate = fromDate;

    // If not completed today, start from yesterday
    final todayStr = _formatDate(DateTime.now());
    if (!completionDates.contains(todayStr)) {
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    while (true) {
      final dateStr = _formatDate(checkDate);
      if (completionDates.contains(dateStr)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  static int calculateLongestStreak(Habit habit) {
    final completions = HiveService.getCompletionsForHabit(habit.id);
    if (completions.isEmpty) return 0;

    completions.sort((a, b) => a.date.compareTo(b.date));

    final completionDates = completions.map((c) => c.date).toSet();
    final sortedDates = completionDates.toList()..sort();

    if (sortedDates.isEmpty) return 0;

    int longestStreak = 1;
    int currentStreak = 1;

    for (int i = 1; i < sortedDates.length; i++) {
      final prevDate = DateTime.parse(sortedDates[i - 1]);
      final currDate = DateTime.parse(sortedDates[i]);
      final diff = currDate.difference(prevDate).inDays;

      if (diff == 1) {
        currentStreak++;
        if (currentStreak > longestStreak) {
          longestStreak = currentStreak;
        }
      } else if (diff > 1) {
        currentStreak = 1;
      }
    }

    return longestStreak;
  }

  static int getTotalCompletions(String habitId) {
    return HiveService.getCompletionsForHabit(habitId).length;
  }

  static double getCompletionRate(String habitId, {int days = 30}) {
    final habit = HiveService.getHabit(habitId);
    if (habit == null) return 0;

    final now = DateTime.now();
    int scheduledDays = 0;
    int completedDays = 0;

    for (int i = 0; i < days; i++) {
      final date = now.subtract(Duration(days: i));
      if (_isScheduledForDay(habit, date.weekday)) {
        scheduledDays++;
        final dateStr = _formatDate(date);
        final completion = HiveService.getCompletionForHabitAndDate(habitId, dateStr);
        if (completion != null) {
          completedDays++;
        }
      }
    }

    if (scheduledDays == 0) return 0;
    return (completedDays / scheduledDays) * 100;
  }

  static bool _isScheduledForDay(Habit habit, int dayOfWeek) {
    switch (habit.frequencyType) {
      case 'daily':
        return true;
      case 'weekdays':
        return dayOfWeek >= 1 && dayOfWeek <= 5;
      case 'weekends':
        return dayOfWeek == 6 || dayOfWeek == 7;
      case 'custom':
        return habit.frequencyDays.contains(dayOfWeek);
      case 'timesPerWeek':
        return habit.frequencyDays.contains(dayOfWeek);
      default:
        return true;
    }
  }

  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static bool isCompletedToday(String habitId) {
    final now = DateTime.now();
    final todayStr = _formatDate(DateTime(now.year, now.month, now.day));
    return HiveService.getCompletionForHabitAndDate(habitId, todayStr) != null;
  }

  static Map<int, int> getWeeklyCompletions(String habitId) {
    final now = DateTime.now();
    final completions = HiveService.getCompletionsForHabit(habitId);
    final completionDates = completions.map((c) => c.date).toSet();

    final weeklyData = <int, int>{};
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayOfWeek = date.weekday;
      final dateStr = _formatDate(date);
      weeklyData[dayOfWeek] = completionDates.contains(dateStr) ? 1 : 0;
    }

    return weeklyData;
  }

  static Map<String, int> getMonthlyCompletions(String habitId, {int months = 3}) {
    final now = DateTime.now();
    final completions = HiveService.getCompletionsForHabit(habitId);
    final completionDates = completions.map((c) => c.date).toSet();

    final monthlyData = <String, int>{};
    for (int i = months - 1; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      
      int completedDays = 0;
      final daysInMonth = DateTime(date.year, date.month + 1, 0).day;
      
      for (int day = 1; day <= daysInMonth; day++) {
        final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
        if (completionDates.contains(dateStr)) {
          completedDays++;
        }
      }
      
      monthlyData[monthKey] = completedDays;
    }

    return monthlyData;
  }
}
