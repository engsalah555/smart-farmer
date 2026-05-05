import 'package:flutter/material.dart';
import 'package:smart_farm2/core/theme/app_colors.dart';

/// Reusable data row for plant detail sections.
class PlantInfoGridTile extends StatelessWidget {
  final IconData icon;
  final Color? iconColor; // Kept for api compatibility
  final String label;
  final String value;

  const PlantInfoGridTile({
    super.key,
    required this.icon,
    this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? context.white.withValues(alpha: context.opacitySubtle / 2) : context.black.withValues(alpha: context.opacitySubtle / 5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? context.white.withValues(alpha: context.opacitySubtle) : context.black.withValues(alpha: context.opacitySubtle / 2.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (iconColor ?? context.primary).withValues(alpha: context.opacityLow),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: iconColor ?? context.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: context.textMuted,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: context.textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
