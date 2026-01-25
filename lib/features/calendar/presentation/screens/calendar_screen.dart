import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../domain/entities/habit.dart';
import '../../../../domain/repositories/habit_repository.dart';
import '../../../../injection_container.dart';
import '../bloc/calendar_cubit.dart';
import '../../../home/presentation/bloc/home_cubit.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    context.read<HomeCubit>().loadData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<HomeCubit>().loadData();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch home cubit so the heatmap rebuilds when habits change
    final homeState = context.watch<HomeCubit>().state;
    final selectedHabitId = context.watch<CalendarCubit>().state.selectedHabitId;

    final habits = homeState.habits;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
      ),
      body: Column(
        children: [
          // Habit Filter
          if (habits.isNotEmpty)
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _FilterChip(
                    label: 'All Habits',
                    isSelected: selectedHabitId == null,
                    onTap: () {
                      context.read<CalendarCubit>().selectHabit(null);
                    },
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  ...habits.map((habit) => Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.sm),
                        child: _FilterChip(
                          label: habit.title,
                          color: Color(habit.colorValue),
                          isSelected: selectedHabitId == habit.id,
                          onTap: () {
                            context.read<CalendarCubit>().selectHabit(habit.id);
                          },
                        ),
                      )),
                ],
              ),
            ),

          const SizedBox(height: AppSpacing.md),

          // Heatmap
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeatmapView(habitId: selectedHabitId),
                  const SizedBox(height: AppSpacing.lg),

                  // Legend
                  _Legend(),
                  const SizedBox(height: AppSpacing.lg),

                  // Month Summary
                  _MonthSummary(habitId: selectedHabitId),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final Color? color;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? (color ?? AppColors.primary).withOpacity(0.2)
              : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: isSelected
                ? (color ?? AppColors.primary)
                : (isDark ? AppColors.dividerDark : AppColors.dividerLight),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (color != null) ...[
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? (color ?? AppColors.primary)
                    : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeatmapView extends StatelessWidget {
  final String? habitId;

  const _HeatmapView({this.habitId});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final habitRepository = sl.get<HabitRepository>();
    final habits = habitRepository.getAllHabits();

    // Generate data for the last 12 weeks (84 days)
    final weeks = <List<_DayData>>[];
    
    for (int week = 11; week >= 0; week--) {
      final weekData = <_DayData>[];
      for (int day = 0; day < 7; day++) {
        final date = now.subtract(Duration(days: week * 7 + (6 - day)));
        final dateStr = DateFormat('yyyy-MM-dd').format(date);
        
        int completed = 0;
        int total = 0;
        
        if (habitId != null) {
          // Single habit
          final habit = habitRepository.getHabit(habitId!);
          if (habit != null && _isScheduledForDay(habit, date.weekday)) {
            total = 1;
            if (habitRepository.getCompletionForHabitAndDate(habitId!, dateStr) != null) {
              completed = 1;
            }
          }
        } else {
          // All habits
          for (var habit in habits) {
            if (_isScheduledForDay(habit, date.weekday)) {
              total++;
              if (habitRepository.getCompletionForHabitAndDate(habit.id, dateStr) != null) {
                completed++;
              }
            }
          }
        }
        
        double intensity = total > 0 ? completed / total : 0;
        weekData.add(_DayData(date: date, completed: completed, total: total, intensity: intensity));
      }
      weeks.add(weekData);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month Labels
        Row(
          children: List.generate(12, (weekIndex) {
            final firstDayOfWeek = weeks[11 - weekIndex].first.date;
            final showLabel = weekIndex == 0 || 
                firstDayOfWeek.day <= 7;
            
            return Expanded(
              child: showLabel
                  ? Text(
                      DateFormat('MMM').format(firstDayOfWeek),
                      style: Theme.of(context).textTheme.labelSmall,
                      textAlign: TextAlign.left,
                    )
                  : const SizedBox(),
            );
          }),
        ),
        const SizedBox(height: 8),

        // Heatmap Grid
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day labels
            Column(
              children: [
                const SizedBox(height: 2),
                ...['M', '', 'W', '', 'F', '', 'S'].map((day) => SizedBox(
                      height: 14,
                      child: Text(
                        day,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontSize: 10,
                            ),
                      ),
                    )),
              ],
            ),
            const SizedBox(width: 8),

            // Weeks
            Expanded(
              child: Column(
                children: [
                  Row(
                    children: List.generate(12, (weekIndex) {
                      return Expanded(
                        child: Column(
                          children: weeks[weekIndex].map((dayData) {
                            return Padding(
                              padding: const EdgeInsets.all(2),
                              child: _HeatmapCell(
                                dayData: dayData,
                                isDark: isDark,
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  bool _isScheduledForDay(Habit habit, int dayOfWeek) {
    switch (habit.frequencyType) {
      case 'daily':
        return true;
      case 'weekdays':
        return dayOfWeek >= 1 && dayOfWeek <= 5;
      case 'weekends':
        return dayOfWeek == 6 || dayOfWeek == 7;
      case 'custom':
        return habit.frequencyDays.contains(dayOfWeek);
      default:
        return true;
    }
  }
}

class _DayData {
  final DateTime date;
  final int completed;
  final int total;
  final double intensity;

  _DayData({
    required this.date,
    required this.completed,
    required this.total,
    required this.intensity,
  });
}

class _HeatmapCell extends StatelessWidget {
  final _DayData dayData;
  final bool isDark;

  const _HeatmapCell({
    required this.dayData,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    Color getColor() {
      if (dayData.total == 0) {
        return isDark ? AppColors.backgroundDark : AppColors.heatmapLight[0];
      }
      if (dayData.intensity == 0) {
        return isDark ? AppColors.heatmapDark[0] : AppColors.heatmapLight[0];
      }
      if (dayData.intensity <= 0.25) {
        return isDark ? AppColors.heatmapDark[1] : AppColors.heatmapLight[1];
      }
      if (dayData.intensity <= 0.5) {
        return isDark ? AppColors.heatmapDark[2] : AppColors.heatmapLight[2];
      }
      if (dayData.intensity <= 0.75) {
        return isDark ? AppColors.heatmapDark[3] : AppColors.heatmapLight[3];
      }
      return isDark ? AppColors.heatmapDark[4] : AppColors.heatmapLight[4];
    }

    return GestureDetector(
      onTap: () => _showDayDetails(context),
      child: Tooltip(
        message: '${dayData.date.day}/${dayData.date.month}: ${dayData.completed}/${dayData.total}',
        child: AnimatedContainer(
          duration: AppDurations.fast,
          width: double.infinity,
          height: 14,
          decoration: BoxDecoration(
            color: getColor(),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }

  void _showDayDetails(BuildContext context) {
    final dateStr = DateFormat('yyyy-MM-dd').format(dayData.date);
    final habitRepository = sl.get<HabitRepository>();
    final habits = habitRepository.getAllHabits();
    final completedHabits = <Habit>[];
    
    for (var habit in habits) {
      if (habitRepository.getCompletionForHabitAndDate(habit.id, dateStr) != null) {
        completedHabits.add(habit);
      }
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('EEEE, MMMM d, yyyy').format(dayData.date),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${dayData.completed} of ${dayData.total} habits completed',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (completedHabits.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: completedHabits.map((habit) => Chip(
                  avatar: Icon(
                    _getIconData(habit.icon),
                    size: 18,
                    color: Color(habit.colorValue),
                  ),
                  label: Text(habit.title),
                  backgroundColor: Color(habit.colorValue).withOpacity(0.1),
                )).toList(),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    final iconMap = {
      'water_drop': Icons.water_drop,
      'menu_book': Icons.menu_book,
      'fitness_center': Icons.fitness_center,
      'self_improvement': Icons.self_improvement,
      'edit_note': Icons.edit_note,
      'bedtime': Icons.bedtime,
      'code': Icons.code,
      'music_note': Icons.music_note,
      'brush': Icons.brush,
      'restaurant': Icons.restaurant,
      'savings': Icons.savings,
      'favorite': Icons.favorite,
      'star': Icons.star,
      'emoji_events': Icons.emoji_events,
      'local_florist': Icons.local_florist,
    };
    return iconMap[iconName] ?? Icons.check_circle;
  }
}

class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        const Text('Less'),
        const SizedBox(width: 4),
        ...List.generate(5, (index) {
          return Container(
            width: 14,
            height: 14,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.heatmapDark[index]
                  : AppColors.heatmapLight[index],
              borderRadius: BorderRadius.circular(3),
            ),
          );
        }),
        const SizedBox(width: 4),
        const Text('More'),
      ],
    );
  }
}

class _MonthSummary extends StatelessWidget {
  final String? habitId;

  const _MonthSummary({this.habitId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final habitRepository = sl.get<HabitRepository>();
    final habits = habitId != null
        ? [habitRepository.getHabit(habitId!)].whereType<Habit>().toList()
        : habitRepository.getAllHabits();

    int totalScheduled = 0;
    int totalCompleted = 0;

    for (int i = 0; i < now.day; i++) {
      final date = DateTime(now.year, now.month - 0, i + 1);
      for (var habit in habits) {
        if (_isScheduledForDay(habit, date.weekday)) {
          totalScheduled++;
          final dateStr = DateFormat('yyyy-MM-dd').format(date);
          if (habitRepository.getCompletionForHabitAndDate(habit.id, dateStr) != null) {
            totalCompleted++;
          }
        }
      }
    }

    final rate = totalScheduled > 0 ? (totalCompleted / totalScheduled) * 100 : 0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: theme.dividerTheme.color ?? Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This Month',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _SummaryItem(
                label: 'Scheduled',
                value: totalScheduled.toString(),
              ),
              _SummaryItem(
                label: 'Completed',
                value: totalCompleted.toString(),
              ),
              _SummaryItem(
                label: 'Rate',
                value: '${rate.toInt()}%',
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool _isScheduledForDay(Habit habit, int dayOfWeek) {
    switch (habit.frequencyType) {
      case 'daily':
        return true;
      case 'weekdays':
        return dayOfWeek >= 1 && dayOfWeek <= 5;
      case 'weekends':
        return dayOfWeek == 6 || dayOfWeek == 7;
      case 'custom':
        return habit.frequencyDays.contains(dayOfWeek);
      default:
        return true;
    }
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}
