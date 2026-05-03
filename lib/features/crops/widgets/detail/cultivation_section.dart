import 'package:flutter/material.dart';
import '../../../../core/models/crop_model.dart';
import '../../../../core/constants.dart';
import '../shared/plant_section_header.dart';
import '../shared/plant_info_grid_tile.dart';

/// Section 2: Cultivation Details
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

    if (tiles.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PlantSectionHeader(
          title: 'دليل الاستزراع والإنتاج',
          icon: Icons.agriculture_rounded,
          onSpeak: onSpeak,
        ),
        
        // Prominent Cultivation Method Card
        if (care.cultivationMethod != null) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 24),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  context.primary.withValues(alpha: 0.12),
                  context.primary.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: context.primary.withValues(alpha: 0.2)),
              boxShadow: [
                BoxShadow(
                  color: context.primary.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.psychology_rounded, color: context.primary, size: 28),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'طريقة الزراعة المثالية:',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          color: context.primary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        care.cultivationMethod!,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: context.textColor,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],

        // Information Grid
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
