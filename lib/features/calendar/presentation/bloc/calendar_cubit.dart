import 'package:flutter_bloc/flutter_bloc.dart';

class CalendarState {
  final String? selectedHabitId;

  const CalendarState({this.selectedHabitId});
}

class CalendarCubit extends Cubit<CalendarState> {
  CalendarCubit() : super(const CalendarState());

  void selectHabit(String? habitId) {
    emit(CalendarState(selectedHabitId: habitId));
  }
}