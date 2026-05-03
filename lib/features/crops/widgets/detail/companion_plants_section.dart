import 'package:flutter/material.dart';
import '../../../../core/models/crop_model.dart';
import '../../../../core/constants.dart';
import '../shared/plant_section_header.dart';

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PlantSectionHeader(
          title: 'نظام الرفقة النباتية',
          icon: Icons.groups_rounded,
        ),
        const SizedBox(height: 12),
        if (companions.isNotEmpty) ...[
          _PlantRelationshipCard(
            title: 'مرفقات جيدة (جيران جيدون)',
            items: companions,
            isPositive: true,
          ),
          const SizedBox(height: 12),
        ],
        if (combative.isNotEmpty) ...[
          _PlantRelationshipCard(
            title: 'مرفقات سيئة (تجنب المجاورة)',
            items: combative,
            isPositive: false,
          ),
        ],
      ],
    );
  }
}

class _PlantRelationshipCard extends StatelessWidget {
  final String title;
  final List<String> items;
  final bool isPositive;

  const _PlantRelationshipCard({
    required this.title,
    required this.items,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    final color = isPositive ? context.primary : Colors.redAccent;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isPositive ? Icons.favorite_rounded : Icons.block_flipped,
                color: color,
                size: 18,
              ),
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
            children: items.map((plant) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: color.withValues(alpha: 0.1),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositive ? Icons.check_circle_outline : Icons.close_rounded,
                      size: 14,
                      color: color,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      plant,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
