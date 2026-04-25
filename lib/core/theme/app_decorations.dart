import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppDecorations {
  static const double headerRadius = 40.0;
  static const double cardRadius = 24.0;
  static const double inputRadius = 16.0;
  static const double buttonRadius = 20.0;

  static List<BoxShadow> softShadow(bool isDark) => [
    BoxShadow(
      color: isDark
          ? AppColors.neutralBlack.withValues(alpha: 0.4)
          : AppColors.textMuted.withValues(alpha: 0.08),
      blurRadius: 20,
      spreadRadius: -5,
      offset: const Offset(0, 10),
    ),
  ];

  static List<BoxShadow> premiumShadow(bool isDark) => [
    BoxShadow(
      color: isDark
          ? AppColors.primaryDark.withValues(alpha: 0.4)
          : AppColors.primary.withValues(alpha: 0.12),
      blurRadius: 30,
      spreadRadius: -5,
      offset: const Offset(0, 15),
    ),
  ];

  static BoxDecoration cardDecoration({
    required bool isDark,
    double radius = cardRadius,
    bool elevated = false,
  }) =>
      BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: AppColors.border(isDark),
          width: 1.0,
        ),
        boxShadow: elevated ? softShadow(isDark) : null,
      );

  static BoxDecoration inputDecoration({required bool isDark, double radius = inputRadius}) =>
      BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: AppColors.border(isDark),
          width: 1.0,
        ),
      );

  static BoxDecoration pillDecoration({required bool isDark, Color? fillColor}) =>
      BoxDecoration(
        color: fillColor ?? (isDark ? AppColors.darkSurface : AppColors.surface),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: AppColors.border(isDark),
          width: 1,
        ),
      );

  static BoxDecoration primaryHeaderDecoration() => const BoxDecoration(
    color: AppColors.primary,
    borderRadius: BorderRadius.vertical(
      bottom: Radius.circular(headerRadius),
    ),
  );

  static BoxDecoration whiteSheetDecoration() => BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.vertical(
      top: Radius.circular(headerRadius - 8),
    ),
  );

  // Backward compatibility - solid card without glassmorphism
  static BoxDecoration premiumCardDecoration({required bool isDark, double radius = cardRadius}) =>
      BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: AppColors.border(isDark),
          width: 1.0,
        ),
        boxShadow: softShadow(isDark),
      );

  static BoxDecoration premiumPillDecoration({required bool isDark, double radius = 25.0}) =>
      BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: AppColors.border(isDark),
          width: 1,
        ),
      );

  static BoxDecoration premiumGlassDecorationV2({required bool isDark, double radius = 24.0}) =>
      BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: AppColors.border(isDark),
          width: 1.5,
        ),
      );

  static BoxDecoration selectedDecoration({double radius = 20.0}) =>
      BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(radius),
      );

  // LinearGradient for button/text fills
  static LinearGradient primaryGradient = const LinearGradient(
    colors: [AppColors.primaryDeep, AppColors.primaryMain],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient accentGradient = const LinearGradient(
    colors: [AppColors.primaryMain, AppColors.primaryDark],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );
}