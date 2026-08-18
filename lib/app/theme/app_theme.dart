import 'package:easy_ride/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,

    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.secondary,

      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      error: AppColors.error,

      surface: AppColors.lightSurface,
      onSurface: AppColors.lightText,
    ),

    scaffoldBackgroundColor: AppColors.lightBackground,
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,

    colorScheme: ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: AppColors.secondary,

      secondary: AppColors.secondary,
      onSecondary: Colors.white,

      error: AppColors.error,

      surface: AppColors.darkSurface,
      onSurface: AppColors.darkText,
    ),

    scaffoldBackgroundColor: AppColors.darkBackground,
  );
}
