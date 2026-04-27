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
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: context.primary),
            const SizedBox(width: 10),
          ],
          Text(
            label,
            style: AppTypography.h3(isDark: false).copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: context.primary,
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
          padding: const EdgeInsets.only(right: 4, bottom: 8),
          child: Text(
            label,
            style: AppTypography.bodySmall(isDark: isDark).copyWith(
              fontSize: 12,
              color: isDark ? AppColors.darkTextSecondary : Colors.grey,
            ),
          ),
        ),
        Container(
          decoration:
              AppDecorations.premiumGlassDecorationV2(
                isDark: isDark,
                radius: 16,
              ).copyWith(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.grey.shade50,
              ),
          child: TextField(
            controller: ctrl,
            keyboardType: keyboard,
            onChanged: onChanged,
            style: AppTypography.valueLabel(isDark: isDark).copyWith(
              color: isDark ? Colors.white : AppColors.textPrimary,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
              prefixIcon: Icon(icon, color: context.primary, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
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
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.info_outline, size: 14, color: color),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration:
              AppDecorations.premiumGlassDecorationV2(
                isDark: isDark,
                radius: 14,
              ).copyWith(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.white,
              ),
          child: TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: AppTypography.valueLabel(
              isDark: isDark,
            ).copyWith(fontSize: 16),
            decoration: InputDecoration(
              hintText: '0',
              border: InputBorder.none,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: color, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Center(
          child: Text(
            'ppm / ملغم',
            style: AppTypography.valueLabel(isDark: isDark).copyWith(
              fontSize: 9,
              color: isDark ? AppColors.darkTextSecondary : Colors.grey,
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
        backgroundColor: isDark ? const Color(0xFF1E2E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          label,
          style: AppTypography.h3(isDark: isDark).copyWith(color: color),
        ),
        content: Text(info, style: AppTypography.bodyMedium(isDark: isDark)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'فهمت',
              style: AppTypography.bodyMedium(
                isDark: isDark,
              ).copyWith(color: context.primary),
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
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2), width: 1.2),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: AppTypography.bodySmall(isDark: false).copyWith(
                color: color,
                fontWeight: FontWeight.w900,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value.toStringAsFixed(1),
              style: AppTypography.valueLabel(
                isDark: false,
              ).copyWith(fontSize: 16, fontWeight: FontWeight.bold),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.primary.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.auto_awesome_outlined,
            color: context.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              msg,
              style: AppTypography.bodySmall(isDark: false).copyWith(
                fontSize: 12,
                height: 1.4,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
