import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/constants.dart';

class GlassmorphicSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final VoidCallback? onSearchPressed;
  final VoidCallback? onFilterPressed;
  final String hintText;

  const GlassmorphicSearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.onSearchPressed,
    this.onFilterPressed,
    this.hintText = 'ابحث عن منتجات، متاجر، أو مزارع...',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fillColor = isDark
        ? AppColors.darkCard.withValues(alpha: 0.7)
        : AppColors.surface.withValues(alpha: 0.9);
    final borderColor = AppColors.border(isDark);
    final textColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    final hintColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: fillColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor, width: 1.5),
                  ),
                  child: TextField(
                    controller: controller,
                    onChanged: onChanged,
                    style: TextStyle(color: textColor, fontSize: 15),
                    decoration: InputDecoration(
                      hintText: hintText,
                      hintStyle: TextStyle(color: hintColor, fontSize: 14),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: context.primary,
                        size: 22,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          _buildActionButton(
            context,
            icon: Icons.tune_rounded,
            onTap: onFilterPressed,
            isPrimary: true,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback? onTap,
    bool isPrimary = false,
  }) {
    final fillColor = isPrimary ? context.primary : context.surface;
    final borderColor = AppColors.border(context.isDark);
    final iconColor = isPrimary ? AppColors.neutralWhite : context.textColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        width: 52,
        decoration: BoxDecoration(
          color: isPrimary ? context.primary : fillColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }
}
