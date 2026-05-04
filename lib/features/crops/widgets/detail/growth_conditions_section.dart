import 'package:flutter/material.dart';
import '../../../../core/models/crop_model.dart';
import '../../../../core/constants.dart';
import 'premium_section_wrapper.dart';
import '../shared/plant_info_grid_tile.dart';

/// Section 1: Growth Conditions (Refactored to Premium UI)
class GrowthConditionsSection extends StatelessWidget {
  final Crop crop;
  final VoidCallback? onSpeak;

  const GrowthConditionsSection({super.key, required this.crop, this.onSpeak});

  @override
  Widget build(BuildContext context) {
    final care = crop.careGuide;
    if (care == null) return const SizedBox.shrink();

    final tiles = <Widget>[
      if (care.minTemp != null || care.maxTemp != null)
        PlantInfoGridTile(
          icon: Icons.thermostat_rounded,
          label: 'درجة الحرارة',
          value: crop.temperatureRange,
        ),
      if (care.lightType != null)
        PlantInfoGridTile(
          icon: Icons.wb_sunny_rounded,
          label: 'التعرض للشمس',
          value: care.lightType!,
        ),
      if (care.rainfall != null)
        PlantInfoGridTile(
          icon: Icons.cloud_queue_rounded,
          label: 'معدل الأمطار',
          value: care.rainfall!,
        ),
      if (care.minHumidity != null || care.maxHumidity != null)
        PlantInfoGridTile(
          icon: Icons.water_drop_rounded,
          label: 'الرطوبة النسبية',
          value: crop.humidityRange,
        ),
    ];

    return PremiumSectionWrapper(
      title: 'ظروف النمو البيئية',
      subtitle: 'المناخ والبيئة المناسبة للمحصول',
      icon: Icons.wb_cloudy_rounded,
      themeColor: Colors.teal,
      children: [
        if (crop.growingConditions != null) ...[
          Text(
            crop.growingConditions!,
            style: TextStyle(
              fontSize: 14,
              color: context.textColor,
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
        ],
        if (tiles.isNotEmpty)
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
