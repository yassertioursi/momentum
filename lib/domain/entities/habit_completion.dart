class HabitCompletion {
  String id;
  String habitId;
  DateTime completedAt;
  String date;
  String? notes;

  HabitCompletion({
    required this.id,
    required this.habitId,
    required this.completedAt,
    required this.date,
    this.notes,
  });

  HabitCompletion copyWith({
    String? id,
    String? habitId,
    DateTime? completedAt,
    String? date,
    String? notes,
  }) {
    return HabitCompletion(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      completedAt: completedAt ?? this.completedAt,
      date: date ?? this.date,
      notes: notes ?? this.notes,
    );
  }
}