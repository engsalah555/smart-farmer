import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_typography.dart';

class SectionLabel extends StatelessWidget {
  final String label;
  final IconData? icon;
  const SectionLabel(this.label, {super.key, this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 22, color: context.primary),
            const SizedBox(width: 10),
          ],
          Text(
            label,
            style: AppTypography.h3(isDark: context.isDark).copyWith(
              fontSize: 16,
              letterSpacing: 0.5,
              fontWeight: FontWeight.w900,
              color: context.textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class StyledField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final String? hint;
  final TextInputType keyboard;
  final IconData icon;
  final bool isDark;
  final ValueChanged<String>? onChanged;

  const StyledField({
    super.key,
    required this.ctrl,
    required this.label,
    this.hint,
    required this.keyboard,
    required this.icon,
    required this.isDark,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 4, bottom: 10),
          child: Text(
            label,
            style: AppTypography.bodySmall(isDark: isDark).copyWith(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
        ),
        Container(
          decoration: AppDecorations.inputDecoration(isDark: isDark),
          child: TextField(
            controller: ctrl,
            keyboardType: keyboard,
            onChanged: onChanged,
            style: AppTypography.valueLabel(isDark: isDark).copyWith(
              color: isDark ? Colors.white : AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: isDark ? Colors.white24 : Colors.grey.shade400,
                fontSize: 14,
              ),
              prefixIcon: Icon(icon, color: context.primary, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDecorations.inputRadius),
                borderSide: BorderSide(color: context.primary, width: 2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class NutrientField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final String info;
  final Color color;
  final bool isDark;

  const NutrientField({
    super.key,
    required this.ctrl,
    required this.label,
    required this.info,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _showInfo(context),
          child: Row(
            children: [
              Text(
                label,
                style: AppTypography.bodySmall(isDark: isDark).copyWith(
                  color: color,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.info_outline,
                size: 14,
                color: color.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: AppDecorations.inputDecoration(
            isDark: isDark,
          ).copyWith(color: isDark ? AppColors.darkCard : Colors.white),
          child: TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: AppTypography.valueLabel(isDark: isDark).copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: '0',
              border: InputBorder.none,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: color, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'ppm (جزء في المليون)',
            style: AppTypography.bodySmall(isDark: isDark).copyWith(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted,
            ),
          ),
        ),
      ],
    );
  }

  void _showInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDecorations.cardRadius),
        ),
        title: Row(
          children: [
            Icon(Icons.info_outline, color: color),
            const SizedBox(width: 12),
            Text(
              label,
              style: AppTypography.h3(isDark: isDark).copyWith(color: color),
            ),
          ],
        ),
        content: Text(
          info,
          style: AppTypography.bodyMedium(isDark: isDark).copyWith(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'حسناً',
              style: AppTypography.bodyMedium(
                isDark: isDark,
              ).copyWith(color: context.primary, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class NPKMini extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  const NPKMini(this.label, this.value, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppDecorations.cardRadius - 8),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Column(
          children: [
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall(isDark: isDark).copyWith(
                color: color,
                fontWeight: FontWeight.w900,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value.toStringAsFixed(1),
              style: AppTypography.valueLabel(isDark: isDark).copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            Text(
              'كجم/هـ',
              style: AppTypography.bodySmall(isDark: isDark).copyWith(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoTip extends StatelessWidget {
  final String msg;
  const InfoTip(this.msg, {super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDecorations.inputRadius),
        border: Border.all(
          color: context.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.tips_and_updates_rounded,
            color: context.primary,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              msg,
              style: AppTypography.bodySmall(isDark: isDark).copyWith(
                fontSize: 13,
                height: 1.5,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
