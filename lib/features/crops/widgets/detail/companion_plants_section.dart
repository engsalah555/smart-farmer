import 'package:flutter/material.dart';
import '../../../../core/models/crop_model.dart';
import 'premium_section_wrapper.dart';

/// Section: Companion Plants (Refactored to Premium UI)
class CompanionPlantsSection extends StatelessWidget {
  final Crop crop;

  const CompanionPlantsSection({super.key, required this.crop});

  @override
  Widget build(BuildContext context) {
    final care = crop.careGuide;
    if (care == null) return const SizedBox.shrink();

    final companions = care.companionPlants ?? [];
    final combative = care.combativePlants ?? [];

    if (companions.isEmpty && combative.isEmpty) return const SizedBox.shrink();

    return PremiumSectionWrapper(
      title: 'نظام الرفقة النباتية',
      subtitle: 'توافق المحاصيل والزراعة المتداخلة',
      icon: Icons.groups_rounded,
      themeColor: Colors.deepPurple,
      children: [
        if (companions.isNotEmpty) ...[
          _RelationshipCard(
            title: 'جيران جيدون (زراعة متوافقة)',
            items: companions,
            isPositive: true,
          ),
          if (combative.isNotEmpty) const SizedBox(height: 16),
        ],
        if (combative.isNotEmpty) ...[
          _RelationshipCard(
            title: 'جيران سيئون (تجنب المجاورة)',
            items: combative,
            isPositive: false,
          ),
        ],
      ],
    );
  }
}

class _RelationshipCard extends StatelessWidget {
  final String title;
  final List<String> items;
  final bool isPositive;

  const _RelationshipCard({
    required this.title,
    required this.items,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    final color = isPositive ? Colors.green : Colors.redAccent;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? color.withValues(alpha: 0.1) : color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPositive ? Icons.favorite_rounded : Icons.block_flipped,
                  color: color,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
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
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((plant) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? Colors.white10 : Colors.grey.shade200,
                  ),
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                child: Text(
                  plant,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
