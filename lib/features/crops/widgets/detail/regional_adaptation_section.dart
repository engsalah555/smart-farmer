import 'package:flutter/material.dart';
import '../../../../core/models/crop_model.dart';
import '../../../../core/constants.dart';
import '../shared/plant_section_header.dart';
import '../shared/fertilizer_calculator_sheet.dart';

class RegionalAdaptationSection extends StatelessWidget {
  final Crop crop;

  const RegionalAdaptationSection({super.key, required this.crop});

  @override
  Widget build(BuildContext context) {
    final care = crop.careGuide;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PlantSectionHeader(
          title: 'التكيف الإقليمي والمحلي',
          icon: Icons.public_rounded,
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                context.primary.withValues(alpha: 0.1),
                Colors.orange.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: context.primary.withValues(alpha: 0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.flag_rounded, color: Colors.white, size: 14),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'نصائح خاصة بالبيئة اليمنية',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.redAccent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildYemenAdvice(context, isDark),
              if (care?.managementTips != null) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(),
                ),
                Text(
                  'إرشادات الإدارة العامة:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  care!.managementTips!,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white60 : Colors.black54,
                    height: 1.6,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildYemenAdvice(BuildContext context, bool isDark) {
    String advice = "";
    List<String> regions = [];
    
    if (crop.category.contains('خضروات')) {
      advice = "في المرتفعات اليمنية (صنعاء، ذمار)، يفضل الزراعة في البيوت المحمية خلال أشهر الشتاء لتجنب الضريب (الصقيع). أما في المناطق الساحلية (الحديدة، عدن)، يجب توفير تظليل جزئي خلال الصيف.";
      regions = ['المرتفعات', 'تهامة', 'لحج'];
    } else if (crop.category.contains('فواكه')) {
      advice = "تنجح الفواكه الاستوائية بشكل ممتاز في تهامة ولحج. تأكد من جودة مياه الري خاصة في المناطق التي تعاني من الملوحة العالية مثل سواحل أبين والحديدة.";
      regions = ['تهامة', 'أبين', 'حضرموت'];
    } else {
      advice = "المناخ اليمني متنوع جداً. ننصح بمتابعة نشرات الإرشاد الزراعي المحلية حسب منطقتك (سواء كانت السراة، الهضبة، أو السهول الساحلية).";
      regions = ['كل الأقاليم'];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          advice,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w500,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          children: regions.map((r) => Chip(
            label: Text(r, style: const TextStyle(fontSize: 10)),
            backgroundColor: context.primary.withValues(alpha: 0.1),
            side: BorderSide.none,
            visualDensity: VisualDensity.compact,
          )).toList(),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () => FertilizerCalculatorSheet.show(context, crop),
          icon: const Icon(Icons.calculate_rounded, size: 18),
          label: const Text('حاسبة السماد للمناخ المحلي'),
          style: OutlinedButton.styleFrom(
            foregroundColor: context.primary,
            side: BorderSide(color: context.primary.withValues(alpha: 0.3)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}
