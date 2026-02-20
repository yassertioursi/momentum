import 'package:flutter_bloc/flutter_bloc.dart';

class AnalyticsState {
  final int timeRange;

  const AnalyticsState({this.timeRange = 7});

  AnalyticsState copyWith({int? timeRange}) {
    return AnalyticsState(timeRange: timeRange ?? this.timeRange);
  }
}

class AnalyticsCubit extends Cubit<AnalyticsState> {
  AnalyticsCubit() : super(const AnalyticsState());

  void setTimeRange(int range) {
    emit(state.copyWith(timeRange: range));
  }
}