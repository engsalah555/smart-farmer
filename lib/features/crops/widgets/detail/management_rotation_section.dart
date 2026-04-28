import 'package:flutter/material.dart';
import '../../../../core/models/crop_model.dart';
import '../shared/plant_section_header.dart';
import '../shared/plant_list_card.dart';

class ManagementRotationSection extends StatelessWidget {
  final Crop crop;
  final VoidCallback? onSpeak;

  const ManagementRotationSection({
    super.key,
    required this.crop,
    this.onSpeak,
  });

  @override
  Widget build(BuildContext context) {
    final care = crop.careGuide;
    if (care == null) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final hasContent = (care.companionPlants?.isNotEmpty ?? false) ||
        (care.combativePlants?.isNotEmpty ?? false) ||
        (care.succeedingCrops?.isNotEmpty ?? false) ||
        (care.forbiddenCrops?.isNotEmpty ?? false) ||
        care.rotationRecommendation != null ||
        care.managementTips != null;

    if (!hasContent) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PlantSectionHeader(
          title: 'التوافق والدورة الزراعية',
          icon: Icons.cached_rounded,
          onSpeak: onSpeak,
        ),

        if (care.companionPlants?.isNotEmpty ?? false)
          PlantListCard(
            title: 'محاصيل مرافقة مفيدة',
            items: care.companionPlants!,
            icon: Icons.verified_user_rounded,
          ),

        if (care.combativePlants?.isNotEmpty ?? false)
          PlantListCard(
            title: 'محاصيل مرافقة ضارة',
            items: care.combativePlants!,
            icon: Icons.report_problem_rounded,
          ),

        if (care.succeedingCrops?.isNotEmpty ?? false)
          PlantListCard(
            title: 'تدوير مناسب (لاحق)',
            items: care.succeedingCrops!,
            icon: Icons.sync_rounded,
          ),

        if (care.forbiddenCrops?.isNotEmpty ?? false)
          PlantListCard(
            title: 'تدوير ممنوع',
            items: care.forbiddenCrops!,
            icon: Icons.block_rounded,
          ),

        if (care.rotationRecommendation != null) ...[
          const SizedBox(height: 16),
          Text(
            care.rotationRecommendation!,
            style: TextStyle(
              fontSize: 15,
              color: isDark ? Colors.white70 : Colors.black87,
              height: 1.6,
            ),
          ),
        ],

        if (care.managementTips != null) ...[
          const SizedBox(height: 16),
          Text(
            care.managementTips!,
            style: TextStyle(
              fontSize: 15,
              color: isDark ? Colors.white70 : Colors.black87,
              height: 1.6,
            ),
          ),
        ],
      ],
    );
  }
}
