import 'package:hive_flutter/hive_flutter.dart';
import '../models/habit.dart';
import '../models/habit_completion.dart';
import '../models/user_settings.dart';

class HiveService {
  static const String habitsBoxName = 'habits';
  static const String completionsBoxName = 'completions';
  static const String settingsBoxName = 'settings';
  static const String settingsKey = 'user_settings';

  static Future<void> init() async {
    await Hive.initFlutter();
    
    Hive.registerAdapter(HabitAdapter());
    Hive.registerAdapter(HabitCompletionAdapter());
    Hive.registerAdapter(UserSettingsAdapter());
    
    await Hive.openBox<Habit>(habitsBoxName);
    await Hive.openBox<HabitCompletion>(completionsBoxName);
    await Hive.openBox<UserSettings>(settingsBoxName);
  }

  static Box<Habit> get habitsBox => Hive.box<Habit>(habitsBoxName);
  static Box<HabitCompletion> get completionsBox => Hive.box<HabitCompletion>(completionsBoxName);
  static Box<UserSettings> get settingsBox => Hive.box<UserSettings>(settingsBoxName);

  // Habits
  static Future<void> saveHabit(Habit habit) async {
    await habitsBox.put(habit.id, habit);
  }

  static List<Habit> getAllHabits() {
    return habitsBox.values.where((h) => !h.isArchived).toList();
  }

  static Habit? getHabit(String id) {
    return habitsBox.get(id);
  }

  static Future<void> deleteHabit(String id) async {
    await habitsBox.delete(id);
    // Delete all completions for this habit
    final completions = completionsBox.values.where((c) => c.habitId == id).toList();
    for (var completion in completions) {
      await completionsBox.delete(completion.id);
    }
  }

  // Completions
  static Future<void> saveCompletion(HabitCompletion completion) async {
    await completionsBox.put(completion.id, completion);
  }

  static Future<void> deleteCompletion(String id) async {
    await completionsBox.delete(id);
  }

  static List<HabitCompletion> getCompletionsForHabit(String habitId) {
    return completionsBox.values.where((c) => c.habitId == habitId).toList();
  }

  static List<HabitCompletion> getCompletionsForDate(String date) {
    return completionsBox.values.where((c) => c.date == date).toList();
  }

  static HabitCompletion? getCompletionForHabitAndDate(String habitId, String date) {
    try {
      return completionsBox.values.firstWhere(
        (c) => c.habitId == habitId && c.date == date,
      );
    } catch (_) {
      return null;
    }
  }

  static List<HabitCompletion> getAllCompletions() {
    return completionsBox.values.toList();
  }

  // Settings
  static UserSettings getSettings() {
    return settingsBox.get(settingsKey) ?? UserSettings();
  }

  static Future<void> saveSettings(UserSettings settings) async {
    await settingsBox.put(settingsKey, settings);
  }

  // Seed data
  static Future<void> seedSampleData() async {
    if (habitsBox.isEmpty) {
      final sampleHabits = [
        Habit(
          id: '1',
          title: 'Drink Water',
          icon: 'water_drop',
          colorValue: 0xFF3B82F6,
          category: 'health',
          frequencyType: 'daily',
          frequencyDays: [1, 2, 3, 4, 5, 6, 7],
          reminderTime: '08:00',
          reminderEnabled: true,
          notes: 'Drink 8 glasses of water daily',
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
        ),
        Habit(
          id: '2',
          title: 'Read Books',
          icon: 'menu_book',
          colorValue: 0xFF8B5CF6,
          category: 'learning',
          frequencyType: 'daily',
          frequencyDays: [1, 2, 3, 4, 5, 6, 7],
          reminderTime: '21:00',
          reminderEnabled: true,
          notes: 'Read for at least 30 minutes',
          createdAt: DateTime.now().subtract(const Duration(days: 25)),
        ),
        Habit(
          id: '3',
          title: 'Exercise',
          icon: 'fitness_center',
          colorValue: 0xFF10B981,
          category: 'fitness',
          frequencyType: 'weekdays',
          frequencyDays: [1, 2, 3, 4, 5],
          reminderTime: '07:00',
          reminderEnabled: true,
          notes: '30 minutes of workout',
          createdAt: DateTime.now().subtract(const Duration(days: 20)),
        ),
        Habit(
          id: '4',
          title: 'Meditation',
          icon: 'self_improvement',
          colorValue: 0xFFF97316,
          category: 'mindfulness',
          frequencyType: 'daily',
          frequencyDays: [1, 2, 3, 4, 5, 6, 7],
          reminderTime: '06:30',
          reminderEnabled: true,
          notes: '10 minutes of mindfulness',
          createdAt: DateTime.now().subtract(const Duration(days: 15)),
        ),
        Habit(
          id: '5',
          title: 'Journaling',
          icon: 'edit_note',
          colorValue: 0xFFEC4899,
          category: 'productivity',
          frequencyType: 'custom',
          frequencyDays: [1, 3, 5],
          reminderEnabled: false,
          notes: 'Write about your day',
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
        ),
      ];

      for (var habit in sampleHabits) {
        await saveHabit(habit);
      }

      // Generate sample completions for the past 30 days
      final now = DateTime.now();
      for (var i = 0; i < 30; i++) {
        final date = now.subtract(Duration(days: i));
        final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        
        for (var habit in sampleHabits) {
          // Random completion based on habit type
          final dayOfWeek = date.weekday;
          bool shouldComplete = false;
          
          if (habit.frequencyType == 'daily') {
            shouldComplete = true;
          } else if (habit.frequencyType == 'weekdays') {
            shouldComplete = dayOfWeek >= 1 && dayOfWeek <= 5;
          } else if (habit.frequencyType == 'weekends') {
            shouldComplete = dayOfWeek == 6 || dayOfWeek == 7;
          } else if (habit.frequencyType == 'custom') {
            shouldComplete = habit.frequencyDays.contains(dayOfWeek);
          }
          
          // Add some randomness to make it more realistic
          if (shouldComplete && i < 25) {
            final random = DateTime.now().millisecondsSinceEpoch + i + habit.id.hashCode;
            if (random % 3 != 0) { // ~67% completion rate
              final completion = HabitCompletion(
                id: '${habit.id}_$dateStr',
                habitId: habit.id,
                completedAt: date,
                date: dateStr,
              );
              await saveCompletion(completion);
            }
          }
        }
      }
    }
  }
}
