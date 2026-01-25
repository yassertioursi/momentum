import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/animated_progress_ring.dart';
import '../../../../domain/entities/habit.dart';
import '../../../../domain/repositories/habit_repository.dart';
import '../../../../domain/services/streak_service.dart';
import '../../../../injection_container.dart';
import 'create_habit_screen.dart';

class HabitDetailsScreen extends StatefulWidget {
  final String habitId;

  const HabitDetailsScreen({super.key, required this.habitId});

  @override
  State<HabitDetailsScreen> createState() => _HabitDetailsScreenState();
}

class _HabitDetailsScreenState extends State<HabitDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final habit = sl.get<HabitRepository>().getHabit(widget.habitId);

    if (habit == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Habit not found')),
      );
    }

    final streakService = sl.get<StreakService>();
    final habitColor = Color(habit.colorValue);
    final currentStreak = streakService.calculateCurrentStreak(habit);
    final longestStreak = streakService.calculateLongestStreak(habit);
    final totalCompletions = streakService.getTotalCompletions(widget.habitId);
    final completionRate = streakService.getCompletionRate(widget.habitId);
    final weeklyData = streakService.getWeeklyCompletions(widget.habitId);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      habitColor,
                      habitColor.withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getIconData(habit.icon),
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        habit.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CreateHabitScreen(habitToEdit: habit),
                    ),
                  );
                  if (mounted) {
                    setState(() {});
                  }
                },
              ),
            ],
          ),

          // Stats Grid
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Completion Rate Ring
                  Center(
                    child: AnimatedProgressRing(
                      progress: completionRate,
                      size: 120,
                      strokeWidth: 12,
                      progressColor: habitColor,
                      gradientColors: [habitColor, habitColor.withOpacity(0.7)],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${completionRate.toInt()}%',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Rate',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Stats Row
                  Row(
                    children: [
                      Expanded(
                        child: _StatItem(
                          icon: Icons.local_fire_department,
                          iconColor: AppColors.accent,
                          value: currentStreak.toString(),
                          label: 'Current Streak',
                        ),
                      ),
                      Expanded(
                        child: _StatItem(
                          icon: Icons.emoji_events,
                          iconColor: AppColors.warning,
                          value: longestStreak.toString(),
                          label: 'Longest Streak',
                        ),
                      ),
                      Expanded(
                        child: _StatItem(
                          icon: Icons.check_circle,
                          iconColor: AppColors.success,
                          value: totalCompletions.toString(),
                          label: 'Total Done',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Weekly Progress
                  Text(
                    'This Week',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _WeeklyChart(
                    data: weeklyData,
                    color: habitColor,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Details
                  if (habit.notes != null && habit.notes!.isNotEmpty) ...[
                    Text(
                      'Notes',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: theme.cardTheme.color,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: theme.dividerTheme.color ?? Colors.grey.withOpacity(0.2),
                        ),
                      ),
                      child: Text(habit.notes!),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],

                  // Frequency Info
                  Text(
                    'Schedule',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: theme.dividerTheme.color ?? Colors.grey.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.schedule, color: habitColor),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          _getFrequencyText(habit),
                          style: theme.textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Reminder Info
                  if (habit.reminderEnabled) ...[
                    Text(
                      'Reminder',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: theme.cardTheme.color,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: theme.dividerTheme.color ?? Colors.grey.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.notifications_active, color: habitColor),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            habit.reminderTime ?? 'Not set',
                            style: theme.textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Created Date
                  const SizedBox(height: AppSpacing.lg),
                  Center(
                    child: Text(
                      'Created ${DateFormat('MMMM d, yyyy').format(habit.createdAt)}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
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

  String _getFrequencyText(Habit habit) {
    switch (habit.frequencyType) {
      case 'daily':
        return 'Every day';
      case 'weekdays':
        return 'Weekdays (Mon-Fri)';
      case 'weekends':
        return 'Weekends (Sat-Sun)';
      case 'custom':
        return 'Custom: ${_getDaysText(habit.frequencyDays)}';
      default:
        return habit.frequencyType;
    }
  }

  String _getDaysText(List<int> days) {
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days.map((d) => dayNames[d - 1]).join(', ');
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  final Map<int, int> data;
  final Color color;

  const _WeeklyChart({
    required this.data,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Container(
      height: 100,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(7, (index) {
          final dayOfWeek = index + 1;
          final isCompleted = data[dayOfWeek] == 1;
          final isToday = dayOfWeek == DateTime.now().weekday;

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Container(
                  width: 32,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? color
                        : (isDark ? AppColors.dividerDark : AppColors.dividerLight),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                dayLabels[index],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  color: isToday ? color : null,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
