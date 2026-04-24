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
  static const Color cardLight = Color(0xFFF5F5F5);

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
  static const Color darkCard = Color(0xFF141A14);

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
