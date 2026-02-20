import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/animated_progress_ring.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/widgets/habit_card.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../../services/hive_service.dart';
import '../bloc/home_cubit.dart';
import '../../../habit/presentation/screens/habit_details_screen.dart';
import '../../../habit/presentation/screens/create_habit_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _animationController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<HomeCubit>().loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeState = context.watch<HomeCubit>().state;
    final theme = Theme.of(context);

    if (homeState.isLoading) {
      return const LoadingState();
    }

    // Start animations after first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_animationController.status == AnimationStatus.dismissed) {
        _animationController.forward();
      }
    });

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<HomeCubit>().loadData();
          },
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: _buildHeader(theme),
              ),

              // Overview Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: _AnimatedEntry(
                    animation: _animationController,
                    index: 0,
                    child: OverviewCard(
                      completed: homeState.completedToday,
                      total: homeState.totalHabits,
                      percentage: homeState.completionPercentage,
                      activeStreaks: homeState.activeStreaks,
                    ),
                  ),
                ),
              ),

              // Progress Rings Section
              if (homeState.habits.isNotEmpty)
                SliverToBoxAdapter(
                  child: _AnimatedEntry(
                    animation: _animationController,
                    index: 1,
                    child: _buildProgressRings(homeState),
                  ),
                ),

              // Today's Habits Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.sm,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Today\'s Habits',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${homeState.completedToday}/${homeState.totalHabits}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Habits List
              if (homeState.habits.isEmpty)
                SliverFillRemaining(
                  child: _buildEmptyState(),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final habit = homeState.habits[index];
                        final isCompleted = homeState.completions[habit.id] ?? false;

                        return _AnimatedEntry(
                          animation: _animationController,
                          index: index + 2,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: HabitCard(
                              habit: habit,
                              isCompleted: isCompleted,
                              index: index,
                              onToggle: () {
                                context
                                    .read<HomeCubit>()
                                    .toggleCompletion(habit.id);
                              },
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        HabitDetailsScreen(habitId: habit.id),
                                  ),
                                );
                                context.read<HomeCubit>().loadData();
                              },
                            ),
                          ),
                        );
                      },
                      childCount: homeState.habits.length,
                    ),
                  ),
                ),

              // Quote Card
              SliverToBoxAdapter(
                child: _AnimatedEntry(
                  animation: _animationController,
                  index: homeState.habits.length + 2,
                  child: _buildQuoteCard(theme),
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.xxl),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateHabitScreen(),
            ),
          ).then((_) {
            context.read<HomeCubit>().loadData();
          });
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    final now = DateTime.now();
    final greeting = _getGreeting();
    final dateStr = DateFormat('EEEE, MMMM d').format(now);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            dateStr,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  Widget _buildProgressRings(HomeState homeState) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: Theme.of(context).dividerTheme.color ?? Colors.grey.withOpacity(0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Progress',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(7, (index) {
                final day = DateTime.now().subtract(Duration(days: 6 - index));
                final dayName = DateFormat('E').format(day).substring(0, 1);
                final isToday = index == 6;
                
                // Calculate completion for this day
                int completed = 0;
                final dateStr = '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
                for (var habit in homeState.habits) {
                  if (HiveService.getCompletionForHabitAndDate(habit.id, dateStr) != null) {
                    completed++;
                  }
                }
                
                final percentage = homeState.totalHabits > 0
                    ? (completed / homeState.totalHabits) * 100
                    : 0.0;

                return _DayProgress(
                  day: dayName,
                  percentage: percentage,
                  isToday: isToday,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return EmptyState(
      icon: Icons.add_task,
      title: 'No Habits Yet',
      message: 'Start building better habits by adding your first one!',
      buttonText: 'Add Habit',
      onButtonPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const CreateHabitScreen(),
          ),
        ).then((_) {
          if (mounted) {
            context.read<HomeCubit>().loadData();
          }
        });
      },
    );
  }

  Widget _buildQuoteCard(ThemeData theme) {
    final quotes = [
      '"The secret of getting ahead is getting started." - Mark Twain',
      '"Success is the sum of small efforts repeated day in and day out." - Robert Collier',
      '"We are what we repeatedly do. Excellence, then, is not an act, but a habit." - Aristotle',
      '"Motivation is what gets you started. Habit is what keeps you going." - Jim Ryun',
    ];
    
    final quote = quotes[DateTime.now().day % quotes.length];

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withOpacity(0.1),
              AppColors.accent.withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(
                Icons.format_quote,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                quote,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayProgress extends StatelessWidget {
  final String day;
  final double percentage;
  final bool isToday;

  const _DayProgress({
    required this.day,
    required this.percentage,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    Color getColor() {
      if (percentage >= 100) return AppColors.success;
      if (percentage >= 75) return AppColors.successLight;
      if (percentage >= 50) return AppColors.warning;
      if (percentage >= 25) return AppColors.accent;
      if (percentage > 0) return AppColors.accentLight;
      return isDark ? AppColors.dividerDark : AppColors.dividerLight;
    }

    return Column(
      children: [
        AnimatedProgressRing(
          progress: percentage,
          size: 36,
          strokeWidth: 3,
          progressColor: getColor(),
          backgroundColor: isDark ? AppColors.dividerDark : AppColors.dividerLight,
        ),
        const SizedBox(height: 4),
        Text(
          day,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            color: isToday ? AppColors.primary : null,
          ),
        ),
      ],
    );
  }
}

class _AnimatedEntry extends StatefulWidget {
  final Animation<double> animation;
  final int index;
  final Widget child;

  const _AnimatedEntry({
    required this.animation,
    required this.index,
    required this.child,
  });

  @override
  State<_AnimatedEntry> createState() => _AnimatedEntryState();
}

class _AnimatedEntryState extends State<_AnimatedEntry> {
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: widget.animation,
        curve: Interval(
          (widget.index * 0.1).clamp(0.0, 0.5),
          ((widget.index * 0.1) + 0.5).clamp(0.5, 1.0),
          curve: Curves.easeOut,
        ),
      ),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: widget.animation,
        curve: Interval(
          (widget.index * 0.1).clamp(0.0, 0.5),
          ((widget.index * 0.1) + 0.5).clamp(0.5, 1.0),
          curve: Curves.easeOutCubic,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}
