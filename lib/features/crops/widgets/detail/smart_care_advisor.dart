import 'package:flutter/material.dart';
import '../../../../core/constants.dart';
import '../../../../core/models/crop_model.dart';

class SmartCareAdvisor extends StatelessWidget {
  final Crop crop;
  const SmartCareAdvisor({super.key, required this.crop});

  @override
  Widget build(BuildContext context) {
    final care = crop.careGuide;
    if (care == null) return const SizedBox.shrink();

    // Simulation of live data for "Premium" feel
    const currentTemp = 24;
    final isTempIdeal = (care.minTemp == null || currentTemp >= care.minTemp!) &&
                        (care.maxTemp == null || currentTemp <= care.maxTemp!);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: context.primary.withValues(alpha: 0.15), width: 1.5),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            context.primary.withValues(alpha: 0.05),
            context.surface,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: context.primary, size: 24),
              const SizedBox(width: 12),
              Text(
                'مستشارك الذكي',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: context.textColor,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: context.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'تحليل مباشر',
                  style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _AdvisorCard(
            title: 'حالة الطقس',
            status: isTempIdeal ? 'مثالي للنمو' : 'يحتاج انتباه',
            desc: 'درجة الحرارة الحالية ($currentTemp°C) ${isTempIdeal ? "مناسبة جداً" : "خارج النطاق المثالي"} لـ ${crop.name}.',
            icon: Icons.wb_sunny_rounded,
            color: isTempIdeal ? Colors.orange : Colors.redAccent,
          ),
          const SizedBox(height: 12),
          _AdvisorCard(
            title: 'نصيحة مخصصة',
            status: 'إجراء مطلوب',
            desc: _generateAdvice(crop),
            icon: Icons.tips_and_updates_rounded,
            color: context.primary,
          ),
        ],
      ),
    );
  }

  String _generateAdvice(Crop crop) {
    if (crop.waterNeeds.contains('عالي')) {
      return 'تأكد من رطوبة التربة العميقة اليوم، فهذه النبتة تستهلك الماء بسرعة في هذا الطقس.';
    }
    if (crop.careGuide?.lightType?.contains('شمس') ?? false) {
      return 'تحتاج النبتة لتعريض مباشر لأشعة الشمس لمدة 6 ساعات على الأقل لضمان جودة المحصول.';
    }
    return 'هذا الوقت مثالي لمراقبة نمو الأوراق والتأكد من خلوها من أي بقع فطرية.';
  }
}

class _AdvisorCard extends StatelessWidget {
  final String title;
  final String status;
  final String desc;
  final IconData icon;
  final Color color;

  const _AdvisorCard({
    required this.title,
    required this.status,
    required this.desc,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.border.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(color: context.textMuted, fontSize: 12),
                    ),
                    Text(
                      status,
                      style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(color: context.textColor, fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
