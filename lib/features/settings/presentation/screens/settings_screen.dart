import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../services/hive_service.dart';
import '../../../../services/notification_service.dart';
import '../../../theme/presentation/bloc/app_theme_cubit.dart';
import '../../../home/presentation/bloc/home_cubit.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    _notificationsEnabled = HiveService.getSettings().notificationsEnabled;
  }

  Future<void> _requestNotificationPermission() async {
    await NotificationService.requestPermission();
  }

  @override
  Widget build(BuildContext context) {
    final themeState = context.watch<AppThemeCubit>().state;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _SectionHeader(title: 'Appearance'),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Switch between light and dark theme'),
            value: themeState.isDarkMode,
            onChanged: (value) {
              context.read<AppThemeCubit>().setDarkMode(value);
            },
            secondary: Icon(
              themeState.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: AppColors.primary,
            ),
          ),

          ListTile(
            title: const Text('Theme Color'),
            subtitle: const Text('Choose your preferred color'),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showThemeColorPicker(context),
          ),
          const Divider(),

          _SectionHeader(title: 'Notifications'),
          SwitchListTile(
            title: const Text('Enable Reminders'),
            subtitle: const Text('Receive daily habit reminders'),
            value: _notificationsEnabled,
            onChanged: (value) async {
              if (value) {
                await _requestNotificationPermission();
              }
              setState(() {
                _notificationsEnabled = value;
              });
              final settings = HiveService.getSettings();
              await HiveService.saveSettings(
                settings.copyWith(notificationsEnabled: value),
              );
              if (!value) {
                await NotificationService.cancelAllNotifications();
              }
            },
            secondary: Icon(
              Icons.notifications,
              color: AppColors.primary,
            ),
          ),
          const Divider(),

          _SectionHeader(title: 'Data'),
          ListTile(
            leading: Icon(
              Icons.delete_outline,
              color: AppColors.error,
            ),
            title: const Text('Clear All Data'),
            subtitle: const Text('Delete all habits and progress'),
            onTap: () => _showClearDataDialog(context),
          ),
          const Divider(),

          _SectionHeader(title: 'About'),
          ListTile(
            leading: Icon(
              Icons.info_outline,
              color: AppColors.primary,
            ),
            title: const Text('Version'),
            subtitle: const Text('1.0.0'),
          ),
          ListTile(
            leading: Icon(
              Icons.favorite,
              color: AppColors.primary,
            ),
            title: const Text('Momentum'),
            subtitle: const Text('Build better habits, one day at a time.'),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  void _showThemeColorPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return BlocBuilder<AppThemeCubit, ThemeState>(
          builder: (context, themeState) {
            final currentTheme = themeState.themeType;

            return Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choose Theme Color',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: AppThemeType.values.map((themeType) {
                      final isSelected = currentTheme == themeType;
                      return GestureDetector(
                        onTap: () {
                          context
                              .read<AppThemeCubit>()
                              .setThemeType(themeType);
                          Navigator.pop(context);
                        },
                        child: AnimatedContainer(
                          duration: AppDurations.fast,
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: themeType.color,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.transparent,
                              width: 3,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: themeType.color.withOpacity(0.5),
                                      blurRadius: 12,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                : null,
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 32,
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: AppThemeType.values.map((themeType) {
                      return Text(
                        themeType.displayName,
                        style: Theme.of(context).textTheme.bodyMedium,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all your habits and progress. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await HiveService.habitsBox.clear();
              await HiveService.completionsBox.clear();

              if (context.mounted) {
                Navigator.pop(context);
                context.read<HomeCubit>().loadData();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('All data cleared'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}