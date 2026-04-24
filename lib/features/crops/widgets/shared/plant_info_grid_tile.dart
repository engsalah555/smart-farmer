import 'package:flutter/material.dart';
import '../../../../core/utils/responsive.dart';

/// Reusable grid tile for plant detail sections.
/// Used in Growth Conditions, Cultivation, Soil, etc.
class PlantInfoGridTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const PlantInfoGridTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(context.wp(3.5)),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(context.wp(4)),
        border: Border.all(
          color: iconColor.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: iconColor.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(context.wp(1.5)),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: context.sp(14)),
              ),
              SizedBox(width: context.wp(2)),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: context.sp(10),
                    color: isDark ? Colors.white60 : Colors.black45,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: context.hp(0.8)),
          Text(
            value,
            style: TextStyle(
              fontSize: context.sp(12),
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
