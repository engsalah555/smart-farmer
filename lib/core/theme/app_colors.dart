import 'package:flutter/material.dart';

class AppColors {
  // --- Core Brand Colors ---
  // Brand hue: ~110 (green). Tinted neutrals converge here.
  static const Color primary = Color(0xFF69A14B);
  static const Color accent = Color(0xFF76C748);
  static const Color secondary = Color(0xFF4A9B2B);

  static const Color primaryDeep = Color(0xFF4F7A38);
  static const Color primaryMain = primary;
  static const Color primaryDark = Color(0xFF2D4520);
  static const Color deepGreen = primaryDeep;
  static const Color vibrantGreen = accent;

  // --- Tinted Neutral Palette (Restrained) ---
  // No pure #fff or #000. All neutrals carry subtle brand hue (chroma 0.005-0.01).
  static const Color neutralWhite = Color(0xFFFDFDFC);
  static const Color neutralBlack = Color(0xFF0C0C0B);
  static const Color white = neutralWhite;
  static const Color black = neutralBlack;
  static const Color neutralDark = Color(0xFF0A0D09); // Deep forest
  static const Color neutralSurface = Color(0xFF141714); // Dark surface

  // --- Light Mode Palette ---
  static const Color background = neutralWhite;
  static const Color surface = Color(0xFFF9FAF8); // Subtle warm tint
  static const Color cardLight = Color(0xFFF4F7F2); // Soft green tint

  // --- Text Colors ---
  static const Color textPrimary = Color(0xFF1A1D1A);
  static const Color textSecondary = Color(0xFF4A5248);
  static const Color textMuted = Color(0xFF6B7B6B);

  // --- Dark Mode Palette (Enhanced) ---
  static const Color darkBackground = Color(0xFF0F1410); // Deep rich forest-slate
  static const Color darkSurface = Color(0xFF19201B);    // Elevated surface
  static const Color darkCard = Color(0xFF1E2620);       // Rich card background
  static const Color darkBorder = Color(0xFF263028);     // Defined borders
  static const Color darkTextPrimary = Color(0xFFE8F2E9); // Minty soft white
  static const Color darkTextSecondary = Color(0xFF94A696); // Sage/Slate mix
  static const Color darkAccent = Color(0xFF2ECC71);     // Vibrant Action Green

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  // --- Semantic Status ---
  static const Color error = Color(0xFFDC4545);
  static const Color success = Color(0xFF2E9B5C);
  static const Color warning = Color(0xFFD99A0B);
  static const Color info = Color(0xFF3B7DD8);

  // --- Functional Methods ---
  static Color border(bool isDark) => isDark
      ? darkBorder
      : textMuted.withValues(alpha: 0.3);

  static Color getBackground(bool isDark) =>
      isDark ? darkBackground : background;
  static Color getSurface(bool isDark) => isDark ? darkSurface : surface;
  static Color getTextColor(bool isDark) =>
      isDark ? darkTextPrimary : textPrimary;
  static Color glass(bool isDark) =>
      isDark 
          ? const Color(0xFFFFFFFF).withValues(alpha: 0.05)
          : const Color(0xFF000000).withValues(alpha: 0.05);

  // --- Shimmer Colors ---
  static const Color shimmerBaseLight = Color(0xFFE2E8E1);
  static const Color shimmerHighlightLight = Color(0xFFF3F7F2);
  static const Color shimmerBaseDark = Color(0xFF2A332A);
  static const Color shimmerHighlightDark = Color(0xFF384538);

  static Color shimmerBase(bool isDark) => isDark ? shimmerBaseDark : shimmerBaseLight;
  static Color shimmerHighlight(bool isDark) => isDark ? shimmerHighlightDark : shimmerHighlightLight;
}

extension ThemeColors on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get primary => isDark ? AppColors.darkAccent : AppColors.primary;
  Color get accent => isDark ? AppColors.darkAccent : AppColors.accent;
  Color get secondary => AppColors.secondary;
  Color get background => AppColors.getBackground(isDark);
  Color get surface => AppColors.getSurface(isDark);
  Color get textPrimary => AppColors.getTextColor(isDark);
  Color get textSecondary => isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
  Color get textMuted => AppColors.textMuted;
  Color get error => AppColors.error;
  Color get success => AppColors.success;
  Color get warning => AppColors.warning;
  Color get info => AppColors.info;
  Color get border => AppColors.border(isDark);
  Color get darkAccent => AppColors.darkAccent;
  Color get primaryDeep => AppColors.primaryDeep;
  Color get primaryDark => AppColors.primaryDark;

  Color get darkBackground => AppColors.darkBackground;
  Color get darkSurface => AppColors.darkSurface;
  Color get darkBorder => AppColors.darkBorder;
  Color get darkTextPrimary => AppColors.darkTextPrimary;
  Color get darkTextSecondary => AppColors.darkTextSecondary;
  Color get darkCard => AppColors.darkCard;
  Color get cardLight => AppColors.cardLight;
  Color get cardBackground => isDark ? darkCard : cardLight;
  Color get textColor => isDark ? darkTextPrimary : textPrimary;

  Color get white => AppColors.neutralWhite;
  Color get black => AppColors.neutralBlack;
  Color get deepGreen => AppColors.primaryDeep;

  Color get shimmerBase => AppColors.shimmerBase(isDark);
  Color get shimmerHighlight => AppColors.shimmerHighlight(isDark);
  Color get glass => AppColors.glass(isDark);
  Color get backgroundColor => isDark ? AppColors.darkBackground : AppColors.background;
  Color get hintColor => Theme.of(this).hintColor;
}
