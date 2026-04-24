import 'package:flutter/material.dart';
import '../../../../core/models/crop_model.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/constants.dart';
import '../shared/plant_section_header.dart';
import '../shared/plant_info_grid_tile.dart';
import '../shared/npk_indicator.dart';
import '../shared/fertilizer_calculator_sheet.dart';
import '../../utils/crop_calculator.dart';

/// Section 3: Soil Standards & Nutrition
/// Shows soil texture, pH, NPK indicators, warning note, and fertilizer calculator button.
class SoilNutritionSection extends StatelessWidget {
  final Crop crop;
  final VoidCallback? onSpeak;

  const SoilNutritionSection({
    super.key,
    required this.crop,
    this.onSpeak,
  });

  @override
  Widget build(BuildContext context) {
    final care = crop.careGuide;
    if (care == null) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PlantSectionHeader(
          title: 'معايير التربة والتسميد',
          icon: Icons.hub_rounded,
          color: Colors.purple,
          onSpeak: onSpeak,
        ),

        // Soil info grid
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: context.wp(3),
          mainAxisSpacing: context.hp(1.5),
          childAspectRatio: 1.6,
          children: [
            PlantInfoGridTile(
              icon: Icons.layers_rounded,
              iconColor: Colors.blueGrey,
              label: 'نوع التربة',
              value: care.soilTexture ?? '—',
            ),
            PlantInfoGridTile(
              icon: Icons.science_rounded,
              iconColor: Colors.indigo,
              label: 'حموضة التربة (pH)',
              value: crop.phRange,
            ),
          ],
        ),

        SizedBox(height: context.hp(2.5)),

        // NPK section
        Text(
          'توزيع العناصر الكبرى (NPK)',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: context.sp(14),
            color: Colors.purple,
          ),
        ),
        SizedBox(height: context.hp(1.5)),
        NpkIndicator(
          nAmount: care.nAmount,
          pAmount: care.pAmount,
          kAmount: care.kAmount,
        ),

        SizedBox(height: context.hp(2)),

        // تحذير هام — always visible in this section
        _WarningNote(isDark: isDark),

        SizedBox(height: context.hp(2)),

        // Fertilizer calculator button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => FertilizerCalculatorSheet.show(context, crop),
            icon: const Icon(Icons.calculate_rounded),
            label: const Text('حاسبة الأسمدة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: context.hp(1.8)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(context.wp(4)),
              ),
              textStyle: TextStyle(
                fontSize: context.sp(15),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Inline warning note shown under NPK data.
class _WarningNote extends StatelessWidget {
  final bool isDark;
  const _WarningNote({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.wp(4)),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(context.wp(3)),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.amber.shade700,
            size: context.sp(18),
          ),
          SizedBox(width: context.wp(3)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تحذير هام',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade800,
                    fontSize: context.sp(13),
                  ),
                ),
                SizedBox(height: context.hp(0.4)),
                Text(
                  'يجب الحرص التام على دقة بيانات NPK والمواعيد الزراعية المُدخلة، لأن أي خطأ قد يؤدي إلى ضرر حقيقي للمحصول. يُرجى الاعتماد على مراجع زراعية موثوقة.',
                  style: TextStyle(
                    fontSize: context.sp(11),
                    color: isDark ? Colors.white70 : Colors.black87,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
