import 'package:flutter/material.dart';
import '../../../../core/models/crop_model.dart';
import '../../../../core/constants.dart';
import 'premium_section_wrapper.dart';
import '../shared/plant_info_grid_tile.dart';

/// Section 2: Cultivation Details (Refactored to Premium UI)
class CultivationSection extends StatelessWidget {
  final Crop crop;
  final VoidCallback? onSpeak;

  const CultivationSection({
    super.key,
    required this.crop,
    this.onSpeak,
  });

  @override
  Widget build(BuildContext context) {
    final care = crop.careGuide;
    if (care == null) return const SizedBox.shrink();

    final tiles = <Widget>[
      PlantInfoGridTile(
        icon: Icons.calendar_month_rounded,
        label: 'موسم الزراعة',
        value: crop.plantingSeason,
      ),
      PlantInfoGridTile(
        icon: Icons.water_drop_rounded,
        label: 'الاحتياجات المائية',
        value: crop.waterNeeds,
      ),
      if (care.lifeCycle != null)
        PlantInfoGridTile(
          icon: Icons.timelapse_rounded,
          label: 'دورة الحياة',
          value: care.lifeCycle!,
        ),
      if (care.plantingDepth != null)
        PlantInfoGridTile(
          icon: Icons.straighten_rounded,
          label: 'عمق الزراعة',
          value: care.plantingDepth!,
        ),
      if (care.seedRate != null)
        PlantInfoGridTile(
          icon: Icons.calculate_rounded,
          label: 'معدل البذور',
          value: care.seedRate!,
        ),
      if (care.soilTexture != null)
        PlantInfoGridTile(
          icon: Icons.layers_rounded,
          label: 'قوام التربة',
          value: care.soilTexture!,
        ),
    ];

    return PremiumSectionWrapper(
      title: 'دليل الاستزراع والإنتاج',
      subtitle: 'الخطوات والمواعيد المثالية للنمو',
      icon: Icons.agriculture_rounded,
      themeColor: context.primary,
      children: [
        if (care.cultivationMethod != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: context.primary.withValues(alpha: 0.1)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_outline_rounded, color: context.primary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    care.cultivationMethod!,
                    style: TextStyle(
                      fontSize: 14,
                      color: context.textColor,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.2,
          children: tiles,
        ),
      ],
    );
  }
}
