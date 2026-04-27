import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  static String get fontFamily => GoogleFonts.cairo().fontFamily!;

  static TextStyle h1({required bool isDark}) => GoogleFonts.cairo(
    fontSize: 32,
    fontWeight: FontWeight.w900,
    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static TextStyle h2({required bool isDark}) => GoogleFonts.cairo(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static TextStyle h3({required bool isDark}) => GoogleFonts.cairo(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
  );

  static TextStyle bodyLarge({required bool isDark}) => GoogleFonts.cairo(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
  );

  static TextStyle bodyMedium({required bool isDark}) => GoogleFonts.cairo(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
  );

  static TextStyle bodySmall({required bool isDark}) => GoogleFonts.cairo(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
  );

  static TextStyle valueLabel({required bool isDark}) => GoogleFonts.outfit(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: isDark ? AppColors.darkAccent : AppColors.primaryMain,
  );

  static TextStyle buttonLabel({required bool isDark}) => GoogleFonts.cairo(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );
  
  static TextStyle hintStyle({required bool isDark}) => GoogleFonts.cairo(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: isDark ? AppColors.darkTextSecondary.withValues(alpha: 0.5) : AppColors.textSecondary.withValues(alpha: 0.5),
  );
}
