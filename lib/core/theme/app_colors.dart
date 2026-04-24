import 'package:flutter/material.dart';

class AppColors {
  // --- Core Brand Colors (Pro Max) ---
  static const Color primary = Color(0xFF69A14B); // Fresh Green (Brand Primary)
  static const Color accent = Color(0xFF76C748); // Vibrant Green
  static const Color secondary = Color(0xFF4A9B2B); // Natural Green

  static const Color primaryDeep = Color(0xFF4F7A38);
  static const Color primaryMain = primary;
  static const Color primaryDark = Color(0xFF2D4520);

  // --- Aliases ---
  static const Color deepGreen = primary;
  static const Color vibrantGreen = accent;

  // --- Neutral Palette (Unification) ---
  static const Color background = Color(0xFFFFFFFF); // Pure White Background
  static const Color surface = Colors.white; // Pure White for Light Surface
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color cardLight = Color(
    0xFFF4F8F4,
  ); // Clearer soft green tint to stand out from white background

  // --- Text Colors ---
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);

  // --- Dark Mode Palette (Deep Forest Black) ---
  static const Color darkBackground = Color(0xFF0A110A); // Deep Forest Black
  static const Color darkSurface = Color(0xFF141A14); // Dark Leaf Surface
  static const Color darkBorder = Color(0xFF1D261D);
  static const Color darkTextPrimary = Color(0xFFE8EFE8); // Minty Soft White
  static const Color darkTextSecondary = Color(0xFF94A38F); // Sage Grey
  static const Color darkCard = Color(
    0xFF1E281E,
  ); // Lighter to be more distinct from background

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  // --- Semantic Status ---
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // --- Functional Methods ---
  static Color glass(bool isDark) => isDark
      ? Colors.white.withValues(alpha: 0.05)
      : Colors.white.withValues(alpha: 0.4);

  static Color border(bool isDark) => isDark
      ? Colors.white.withValues(alpha: 0.1)
      : Colors.grey.withValues(alpha: 0.2);

  static Color getBackground(bool isDark) =>
      isDark ? darkBackground : background;
  static Color getSurface(bool isDark) => isDark ? darkSurface : surface;
  static Color getTextColor(bool isDark) =>
      isDark ? darkTextPrimary : textPrimary;
}

extension ThemeColors on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get primary => AppColors.primary;
  Color get accent => AppColors.accent;
  Color get secondary => AppColors.secondary;
  Color get background => AppColors.getBackground(isDark);
  Color get surface => AppColors.getSurface(isDark);
  Color get textPrimary => AppColors.getTextColor(isDark);
  Color get textSecondary => AppColors.textSecondary;
  Color get textMuted => AppColors.textMuted;
  Color get error => AppColors.error;
  Color get success => AppColors.success;
  Color get warning => AppColors.warning;
  Color get info => AppColors.info;
  Color get border => AppColors.border(isDark);
  Color get glass => AppColors.glass(isDark);

  Color get deepGreen => AppColors.deepGreen;
  Color get vibrantGreen => AppColors.vibrantGreen;

  Color get darkBackground => AppColors.darkBackground;
  Color get darkSurface => AppColors.darkSurface;
  Color get darkBorder => AppColors.darkBorder;
  Color get darkTextPrimary => AppColors.darkTextPrimary;
  Color get darkTextSecondary => AppColors.darkTextSecondary;
  Color get darkCard => AppColors.darkCard;

  Color get cardLight => AppColors.cardLight;

  Color get primaryDeep => AppColors.primaryDeep;
  Color get primaryMain => AppColors.primaryMain;
  Color get primaryDark => AppColors.primaryDark;

  Color get white => AppColors.white;
  Color get black => AppColors.black;

  Color get cardBackground => isDark ? darkCard : cardLight;
}
