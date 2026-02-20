import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../models/habit.dart';
import '../../services/streak_service.dart';

class HabitCard extends StatefulWidget {
  final Habit habit;
  final bool isCompleted;
  final VoidCallback onToggle;
  final VoidCallback? onTap;
  final int index;

  const HabitCard({
    super.key,
    required this.habit,
    required this.isCompleted,
    required this.onToggle,
    this.onTap,
    this.index = 0,
  });

  @override
  State<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<HabitCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleToggle() {
    if (!widget.isCompleted) {
      _controller.forward().then((_) {
        _controller.reverse();
      });
    }
    widget.onToggle();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final habitColor = Color(widget.habit.colorValue);
    final streak = StreakService.calculateCurrentStreak(widget.habit);

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: AnimatedContainer(
        duration: AppDurations.normal,
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: widget.isCompleted
              ? habitColor.withOpacity(0.1)
              : theme.cardTheme.color,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: widget.isCompleted
                ? habitColor.withOpacity(0.3)
                : theme.dividerTheme.color ?? Colors.grey.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: (theme.brightness == Brightness.dark
                      ? Colors.black
                      : Colors.grey)
                  .withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  // Completion toggle - separate tap area
                  GestureDetector(
                    onTap: _handleToggle,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: _CompletionToggle(
                        isCompleted: widget.isCompleted,
                        color: habitColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),

                  // Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: habitColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(
                      _getIconData(widget.habit.icon),
                      color: habitColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.habit.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            decoration: widget.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            color: widget.isCompleted
                                ? theme.textTheme.bodyMedium?.color
                                : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _FrequencyChip(
                              frequencyType: widget.habit.frequencyType,
                              color: habitColor,
                            ),
                            if (streak > 0) ...[
                              const SizedBox(width: AppSpacing.sm),
                              _StreakBadge(streak: streak, color: habitColor),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Arrow
                  Icon(
                    Icons.chevron_right,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ],
              ),
            ),
          ),
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

class _CompletionToggle extends StatelessWidget {
  final bool isCompleted;
  final Color color;

  const _CompletionToggle({
    required this.isCompleted,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppDurations.normal,
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: isCompleted ? color : Colors.transparent,
        border: Border.all(
          color: isCompleted ? color : Colors.grey.withOpacity(0.5),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: isCompleted
          ? const Icon(
              Icons.check,
              color: Colors.white,
              size: 18,
            )
          : null,
    );
  }
}

class _FrequencyChip extends StatelessWidget {
  final String frequencyType;
  final Color color;

  const _FrequencyChip({
    required this.frequencyType,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    String label;
    switch (frequencyType) {
      case 'daily':
        label = 'Daily';
        break;
      case 'weekdays':
        label = 'Weekdays';
        break;
      case 'weekends':
        label = 'Weekends';
        break;
      case 'custom':
        label = 'Custom';
        break;
      default:
        label = frequencyType;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.xs),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}

class _StreakBadge extends StatelessWidget {
  final int streak;
  final Color color;

  const _StreakBadge({
    required this.streak,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.8),
            color,
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.xs),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.local_fire_department,
            color: Colors.white,
            size: 12,
          ),
          const SizedBox(width: 2),
          Text(
            '$streak',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
