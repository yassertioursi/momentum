import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../../models/habit.dart';
import '../../../../services/streak_service.dart';
import '../bloc/analytics_cubit.dart';
import '../../../home/presentation/bloc/home_cubit.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> with WidgetsBindingObserver {
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
    // Watch home cubit so analytics rebuilds when habits change
    final homeState = context.watch<HomeCubit>().state;
    final timeRange = context.watch<AnalyticsCubit>().state.timeRange;

    final theme = Theme.of(context);
    final habits = homeState.habits;

    // Calculate overall stats
    int totalHabits = habits.length;
    int totalCompletions = 0;
    double avgCompletionRate = 0;
    int totalCurrentStreaks = 0;

    for (var habit in habits) {
      totalCompletions += StreakService.getTotalCompletions(habit.id);
      avgCompletionRate += StreakService.getCompletionRate(habit.id, days: timeRange);
      totalCurrentStreaks += StreakService.calculateCurrentStreak(habit);
    }

    if (totalHabits > 0) {
      avgCompletionRate /= totalHabits;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time Range Selector
            Row(
              children: [
                _TimeRangeChip(
                  label: '7 Days',
                  isSelected: timeRange == 7,
                  onTap: () => context.read<AnalyticsCubit>().setTimeRange(7),
                ),
                const SizedBox(width: AppSpacing.sm),
                _TimeRangeChip(
                  label: '30 Days',
                  isSelected: timeRange == 30,
                  onTap: () => context.read<AnalyticsCubit>().setTimeRange(30),
                ),
                const SizedBox(width: AppSpacing.sm),
                _TimeRangeChip(
                  label: '90 Days',
                  isSelected: timeRange == 90,
                  onTap: () => context.read<AnalyticsCubit>().setTimeRange(90),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Overview Stats
            Text(
              'Overview',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Total Habits',
                    value: totalHabits.toString(),
                    icon: Icons.list_alt,
                    iconColor: AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: StatCard(
                    title: 'Completions',
                    value: totalCompletions.toString(),
                    icon: Icons.check_circle,
                    iconColor: AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Avg. Rate',
                    value: '${avgCompletionRate.toInt()}%',
                    icon: Icons.trending_up,
                    iconColor: AppColors.warning,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: StatCard(
                    title: 'Active Streaks',
                    value: totalCurrentStreaks.toString(),
                    icon: Icons.local_fire_department,
                    iconColor: AppColors.accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Habit Performance
            Text(
              'Habit Performance',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (habits.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Text(
                    'No habits to analyze',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              )
            else
              ...habits.map((habit) => _HabitPerformanceCard(
                    habit: habit,
                    days: timeRange,
                  )),
          ],
        ),
      ),
    );
  }
}

class _TimeRangeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TimeRangeChip({
    required this.label,
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
              ? AppColors.primary
              : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.dividerDark : AppColors.dividerLight),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : null,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _HabitPerformanceCard extends StatelessWidget {
  final Habit habit;
  final int days;

  const _HabitPerformanceCard({
    required this.habit,
    required this.days,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final habitColor = Color(habit.colorValue);
    final completionRate = StreakService.getCompletionRate(habit.id, days: days);
    final currentStreak = StreakService.calculateCurrentStreak(habit);
    final longestStreak = StreakService.calculateLongestStreak(habit);
    final totalCompletions = StreakService.getTotalCompletions(habit.id);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: habitColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  _getIconData(habit.icon),
                  color: habitColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  habit.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: habitColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                ),
                child: Text(
                  '${completionRate.toInt()}%',
                  style: TextStyle(
                    color: habitColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          
          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: LinearProgressIndicator(
              value: completionRate / 100,
              backgroundColor: isDark ? AppColors.dividerDark : AppColors.dividerLight,
              valueColor: AlwaysStoppedAnimation<Color>(habitColor),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MiniStat(
                icon: Icons.local_fire_department,
                iconColor: AppColors.accent,
                value: currentStreak.toString(),
                label: 'Current',
              ),
              _MiniStat(
                icon: Icons.emoji_events,
                iconColor: AppColors.warning,
                value: longestStreak.toString(),
                label: 'Best',
              ),
              _MiniStat(
                icon: Icons.check_circle,
                iconColor: AppColors.success,
                value: totalCompletions.toString(),
                label: 'Total',
              ),
            ],
          ),
        ],
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

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _MiniStat({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 16),
            const SizedBox(width: 4),
            Text(
              value,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}
