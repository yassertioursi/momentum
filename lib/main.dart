import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'domain/repositories/habit_repository.dart';
import 'domain/repositories/settings_repository.dart';
import 'domain/services/streak_service.dart';
import 'data/datasources/local/hive_service.dart';
import 'data/datasources/local/notification_service.dart';
import 'features/theme/presentation/bloc/app_theme_cubit.dart';
import 'features/home/presentation/bloc/home_cubit.dart';
import 'features/onboarding/presentation/screens/splash_screen.dart';
import 'features/onboarding/presentation/screens/onboarding_screen.dart';
import 'features/home/presentation/screens/main_navigation.dart';
import 'injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );

  await HiveService.init();
  setupDependencies();
  try {
    await NotificationService.init();
  } catch (e) {
    debugPrint('Notification init skipped: $e');
  }

  final settings = sl.get<SettingsRepository>().getSettings();
  AppColors.setTheme(settings.themeType);

  runApp(const MomentumApp());
}

class MomentumApp extends StatelessWidget {
  const MomentumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AppThemeCubit>(
          create: (_) => AppThemeCubit(
            settingsRepository: sl.get<SettingsRepository>(),
          ),
        ),
        BlocProvider<HomeCubit>(
          create: (_) => HomeCubit(
            habitRepository: sl.get<HabitRepository>(),
            streakService: sl.get<StreakService>(),
          )..loadData(),
        ),
      ],
      child: const _AppRoot(),
    );
  }
}

class _AppRoot extends StatelessWidget {
  const _AppRoot();

  @override
  Widget build(BuildContext context) {
    final themeState = context.watch<AppThemeCubit>().state;

    return MaterialApp(
      title: 'Momentum',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const AppEntryPoint(),
    );
  }
}

class AppEntryPoint extends StatefulWidget {
  const AppEntryPoint({super.key});

  @override
  State<AppEntryPoint> createState() => _AppEntryPointState();
}

class _AppEntryPointState extends State<AppEntryPoint> {
  bool _showSplash = true;
  bool _showOnboarding = false;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  void _checkOnboarding() {
    final settings = context.read<AppThemeCubit>().settings;
    if (!settings.hasCompletedOnboarding) {
      setState(() {
        _showOnboarding = true;
      });
    }
  }

  void _onSplashComplete() {
    setState(() {
      _showSplash = false;
    });
  }

  void _onOnboardingComplete() async {
    await context.read<AppThemeCubit>().completeOnboarding();
    if (mounted) {
      setState(() {
        _showOnboarding = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return SplashScreen(onComplete: _onSplashComplete);
    }

    if (_showOnboarding) {
      return OnboardingScreen(onComplete: _onOnboardingComplete);
    }

    return const MainNavigation();
  }
}