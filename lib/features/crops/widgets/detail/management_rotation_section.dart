import 'package:flutter/material.dart';
import 'package:smart_farm2/core/theme/app_colors.dart';
import '../../../../core/models/crop_model.dart';
import 'premium_section_wrapper.dart';

/// Section: Management & Rotation (Refactored to Premium UI)
class ManagementRotationSection extends StatelessWidget {
  final Crop crop;
  final VoidCallback? onSpeak;

  const ManagementRotationSection({
    super.key,
    required this.crop,
    this.onSpeak,
  });

  @override
  Widget build(BuildContext context) {
    final care = crop.careGuide;
    if (care == null) return const SizedBox.shrink();

    final successing = care.succeedingCrops ?? [];
    final forbidden = care.forbiddenCrops ?? [];

    if (successing.isEmpty && forbidden.isEmpty && care.rotationRecommendation == null) {
      return const SizedBox.shrink();
    }

    return PremiumSectionWrapper(
      title: 'الدورة الزراعية',
      subtitle: 'تنظيم زراعة المحاصيل المتعاقبة',
      icon: Icons.cached_rounded,
      themeColor: Colors.orange,
      children: [
        if (care.rotationRecommendation != null) ...[
          Text(
            care.rotationRecommendation!,
            style: TextStyle(
              fontSize: 14,
              color: context.textColor,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),
        ],
        if (successing.isNotEmpty)
          _RotationListCard(
            title: 'محاصيل يفضل زراعتها لاحقاً',
            items: successing,
            icon: Icons.check_circle_outline,
            color: Colors.green,
          ),
        if (forbidden.isNotEmpty) ...[
          if (successing.isNotEmpty) const SizedBox(height: 12),
          _RotationListCard(
            title: 'محاصيل تجنب زراعتها لاحقاً',
            items: forbidden,
            icon: Icons.block_flipped,
            color: Colors.redAccent,
          ),
        ],
      ],
    );
  }
}

class _RotationListCard extends StatelessWidget {
  final String title;
  final List<String> items;
  final IconData icon;
  final Color color;

  const _RotationListCard({
    required this.title,
    required this.items,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? color.withValues(alpha: 0.1) : color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((item) => Chip(
              label: Text(item, style: const TextStyle(fontSize: 12)),
              backgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
              side: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade200),
              labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            )).toList(),
          ),
        ],
      ),
    );
  }
}
