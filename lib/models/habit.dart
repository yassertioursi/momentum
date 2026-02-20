import 'package:hive/hive.dart';

class Habit extends HiveObject {
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'icon': icon,
      'colorValue': colorValue,
      'category': category,
      'frequencyType': frequencyType,
      'frequencyDays': frequencyDays,
      'reminderTime': reminderTime,
      'reminderEnabled': reminderEnabled,
      'notes': notes,
      'goalType': goalType,
      'goalTarget': goalTarget,
      'createdAt': createdAt.toIso8601String(),
      'isArchived': isArchived,
    };
  }

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] as String,
      title: json['title'] as String,
      icon: json['icon'] as String,
      colorValue: json['colorValue'] as int,
      category: json['category'] as String,
      frequencyType: json['frequencyType'] as String,
      frequencyDays: List<int>.from(json['frequencyDays'] as List),
      reminderTime: json['reminderTime'] as String?,
      reminderEnabled: json['reminderEnabled'] as bool? ?? false,
      notes: json['notes'] as String?,
      goalType: json['goalType'] as String?,
      goalTarget: json['goalTarget'] as int?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isArchived: json['isArchived'] as bool? ?? false,
    );
  }
}

class HabitAdapter extends TypeAdapter<Habit> {
  @override
  final int typeId = 0;

  @override
  Habit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Habit(
      id: fields[0] as String,
      title: fields[1] as String,
      icon: fields[2] as String,
      colorValue: fields[3] as int,
      category: fields[4] as String,
      frequencyType: fields[5] as String,
      frequencyDays: (fields[6] as List).cast<int>(),
      reminderTime: fields[7] as String?,
      reminderEnabled: fields[8] as bool? ?? false,
      notes: fields[9] as String?,
      goalType: fields[10] as String?,
      goalTarget: fields[11] as int?,
      createdAt: fields[12] as DateTime,
      isArchived: fields[13] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, Habit obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.icon)
      ..writeByte(3)
      ..write(obj.colorValue)
      ..writeByte(4)
      ..write(obj.category)
      ..writeByte(5)
      ..write(obj.frequencyType)
      ..writeByte(6)
      ..write(obj.frequencyDays)
      ..writeByte(7)
      ..write(obj.reminderTime)
      ..writeByte(8)
      ..write(obj.reminderEnabled)
      ..writeByte(9)
      ..write(obj.notes)
      ..writeByte(10)
      ..write(obj.goalType)
      ..writeByte(11)
      ..write(obj.goalTarget)
      ..writeByte(12)
      ..write(obj.createdAt)
      ..writeByte(13)
      ..write(obj.isArchived);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
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
