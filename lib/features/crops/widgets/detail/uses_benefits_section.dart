import 'package:flutter/material.dart';
import '../../../../core/models/crop_model.dart';
import 'premium_section_wrapper.dart';

/// Section: Uses & Benefits (Refactored to Premium UI)
class UsesBenefitsSection extends StatelessWidget {
  final Crop crop;
  final VoidCallback? onSpeak;

  const UsesBenefitsSection({super.key, required this.crop, this.onSpeak});

  @override
  Widget build(BuildContext context) {
    final hasContent = crop.uses != null || crop.benefits != null || crop.growthGuide != null;
    if (!hasContent) return const SizedBox.shrink();

    return PremiumSectionWrapper(
      title: 'الاستخدامات والفوائد',
      subtitle: 'القيمة الغذائية والاستعمالات الشائعة',
      icon: Icons.menu_book_rounded,
      themeColor: Colors.blueAccent,
      children: [
        if (crop.uses != null)
          _BenefitItem(
            title: 'الاستخدامات الشائعة',
            content: crop.uses!,
            icon: Icons.auto_awesome_rounded,
            color: Colors.blue,
          ),
        if (crop.benefits != null) ...[
          if (crop.uses != null) const SizedBox(height: 16),
          _BenefitItem(
            title: 'الفوائد الغذائية والعلاجية',
            content: crop.benefits!,
            icon: Icons.favorite_rounded,
            color: Colors.redAccent,
          ),
        ],
        if (crop.growthGuide != null) ...[
          if (crop.uses != null || crop.benefits != null) const SizedBox(height: 16),
          _BenefitItem(
            title: 'ملاحظات إضافية',
            content: crop.growthGuide!,
            icon: Icons.info_outline_rounded,
            color: Colors.amber,
          ),
        ],
      ],
    );
  }
}

class _BenefitItem extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;
  final Color color;

  const _BenefitItem({
    required this.title,
    required this.content,
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
        color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey[200]!,
        ),
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
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white60 : Colors.black54,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
