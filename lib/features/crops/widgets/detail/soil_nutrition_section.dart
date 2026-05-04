import 'package:flutter/material.dart';
import '../../../../core/models/crop_model.dart';
import '../../../../core/constants.dart';
import 'premium_section_wrapper.dart';
import '../shared/plant_info_grid_tile.dart';
import '../shared/npk_indicator.dart';
import '../shared/fertilizer_calculator_sheet.dart';

/// Section 3: Soil Standards & Nutrition (Refactored to Premium UI)
class SoilNutritionSection extends StatelessWidget {
  final Crop crop;
  final VoidCallback? onSpeak;

  const SoilNutritionSection({super.key, required this.crop, this.onSpeak});

  @override
  Widget build(BuildContext context) {
    final care = crop.careGuide;
    if (care == null) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PremiumSectionWrapper(
      title: 'معايير التربة والتسميد',
      subtitle: 'توازن العناصر والاحتياجات الغذائية',
      icon: Icons.science_rounded,
      themeColor: Colors.blue,
      children: [
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.2,
          children: [
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
          ],
        ),
        const SizedBox(height: 24),
        
        // NPK Legend
        Row(
          children: [
            const Icon(Icons.analytics_rounded, color: Colors.blue, size: 18),
            const SizedBox(width: 8),
            Text(
              'توزيع العناصر الكبرى (NPK)',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: context.textColor,
              ),
            ),
          ],
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
          height: 58,
          child: ElevatedButton.icon(
            onPressed: () => FertilizerCalculatorSheet.show(context, crop),
            icon: const Icon(Icons.calculate_rounded, size: 22),
            label: const Text('تشغيل حاسبة الأسمدة الذكية'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
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
        color: Colors.amber.withValues(alpha: isDark ? 0.08 : 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: Colors.amber.shade700, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'يجب الحرص على دقة بيانات NPK والمواعيد، لأن أي خطأ قد يؤدي إلى ضرر للمحصول. يفضل استشارة مرشد زراعي.',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white70 : Colors.black87,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
