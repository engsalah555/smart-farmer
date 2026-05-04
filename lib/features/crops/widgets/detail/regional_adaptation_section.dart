import 'package:flutter/material.dart';
import '../../../../core/models/crop_model.dart';
import '../../../../core/constants.dart';
import 'premium_section_wrapper.dart';

/// Section: Regional Adaptation (Refactored to Premium UI)
class RegionalAdaptationSection extends StatelessWidget {
  final Crop crop;

  const RegionalAdaptationSection({super.key, required this.crop});

  @override
  Widget build(BuildContext context) {
    final care = crop.careGuide;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PremiumSectionWrapper(
      title: 'التكيف الإقليمي والمحلي',
      subtitle: 'دليل الزراعة حسب الأقاليم اليمنية',
      icon: Icons.public_rounded,
      themeColor: Colors.orange,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                context.primary.withValues(alpha: 0.08),
                Colors.orange.withValues(alpha: 0.04),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: context.primary.withValues(alpha: 0.1),
            ),
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
                    child: const Icon(
                      Icons.flag_rounded,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'نصائح خاصة بالبيئة اليمنية',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.redAccent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildYemenAdvice(context, isDark),
            ],
          ),
        ),

        if (care?.managementTips != null) ...[
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.white10 : Colors.grey[200]!,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline_rounded,
                      size: 18,
                      color: context.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'إرشادات الإدارة العامة',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  care!.managementTips!,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white60 : Colors.black54,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildYemenAdvice(BuildContext context, bool isDark) {
    String advice = "";
    List<String> regions = [];
    
    final category = crop.category;
    if (category.contains('خضروات') || category.contains('منتجات زراعية')) {
      advice = "في المرتفعات اليمنية (صنعاء، ذمار)، يفضل الزراعة في البيوت المحمية خلال أشهر الشتاء لتجنب الضريب (الصقيع). أما في المناطق الساحلية (الحديدة، عدن)، يجب توفير تظليل جزئي خلال الصيف.";
      regions = ['المرتفعات', 'تهامة', 'لحج'];
    } else if (category.contains('فواكه') || category.contains('أشجار')) {
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
          runSpacing: 8,
          children: regions.map((r) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: context.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: context.primary.withValues(alpha: 0.1)),
            ),
            child: Text(
              r,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: context.primary,
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }
}
