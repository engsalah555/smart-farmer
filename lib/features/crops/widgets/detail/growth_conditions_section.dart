import 'package:flutter/material.dart';
import '../../../../core/models/crop_model.dart';
import '../../../../core/utils/responsive.dart';
import '../shared/plant_section_header.dart';
import '../shared/plant_info_grid_tile.dart';
import '../../utils/crop_calculator.dart';

/// Section 1: Growth Conditions Grid
/// Shows temperature, sunlight, rainfall, humidity, irrigation.
class GrowthConditionsSection extends StatelessWidget {
  final Crop crop;
  final VoidCallback? onSpeak;

  const GrowthConditionsSection({
    super.key,
    required this.crop,
    this.onSpeak,
  });

  @override
  Widget build(BuildContext context) {
    final care = crop.careGuide;
    if (care == null) return const SizedBox.shrink();

    final tiles = <_TileData>[
      if (care.minTemp != null || care.maxTemp != null)
        _TileData(
          icon: Icons.thermostat_rounded,
          color: Colors.redAccent,
          label: 'درجة الحرارة',
          value: crop.temperatureRange,
        ),
      if (care.lightType != null)
        _TileData(
          icon: Icons.wb_sunny_rounded,
          color: Colors.amber,
          label: 'التعرض للشمس',
          value: care.lightType!,
        ),
      if (care.rainfall != null)
        _TileData(
          icon: Icons.cloud_queue_rounded,
          color: Colors.blue,
          label: 'معدل الأمطار',
          value: care.rainfall!,
        ),
      if (care.minHumidity != null || care.maxHumidity != null)
        _TileData(
          icon: Icons.water_drop_rounded,
          color: Colors.cyan,
          label: 'الرطوبة النسبية',
          value: crop.humidityRange,
        ),
      if (care.irrigationLevel != null)
        _TileData(
          icon: Icons.opacity_rounded,
          color: Colors.blueAccent,
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
          color: Colors.orange,
          onSpeak: onSpeak,
        ),
        if (crop.growingConditions != null) ...[
          _InfoCard(text: crop.growingConditions!, color: Colors.orange),
          SizedBox(height: context.hp(1.5)),
        ],
        if (tiles.isNotEmpty)
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: context.wp(3),
            mainAxisSpacing: context.hp(1.5),
            childAspectRatio: 1.6,
            children: tiles
                .map(
                  (t) => PlantInfoGridTile(
                    icon: t.icon,
                    iconColor: t.color,
                    label: t.label,
                    value: t.value,
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}

class _TileData {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  const _TileData({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });
}

class _InfoCard extends StatelessWidget {
  final String text;
  final Color color;
  const _InfoCard({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.all(context.wp(4)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(context.wp(4)),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: context.sp(13),
          color: isDark ? Colors.white70 : Colors.black87,
          height: 1.6,
        ),
      ),
    );
  }
}
