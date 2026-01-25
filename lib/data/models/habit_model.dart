import 'package:hive/hive.dart';
import '../../domain/entities/habit.dart';

class HabitModel extends Habit {
  HabitModel({
    required super.id,
    required super.title,
    required super.icon,
    required super.colorValue,
    required super.category,
    required super.frequencyType,
    required super.frequencyDays,
    super.reminderTime,
    super.reminderEnabled,
    super.notes,
    super.goalType,
    super.goalTarget,
    required super.createdAt,
    super.isArchived,
  });

  factory HabitModel.fromEntity(Habit habit) {
    return HabitModel(
      id: habit.id,
      title: habit.title,
      icon: habit.icon,
      colorValue: habit.colorValue,
      category: habit.category,
      frequencyType: habit.frequencyType,
      frequencyDays: List<int>.from(habit.frequencyDays),
      reminderTime: habit.reminderTime,
      reminderEnabled: habit.reminderEnabled,
      notes: habit.notes,
      goalType: habit.goalType,
      goalTarget: habit.goalTarget,
      createdAt: habit.createdAt,
      isArchived: habit.isArchived,
    );
  }
}

class HabitAdapter extends TypeAdapter<HabitModel> {
  @override
  final int typeId = 0;

  @override
  HabitModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HabitModel(
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
  void write(BinaryWriter writer, HabitModel obj) {
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