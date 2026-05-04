import 'package:flutter/material.dart';
import '../../../../core/models/crop_model.dart';
import 'premium_section_wrapper.dart';

/// Section 5: Pests & Diseases (Refactored to Premium UI)
class PestsSection extends StatelessWidget {
  final Crop crop;
  final VoidCallback? onSpeak;

  const PestsSection({super.key, required this.crop, this.onSpeak});

  @override
  Widget build(BuildContext context) {
    final text = crop.pestsAndDiseases ?? crop.careGuide?.pestsAndDiseases;
    if (text == null || text.isEmpty) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final items = _extractItems(text);

    return PremiumSectionWrapper(
      title: 'الآفات والمشاكل الشائعة',
      subtitle: 'دليل المكافحة والوقاية الذكي',
      icon: Icons.bug_report_rounded,
      themeColor: Colors.redAccent,
      children: [
        ...items.map((item) => _ProblemCard(
              text: item,
              isDark: isDark,
              icon: _getIconForItem(item),
              color: Colors.redAccent,
            )),
      ],
    );
  }

  List<String> _extractItems(String text) {
    if (text.isEmpty) return [];
    return text
        .split(RegExp(r'\n|•|-|(\d+\.)|(\*+)'))
        .map((e) => e.trim())
        .where((e) => e.length > 5)
        .toList();
  }

  IconData _getIconForItem(String text) {
    final lowerText = text.toLowerCase();
    if (lowerText.contains('حشر') || 
        lowerText.contains('ذبابة') || 
        lowerText.contains('من') || 
        lowerText.contains('ديدان') ||
        lowerText.contains('يرقة') ||
        lowerText.contains('بقة')) {
      return Icons.pest_control_rounded;
    }
    
    if (lowerText.contains('فطر') || 
        lowerText.contains('عفن') || 
        lowerText.contains('صدأ') ||
        lowerText.contains('بياض') ||
        lowerText.contains('مرض') ||
        lowerText.contains('لفحة')) {
      return Icons.biotech_rounded;
    }
    
    if (lowerText.contains('ري') || 
        lowerText.contains('ماء') || 
        lowerText.contains('رطوبة') ||
        lowerText.contains('جفاف') ||
        lowerText.contains('عطش')) {
      return Icons.water_drop_rounded;
    }
    
    if (lowerText.contains('نقص') || 
        lowerText.contains('عنصر') || 
        lowerText.contains('تسميد') ||
        lowerText.contains('تربة') ||
        lowerText.contains('غذاء')) {
      return Icons.local_florist_rounded;
    }

    return Icons.warning_amber_rounded;
  }
}

class _ProblemCard extends StatelessWidget {
  final String text;
  final bool isDark;
  final IconData icon;
  final Color color;

  const _ProblemCard({
    required this.text,
    required this.isDark,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? color.withValues(alpha: 0.08) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.15)),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: color.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black87,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Section 6: Harvesting & Storage (Refactored to Premium UI)
class HarvestSection extends StatelessWidget {
  final Crop crop;
  final VoidCallback? onSpeak;

  const HarvestSection({super.key, required this.crop, this.onSpeak});

  @override
  Widget build(BuildContext context) {
    final text = crop.harvestingAndStorage ?? crop.careGuide?.harvestingAndStorage;
    if (text == null || text.isEmpty) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final items = _extractItems(text);

    return PremiumSectionWrapper(
      title: 'الحصاد والتخزين',
      subtitle: 'جودة الإنتاج بعد القطف',
      icon: Icons.inventory_2_rounded,
      themeColor: Colors.orange,
      children: [
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  List<String> _extractItems(String text) {
    if (text.isEmpty) return [];
    return text
        .split(RegExp(r'\n|•|-|(\d+\.)'))
        .map((e) => e.trim())
        .where((e) => e.length > 3)
        .toList();
  }
}
