import 'package:flutter/material.dart';
import '../../../../core/models/crop_model.dart';
import '../../../../core/utils/responsive.dart';
import '../shared/plant_section_header.dart';

/// Section 5: Pests & Diseases
class PestsSection extends StatelessWidget {
  final Crop crop;
  final VoidCallback? onSpeak;

  const PestsSection({super.key, required this.crop, this.onSpeak});

  @override
  Widget build(BuildContext context) {
    final text =
        crop.pestsAndDiseases ?? crop.careGuide?.pestsAndDiseases;
    if (text == null || text.isEmpty) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PlantSectionHeader(
          title: 'الآفات والأمراض',
          icon: Icons.bug_report_rounded,
          color: Colors.red,
          onSpeak: onSpeak,
        ),
        Container(
          padding: EdgeInsets.all(context.wp(4)),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(context.wp(4)),
            border: Border.all(color: Colors.red.withValues(alpha: 0.18)),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: context.sp(13),
              color: isDark ? Colors.white70 : Colors.black87,
              height: 1.7,
            ),
          ),
        ),
      ],
    );
  }
}


/// Section 6: Harvesting & Storage
class HarvestSection extends StatelessWidget {
  final Crop crop;
  final VoidCallback? onSpeak;

  const HarvestSection({super.key, required this.crop, this.onSpeak});

  @override
  Widget build(BuildContext context) {
    final text =
        crop.harvestingAndStorage ?? crop.careGuide?.harvestingAndStorage;
    if (text == null || text.isEmpty) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PlantSectionHeader(
          title: 'الحصاد والتخزين',
          icon: Icons.inventory_2_rounded,
          color: Colors.amber,
          onSpeak: onSpeak,
        ),
        Container(
          padding: EdgeInsets.all(context.wp(4)),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(context.wp(4)),
            border: Border.all(color: Colors.amber.withValues(alpha: 0.2)),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: context.sp(13),
              color: isDark ? Colors.white70 : Colors.black87,
              height: 1.7,
            ),
          ),
        ),
      ],
    );
  }
}
