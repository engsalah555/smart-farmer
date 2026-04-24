import 'package:flutter/material.dart';
import '../../../../core/models/crop_model.dart';
import '../../../../core/utils/responsive.dart';
import '../shared/plant_section_header.dart';
import '../shared/plant_info_grid_tile.dart';

/// Section 2: Cultivation Details
/// Shows life cycle, cultivation method, planting season, water needs, depth, seed rate.
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

    final tiles = <_TileData>[
      _TileData(
        icon: Icons.calendar_today_rounded,
        color: Colors.orange,
        label: 'موسم الزراعة',
        value: crop.plantingSeason,
      ),
      _TileData(
        icon: Icons.water_drop_outlined,
        color: Colors.blue,
        label: 'الاحتياجات المائية',
        value: crop.waterNeeds,
      ),
      if (care.lifeCycle != null)
        _TileData(
          icon: Icons.hourglass_empty_rounded,
          color: Colors.green,
          label: 'دورة الحياة',
          value: care.lifeCycle!,
        ),
      if (care.cultivationMethod != null)
        _TileData(
          icon: Icons.agriculture_rounded,
          color: Colors.teal,
          label: 'طريقة الزراعة',
          value: care.cultivationMethod!,
        ),
      if (care.plantingDepth != null)
        _TileData(
          icon: Icons.vertical_align_bottom_rounded,
          color: Colors.brown,
          label: 'عمق الزراعة',
          value: care.plantingDepth!,
        ),
      if (care.seedRate != null)
        _TileData(
          icon: Icons.grain_rounded,
          color: Colors.orangeAccent,
          label: 'معدل البذور',
          value: care.seedRate!,
        ),
    ];

    if (tiles.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PlantSectionHeader(
          title: 'بيانات الاستزراع',
          icon: Icons.grass_rounded,
          color: Colors.green,
          onSpeak: onSpeak,
        ),
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
