import 'package:flutter/material.dart';
import '../../../../core/models/crop_model.dart';
import '../../../../core/constants.dart';
import '../shared/plant_section_header.dart';
import '../shared/plant_info_grid_tile.dart';
import '../shared/npk_indicator.dart';
import '../shared/fertilizer_calculator_sheet.dart';

/// Section 3: Soil Standards & Nutrition
class SoilNutritionSection extends StatelessWidget {
  final Crop crop;
  final VoidCallback? onSpeak;

  const SoilNutritionSection({super.key, required this.crop, this.onSpeak});

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
          onSpeak: onSpeak,
        ),

        PlantInfoGridTile(
          icon: Icons.layers_rounded,
          label: 'نوع التربة',
          value: care.soilTexture ?? '—',
        ),
        PlantInfoGridTile(
          icon: Icons.science_rounded,
          label: 'حموضة التربة (pH)',
          value: crop.phRange,
        ),

        const SizedBox(height: 24),

        Text(
          'توزيع العناصر الكبرى (NPK)',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: isDark ? Colors.white54 : Colors.black54,
          ),
        ),
        const SizedBox(height: 16),
        NpkIndicator(
          nAmount: care.nAmount,
          pAmount: care.pAmount,
          kAmount: care.kAmount,
        ),

        const SizedBox(height: 24),

        _WarningNote(isDark: isDark),

        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () => FertilizerCalculatorSheet.show(context, crop),
            icon: const Icon(Icons.calculate_rounded),
            label: const Text('حاسبة الأسمدة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _WarningNote extends StatelessWidget {
  final bool isDark;
  const _WarningNote({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: isDark ? Colors.white70 : Colors.black54,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تنبيه',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'يجب الحرص التام على دقة بيانات NPK والمواعيد الزراعية المُدخلة، لأن أي خطأ قد يؤدي إلى ضرر حقيقي للمحصول. يُرجى الاعتماد على مراجع زراعية موثوقة.',
                  style: TextStyle(
                    fontSize: 13,
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
