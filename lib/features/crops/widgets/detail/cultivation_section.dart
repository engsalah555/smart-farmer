import 'package:flutter/material.dart';
import '../../../../core/models/crop_model.dart';
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
        icon: Icons.calendar_today_rounded,
        label: 'موسم الزراعة',
        value: crop.plantingSeason,
      ),
      PlantInfoGridTile(
        icon: Icons.water_drop_outlined,
        label: 'الاحتياجات المائية',
        value: crop.waterNeeds,
      ),
      if (care.lifeCycle != null)
        PlantInfoGridTile(
          icon: Icons.hourglass_empty_rounded,
          label: 'دورة الحياة',
          value: care.lifeCycle!,
        ),
      if (care.cultivationMethod != null)
        PlantInfoGridTile(
          icon: Icons.agriculture_rounded,
          label: 'طريقة الزراعة',
          value: care.cultivationMethod!,
        ),
      if (care.plantingDepth != null)
        PlantInfoGridTile(
          icon: Icons.vertical_align_bottom_rounded,
          label: 'عمق الزراعة',
          value: care.plantingDepth!,
        ),
      if (care.seedRate != null)
        PlantInfoGridTile(
          icon: Icons.grain_rounded,
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
          onSpeak: onSpeak,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: tiles,
        ),
      ],
    );
  }
}
