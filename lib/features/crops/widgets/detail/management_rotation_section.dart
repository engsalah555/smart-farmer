import 'package:flutter/material.dart';
import '../../../../core/models/crop_model.dart';
import '../../../../core/utils/responsive.dart';
import '../shared/plant_section_header.dart';
import '../shared/plant_list_card.dart';

/// Section 4: Management & Rotation
/// Shows companion plants, combative plants, succeeding crops, forbidden crops.
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
          color: Colors.teal,
          onSpeak: onSpeak,
        ),

        // Companion plants — SUCCESS SHIELD
        if (care.companionPlants?.isNotEmpty ?? false)
          PlantListCard(
            title: 'محاصيل مرافقة مفيدة',
            items: care.companionPlants!,
            icon: Icons.verified_user_rounded,
            color: Colors.green,
          ),

        if (care.combativePlants?.isNotEmpty ?? false) ...[
          SizedBox(height: context.hp(1.5)),
          // Combative plants — WARNING SHIELD
          PlantListCard(
            title: 'محاصيل مرافقة ضارة',
            items: care.combativePlants!,
            icon: Icons.report_problem_rounded,
            color: Colors.red,
          ),
        ],

        if (care.succeedingCrops?.isNotEmpty ?? false) ...[
          SizedBox(height: context.hp(1.5)),
          // Good rotation — ROTATION ARROW
          PlantListCard(
            title: 'تدوير مناسب (لاحق)',
            items: care.succeedingCrops!,
            icon: Icons.sync_rounded,
            color: Colors.blue,
          ),
        ],

        if (care.forbiddenCrops?.isNotEmpty ?? false) ...[
          SizedBox(height: context.hp(1.5)),
          // Forbidden rotation — BLOCKED ROTATION
          PlantListCard(
            title: 'تدوير ممنوع',
            items: care.forbiddenCrops!,
            icon: Icons.block_rounded,
            color: Colors.orange,
          ),
        ],

        if (care.rotationRecommendation != null) ...[
          SizedBox(height: context.hp(1.5)),
          _InfoCard(
            text: care.rotationRecommendation!,
            color: Colors.teal,
          ),
        ],

        if (care.managementTips != null) ...[
          SizedBox(height: context.hp(1.5)),
          _InfoCard(
            text: care.managementTips!,
            color: Colors.amber,
          ),
        ],
      ],
    );
  }
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
