import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static Color primary = const Color(0xFF7C4DFF);
  static Color primaryLight = const Color(0xFFA78BFA);
  static Color primaryDark = const Color(0xFF5B2DDB);

  static List<Color> primaryGradient = [
    const Color(0xFF7C4DFF),
    const Color(0xFFA855F7),
  ];

  static const Color accent = Color(0xFFF59E0B);
  static const Color accentLight = Color(0xFFFBBF24);

  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFF34D399);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFF87171);

  static const Color backgroundLight = Color(0xFFF7F7FB);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF17151E);
  static const Color textSecondaryLight = Color(0xFF52525B);
  static const Color textTertiaryLight = Color(0xFFA1A1AA);
  static const Color dividerLight = Color(0xFFE4E4E7);

  static const Color backgroundDark = Color(0xFF0B0A0F);
  static const Color surfaceDark = Color(0xFF17151E);
  static const Color cardDark = Color(0xFF17151E);
  static const Color textPrimaryDark = Color(0xFFFAFAFA);
  static const Color textSecondaryDark = Color(0xFFA1A1AA);
  static const Color textTertiaryDark = Color(0xFF71717A);
  static const Color dividerDark = Color(0xFF2A2833);

  static const List<Color> accentGradient = [
    Color(0xFFF59E0B),
    Color(0xFFF43F5E),
  ];

  static const List<Color> successGradient = [
    Color(0xFF34D399),
    Color(0xFF0EA5E9),
  ];

  static List<Color> heatmapLight = [
    const Color(0xFFE4E4E7),
    const Color(0xFFE9E3FF),
    const Color(0xFFB9A6F7),
    const Color(0xFF8B67F0),
    const Color(0xFF5B2DDB),
  ];

  static List<Color> heatmapDark = [
    const Color(0xFF2A2833),
    const Color(0xFF3B2E5C),
    const Color(0xFF5B3FA8),
    const Color(0xFF7C4DFF),
    const Color(0xFFA78BFA),
  ];

  static const List<Color> habitColors = [
    Color(0xFF8B5CF6),
    Color(0xFFF43F5E),
    Color(0xFF0EA5E9),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFEC4899),
    Color(0xFF06B6D4),
    Color(0xFFEF4444),
    Color(0xFF3B82F6),
    Color(0xFF84CC16),
  ];

  static void setTheme(AppThemeType themeType) {
    switch (themeType) {
      case AppThemeType.violet:
        primary = const Color(0xFF7C4DFF);
        primaryLight = const Color(0xFFA78BFA);
        primaryDark = const Color(0xFF5B2DDB);
        primaryGradient = [const Color(0xFF7C4DFF), const Color(0xFFA855F7)];
        heatmapLight = [
          const Color(0xFFE4E4E7),
          const Color(0xFFE9E3FF),
          const Color(0xFFB9A6F7),
          const Color(0xFF8B67F0),
          const Color(0xFF5B2DDB),
        ];
        heatmapDark = [
          const Color(0xFF2A2833),
          const Color(0xFF3B2E5C),
          const Color(0xFF5B3FA8),
          const Color(0xFF7C4DFF),
          const Color(0xFFA78BFA),
        ];
        break;
      case AppThemeType.sunset:
        primary = const Color(0xFFF0643E);
        primaryLight = const Color(0xFFFB923C);
        primaryDark = const Color(0xFFC2410C);
        primaryGradient = [const Color(0xFFF0643E), const Color(0xFFFBBF24)];
        heatmapLight = [
          const Color(0xFFE4E4E7),
          const Color(0xFFFEE7D8),
          const Color(0xFFFDB287),
          const Color(0xFFFB7A4B),
          const Color(0xFFC2410C),
        ];
        heatmapDark = [
          const Color(0xFF2A2833),
          const Color(0xFF4C2A1F),
          const Color(0xFF7C3A16),
          const Color(0xFFC2410C),
          const Color(0xFFF0643E),
        ];
        break;
      case AppThemeType.ocean:
        primary = const Color(0xFF0EA5E9);
        primaryLight = const Color(0xFF38BDF8);
        primaryDark = const Color(0xFF0369A1);
        primaryGradient = [const Color(0xFF0EA5E9), const Color(0xFF22D3EE)];
        heatmapLight = [
          const Color(0xFFE4E4E7),
          const Color(0xFFD6ECF9),
          const Color(0xFF7FC8EC),
          const Color(0xFF3AA5DB),
          const Color(0xFF0677A8),
        ];
        heatmapDark = [
          const Color(0xFF2A2833),
          const Color(0xFF14394A),
          const Color(0xFF155E78),
          const Color(0xFF0E7490),
          const Color(0xFF22D3EE),
        ];
        break;
    }
  }
}

enum AppThemeType {
  violet,
  sunset,
  ocean,
}

extension AppThemeTypeExtension on AppThemeType {
  String get displayName {
    switch (this) {
      case AppThemeType.violet:
        return 'Violet';
      case AppThemeType.sunset:
        return 'Sunset';
      case AppThemeType.ocean:
        return 'Ocean';
    }
  }

  Color get color {
    switch (this) {
      case AppThemeType.violet:
        return const Color(0xFF7C4DFF);
      case AppThemeType.sunset:
        return const Color(0xFFF0643E);
      case AppThemeType.ocean:
        return const Color(0xFF0EA5E9);
    }
  }
}

class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

class AppRadius {
  AppRadius._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double full = 100.0;
}

class AppDurations {
  AppDurations._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration pageTransition = Duration(milliseconds: 350);
  static const Duration stagger = Duration(milliseconds: 50);
}