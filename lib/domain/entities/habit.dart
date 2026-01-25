class Habit {
  String id;
  String title;
  String icon;
  int colorValue;
  String category;
  String frequencyType;
  List<int> frequencyDays;
  String? reminderTime;
  bool reminderEnabled;
  String? notes;
  String? goalType;
  int? goalTarget;
  DateTime createdAt;
  bool isArchived;

  Habit({
    required this.id,
    required this.title,
    required this.icon,
    required this.colorValue,
    required this.category,
    required this.frequencyType,
    required this.frequencyDays,
    this.reminderTime,
    this.reminderEnabled = false,
    this.notes,
    this.goalType,
    this.goalTarget,
    required this.createdAt,
    this.isArchived = false,
  });

  Habit copyWith({
    String? id,
    String? title,
    String? icon,
    int? colorValue,
    String? category,
    String? frequencyType,
    List<int>? frequencyDays,
    String? reminderTime,
    bool? reminderEnabled,
    String? notes,
    String? goalType,
    int? goalTarget,
    DateTime? createdAt,
    bool? isArchived,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      icon: icon ?? this.icon,
      colorValue: colorValue ?? this.colorValue,
      category: category ?? this.category,
      frequencyType: frequencyType ?? this.frequencyType,
      frequencyDays: frequencyDays ?? List.from(this.frequencyDays),
      reminderTime: reminderTime ?? this.reminderTime,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      notes: notes ?? this.notes,
      goalType: goalType ?? this.goalType,
      goalTarget: goalTarget ?? this.goalTarget,
      createdAt: createdAt ?? this.createdAt,
      isArchived: isArchived ?? this.isArchived,
    );
  }
}

enum FrequencyType {
  daily,
  weekdays,
  weekends,
  custom,
  timesPerWeek,
}

extension FrequencyTypeExtension on FrequencyType {
  String get displayName {
    switch (this) {
      case FrequencyType.daily:
        return 'Daily';
      case FrequencyType.weekdays:
        return 'Weekdays';
      case FrequencyType.weekends:
        return 'Weekends';
      case FrequencyType.custom:
        return 'Custom Days';
      case FrequencyType.timesPerWeek:
        return 'X Times per Week';
    }
  }

  static FrequencyType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'daily':
        return FrequencyType.daily;
      case 'weekdays':
        return FrequencyType.weekdays;
      case 'weekends':
        return FrequencyType.weekends;
      case 'custom':
        return FrequencyType.custom;
      case 'timesperweek':
        return FrequencyType.timesPerWeek;
      default:
        return FrequencyType.daily;
    }
  }
}

enum HabitCategory {
  health,
  productivity,
  mindfulness,
  learning,
  fitness,
  finance,
  social,
  creativity,
  other,
}

extension HabitCategoryExtension on HabitCategory {
  String get displayName {
    switch (this) {
      case HabitCategory.health:
        return 'Health';
      case HabitCategory.productivity:
        return 'Productivity';
      case HabitCategory.mindfulness:
        return 'Mindfulness';
      case HabitCategory.learning:
        return 'Learning';
      case HabitCategory.fitness:
        return 'Fitness';
      case HabitCategory.finance:
        return 'Finance';
      case HabitCategory.social:
        return 'Social';
      case HabitCategory.creativity:
        return 'Creativity';
      case HabitCategory.other:
        return 'Other';
    }
  }

  static HabitCategory fromString(String value) {
    switch (value.toLowerCase()) {
      case 'health':
        return HabitCategory.health;
      case 'productivity':
        return HabitCategory.productivity;
      case 'mindfulness':
        return HabitCategory.mindfulness;
      case 'learning':
        return HabitCategory.learning;
      case 'fitness':
        return HabitCategory.fitness;
      case 'finance':
        return HabitCategory.finance;
      case 'social':
        return HabitCategory.social;
      case 'creativity':
        return HabitCategory.creativity;
      default:
        return HabitCategory.other;
    }
  }
}