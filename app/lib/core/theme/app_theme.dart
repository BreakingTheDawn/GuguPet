import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.light(
          primary: AppColors.primary,
          onPrimary: AppColors.primaryForeground,
          secondary: AppColors.secondary,
          onSecondary: AppColors.secondaryForeground,
          surface: AppColors.background,
          onSurface: AppColors.foreground,
          error: AppColors.destructive,
          onError: AppColors.destructiveForeground,
        ),
        scaffoldBackgroundColor: AppColors.background,
        textTheme: const TextTheme(
          displayLarge: AppTypography.displayLarge,
          displayMedium: AppTypography.displayMedium,
          headlineLarge: AppTypography.headingLarge,
          headlineMedium: AppTypography.headingMedium,
          headlineSmall: AppTypography.headingSmall,
          bodyLarge: AppTypography.bodyLarge,
          bodyMedium: AppTypography.bodyMedium,
          bodySmall: AppTypography.bodySmall,
          labelLarge: AppTypography.labelLarge,
          labelMedium: AppTypography.labelMedium,
          labelSmall: AppTypography.labelSmall,
        ),
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.foreground,
        ),
        cardTheme: CardThemeData(
          color: AppColors.cardBackground,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.inputBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            borderSide: const BorderSide(color: AppColors.indigo500, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.primaryForeground,
            minimumSize: const Size(double.infinity, AppSpacing.buttonHeightMd),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.divider,
          thickness: 1,
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(
          primary: AppColors.primaryForeground,
          onPrimary: AppColors.primary,
          secondary: AppColors.secondary,
          onSecondary: AppColors.secondaryForeground,
          surface: const Color(0xFF1A1A2E),
          onSurface: AppColors.primaryForeground,
          error: AppColors.destructive,
          onError: AppColors.destructiveForeground,
        ),
        scaffoldBackgroundColor: const Color(0xFF1A1A2E),
        textTheme: TextTheme(
          displayLarge: AppTypography.displayLarge.copyWith(color: Colors.white),
          displayMedium: AppTypography.displayMedium.copyWith(color: Colors.white),
          headlineLarge: AppTypography.headingLarge.copyWith(color: Colors.white),
          headlineMedium: AppTypography.headingMedium.copyWith(color: Colors.white),
          headlineSmall: AppTypography.headingSmall.copyWith(color: Colors.white),
          bodyLarge: AppTypography.bodyLarge.copyWith(color: Colors.white70),
          bodyMedium: AppTypography.bodyMedium.copyWith(color: Colors.white70),
          bodySmall: AppTypography.bodySmall.copyWith(color: Colors.white60),
          labelLarge: AppTypography.labelLarge.copyWith(color: Colors.white),
          labelMedium: AppTypography.labelMedium.copyWith(color: Colors.white),
          labelSmall: AppTypography.labelSmall.copyWith(color: Colors.white),
        ),
      );
}
