import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppDecorations {
  // --- Spacing & Radii ---
  static const double headerRadius = 40.0;
  static const double cardRadius = 24.0;
  static const double inputRadius = 16.0;
  static const double buttonRadius = 20.0;

  // --- Gradients ---
  static LinearGradient get primaryGradient => const LinearGradient(
    colors: [AppColors.primaryDeep, AppColors.primaryMain],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get accentGradient => const LinearGradient(
    colors: [AppColors.primaryMain, AppColors.primaryDark],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

  static LinearGradient glassGradient(bool isDark) => LinearGradient(
    colors: [
      Colors.white.withValues(alpha: isDark ? 0.05 : 0.25),
      AppColors.primary.withValues(alpha: isDark ? 0.02 : 0.05),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // --- Shadows ---
  static List<BoxShadow> softShadow(bool isDark) => [
    BoxShadow(
      color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.05),
      blurRadius: 20,
      spreadRadius: -5,
      offset: const Offset(0, 10),
    ),
  ];

  static List<BoxShadow> premiumShadow(bool isDark) => [
    BoxShadow(
      color: isDark ? AppColors.primaryDark.withValues(alpha: 0.5) : AppColors.primaryMain.withValues(alpha: 0.15),
      blurRadius: 30,
      spreadRadius: -5,
      offset: const Offset(0, 15),
    ),
  ];

  // --- Containers & Decorations ---
  static BoxDecoration glassDecoration(bool isDark, {double radius = cardRadius}) =>
      BoxDecoration(
        color: AppColors.glass(isDark),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: AppColors.border(isDark),
          width: 1.5,
        ),
      );

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

  static BoxDecoration primaryHeaderDecoration() => const BoxDecoration(
    color: AppColors.primary,
    borderRadius: BorderRadius.vertical(
      bottom: Radius.circular(headerRadius),
    ),
  );

  static BoxDecoration whiteSheetDecoration() => const BoxDecoration(
    color: AppColors.background,
    borderRadius: BorderRadius.vertical(
      top: Radius.circular(headerRadius - 8),
    ),
  );

  static BoxDecoration selectedGradientDecoration({double radius = 20.0}) =>
      BoxDecoration(
        gradient: primaryGradient,
        borderRadius: BorderRadius.circular(radius),
      );

  static BoxDecoration premiumPillDecoration({required bool isDark, double radius = 25.0}) => BoxDecoration(
    color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(
      color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
      width: 1,
    ),
  );

  static BoxDecoration premiumGlassDecorationV2({required bool isDark, double radius = 24.0}) => BoxDecoration(
    color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(
      color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.04),
      width: 1.5,
    ),
  );

  // --- Background Decorating Widgets ---
  static List<Widget> buildMeshBlobs(BoxConstraints constraints) {
    return [
      Positioned(
        top: -constraints.maxHeight * 0.2,
        right: -constraints.maxWidth * 0.1,
        child: _Blob(
          size: constraints.maxHeight * 0.8,
          color: AppColors.primary.withAlpha(77), // 0.3 opacity
        ),
      ),
      Positioned(
        bottom: -constraints.maxHeight * 0.1,
        left: -constraints.maxWidth * 0.2,
        child: _Blob(
          size: constraints.maxHeight * 0.7,
          color: AppColors.accent.withAlpha(51), // 0.2 opacity
        ),
      ),
      Positioned(
        top: constraints.maxHeight * 0.1,
        left: constraints.maxWidth * 0.3,
        child: _Blob(
          size: constraints.maxHeight * 0.5,
          color: const Color(0xFFC6FF00).withAlpha(38), // 0.15 opacity
        ),
      ),
    ];
  }
}

class _Blob extends StatelessWidget {
  final double size;
  final Color color;
  const _Blob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withAlpha(255), // Fully opaque for the shadow source
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: size * 0.6,
            spreadRadius: size * 0.1,
          ),
        ],
      ),
    );
  }
}
