import 'package:flutter/material.dart';
import '../../../../core/models/crop_model.dart';
import '../shared/plant_section_header.dart';
import '../shared/plant_info_grid_tile.dart';

/// Section 1: Growth Conditions
class GrowthConditionsSection extends StatelessWidget {
  final Crop crop;
  final VoidCallback? onSpeak;

  const GrowthConditionsSection({super.key, required this.crop, this.onSpeak});

  @override
  Widget build(BuildContext context) {
    final care = crop.careGuide;
    if (care == null) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
      if (care.irrigationLevel != null)
        PlantInfoGridTile(
          icon: Icons.opacity_rounded,
          label: 'مستوى الري',
          value: care.irrigationLevel!,
        ),
    ];

    if (tiles.isEmpty && crop.growingConditions == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PlantSectionHeader(
          title: 'ظروف النمو البيئية',
          icon: Icons.wb_cloudy_rounded,
          onSpeak: onSpeak,
        ),
        if (crop.growingConditions != null) ...[
          Text(
            crop.growingConditions!,
            style: TextStyle(
              fontSize: 15,
              color: isDark ? Colors.white70 : Colors.black87,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (tiles.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: tiles,
          ),
      ],
    );
  }
}
