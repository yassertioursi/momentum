import 'package:hive/hive.dart';
import '../../domain/entities/habit_completion.dart';

class HabitCompletionModel extends HabitCompletion {
  HabitCompletionModel({
    required super.id,
    required super.habitId,
    required super.completedAt,
    required super.date,
    super.notes,
  });

  factory HabitCompletionModel.fromEntity(HabitCompletion completion) {
    return HabitCompletionModel(
      id: completion.id,
      habitId: completion.habitId,
      completedAt: completion.completedAt,
      date: completion.date,
      notes: completion.notes,
    );
  }
}

class HabitCompletionAdapter extends TypeAdapter<HabitCompletionModel> {
  @override
  final int typeId = 1;

  @override
  HabitCompletionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HabitCompletionModel(
      id: fields[0] as String,
      habitId: fields[1] as String,
      completedAt: fields[2] as DateTime,
      date: fields[3] as String,
      notes: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, HabitCompletionModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.habitId)
      ..writeByte(2)
      ..write(obj.completedAt)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitCompletionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}