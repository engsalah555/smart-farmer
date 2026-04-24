import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_typography.dart';
import '../../models/fertilizer_models.dart';
import 'calculator_shared_widgets.dart';

class ResultSheet extends StatelessWidget {
  final FertilizerRecommendation result;
  final CropFertilizerProfile crop;
  final double areaHa;
  final String areaDisplay;
  final String yieldDisplay;
  final double ph;

  const ResultSheet({
    super.key,
    required this.result,
    required this.crop,
    required this.areaHa,
    required this.areaDisplay,
    required this.yieldDisplay,
    required this.ph,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.6,
      maxChildSize: 0.98,
      builder: (_, ctrl) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 40,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: Column(
            children: [
              // Grab Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Expanded(
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: ListView(
                    controller: ctrl,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    children: [
                      _buildHeader(context, isDark),
                      const SizedBox(height: 24),

                      _buildNPKSummary(isDark),
                      const SizedBox(height: 32),

                      const SectionLabel(
                        '📊 تحليل الاحتياجات الغذائية',
                        icon: Icons.analytics_rounded,
                      ),
                      const SizedBox(height: 16),
                      _NutrientChart(result: result, isDark: isDark),

                      const SizedBox(height: 32),
                      const SectionLabel(
                        '🧴 كميات الأسمدة الموصى بها',
                        icon: Icons.science_rounded,
                      ),
                      const SizedBox(height: 16),
                      _buildFertList(isDark),

                      const SizedBox(height: 32),
                      const SectionLabel(
                        '🗓 جدول المواعيد والمراحل',
                        icon: Icons.calendar_today_rounded,
                      ),
                      const SizedBox(height: 16),
                      _FertTimeline(result: result, isDark: isDark),

                      const SizedBox(height: 32),
                      _buildProTips(isDark),

                      const SizedBox(height: 40),
                      _buildFooter(isDark),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppDecorations.premiumGlassDecorationV2(isDark: isDark).copyWith(
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.secondary.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Text(crop.emoji, style: const TextStyle(fontSize: 40)),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تقرير التوصية الفنية',
                  style: AppTypography.bodySmall(isDark: isDark).copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                Text(
                  'محصول ${crop.name}',
                  style: AppTypography.h3(isDark: isDark).copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _CompactInfoTag(
                        Icons.aspect_ratio_rounded,
                        areaDisplay,
                        isDark,
                      ),
                      const SizedBox(width: 8),
                      _CompactInfoTag(
                        Icons.track_changes_rounded,
                        yieldDisplay,
                        isDark,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNPKSummary(bool isDark) {
    return Row(
      children: [
        NPKMini('نيتروجين (N)', result.requiredN, Colors.blue),
        const SizedBox(width: 12),
        NPKMini('فوسفور (P)', result.requiredP, Colors.orange),
        const SizedBox(width: 12),
        NPKMini('بوتاسيوم (K)', result.requiredK, Colors.purple),
      ],
    );
  }

  Widget _buildFertList(bool isDark) {
    return Column(
      children: [
        _FertItem(
          icon: Icons.science_rounded,
          name: 'يوريا (46% N)',
          amount: result.urea,
          color: Colors.amber.shade700,
          desc: 'مصدر النيتروجين الرئيسي للنبات',
          isDark: isDark,
        ),
        _FertItem(
          icon: Icons.grain_rounded,
          name: 'DAP (18-46-0)',
          amount: result.dap,
          color: Colors.blue.shade700,
          desc: 'مصدر النيتروجين والفوسفور الثنائي',
          isDark: isDark,
        ),
        _FertItem(
          icon: Icons.eco_rounded,
          name: 'بُوتاس (50% K₂O)',
          amount: result.mop,
          color: Colors.purple.shade600,
          desc: 'بوتاسيوم عالي النقاء لنمو الثمار',
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildProTips(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.premiumGlassDecorationV2(isDark: isDark).copyWith(
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.tips_and_updates_rounded,
                color: Colors.orange,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                'نصائح الخبراء للـ ${crop.name}',
                style: AppTypography.h3(isDark: isDark).copyWith(fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _TipItem('تأكد من توزيع الأسمدة بانتظام حول منطقة انتشار الجذور.'),
          _TipItem('يفضل التسميد في الصباح الباكر لتجنب الفقد بالتبخر.'),
          _TipItem('احرص على ري المحصول مباشرة بعد إتمام عملية التسميد.'),
        ],
      ),
    );
  }

  Widget _buildFooter(bool isDark) {
    return Column(
      children: [
        InfoTip(
          'هذه التوصيات استرشادية وفق معايير FAO العالمية. يُنصح دائماً بمراجعة المهندس الزراعي المختص.',
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Text(
              'حفظ في سجل المزرعة',
              style: AppTypography.h3(isDark: true).copyWith(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CompactInfoTag extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isDark;
  const _CompactInfoTag(this.icon, this.text, this.isDark);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            text,
            style: AppTypography.valueLabel(isDark: isDark).copyWith(
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _NutrientChart extends StatelessWidget {
  final FertilizerRecommendation result;
  final bool isDark;
  const _NutrientChart({required this.result, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final total = result.requiredN + result.requiredP + result.requiredK;
    if (total == 0) return const SizedBox.shrink();

    return Container(
      height: 220,
      padding: const EdgeInsets.all(24),
      decoration: AppDecorations.premiumGlassDecorationV2(isDark: isDark),
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(
                    value: result.requiredN,
                    color: Colors.blue,
                    title: 'N',
                    radius: 50,
                    titleStyle: AppTypography.valueLabel(isDark: isDark).copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  PieChartSectionData(
                    value: result.requiredP,
                    color: Colors.orange,
                    title: 'P',
                    radius: 50,
                    titleStyle: AppTypography.valueLabel(isDark: isDark).copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  PieChartSectionData(
                    value: result.requiredK,
                    color: Colors.purple,
                    title: 'K',
                    radius: 50,
                    titleStyle: AppTypography.valueLabel(isDark: isDark).copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 20),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ChartLegend('N', Colors.blue, result.requiredN),
              const SizedBox(height: 12),
              _ChartLegend('P', Colors.orange, result.requiredP),
              const SizedBox(height: 12),
              _ChartLegend('K', Colors.purple, result.requiredK),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChartLegend extends StatelessWidget {
  final String label;
  final Color color;
  final double value;
  const _ChartLegend(this.label, this.color, this.value);

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 8),
      Text(
        label,
        style: AppTypography.bodyMedium(isDark: false).copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
      const SizedBox(width: 8),
      Text(
        value.toStringAsFixed(1),
        style: AppTypography.valueLabel(isDark: false).copyWith(color: color),
      ),
    ],
  );
}

class _FertTimeline extends StatelessWidget {
  final FertilizerRecommendation result;
  final bool isDark;
  const _FertTimeline({required this.result, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _TimelineStep(
          title: 'تجهيز التربة',
          desc: 'قبل الزراعة: إضافة كامل كمية DAP ونصف كمية البوتاسيوم.',
          amount: '${(result.dap + result.mop * 0.5).toStringAsFixed(1)} كجم',
          isFirst: true,
          isDark: isDark,
        ),
        _TimelineStep(
          title: 'النمو الخضري',
          desc: 'بعد 30 يوم: إضافة نصف كمية اليوريا مع البوتاسيوم المتبقي.',
          amount:
              '${(result.urea * 0.5 + result.mop * 0.5).toStringAsFixed(1)} كجم',
          isDark: isDark,
        ),
        _TimelineStep(
          title: 'مرحلة الإثمار',
          desc: 'بعد 60 يوم: إضافة الكمية المتبقية من اليوريا لدعم الثمار.',
          amount: '${(result.urea * 0.5).toStringAsFixed(1)} كجم',
          isLast: true,
          isDark: isDark,
        ),
      ],
    );
  }
}

class _TimelineStep extends StatelessWidget {
  final String title, desc, amount;
  final bool isFirst, isLast, isDark;
  const _TimelineStep({
    required this.title,
    required this.desc,
    required this.amount,
    this.isFirst = false,
    this.isLast = false,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: isFirst ? AppColors.primary : Colors.grey.shade400,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.5),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1.5,
                    color: AppColors.primary.withValues(alpha: 0.15),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(16),
              decoration: AppDecorations.premiumGlassDecorationV2(
                isDark: isDark,
                radius: 18,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: AppTypography.h3(isDark: isDark).copyWith(
                          fontSize: 14,
                          color: isFirst ? AppColors.primary : null,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          amount,
                          style: AppTypography.valueLabel(isDark: isDark).copyWith(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    desc,
                    style: AppTypography.bodySmall(isDark: isDark).copyWith(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FertItem extends StatelessWidget {
  final IconData icon;
  final String name;
  final double amount;
  final Color color;
  final String desc;
  final bool isDark;

  const _FertItem({
    required this.icon,
    required this.name,
    required this.amount,
    required this.color,
    required this.desc,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.premiumGlassDecorationV2(isDark: isDark, radius: 18),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTypography.h3(isDark: isDark).copyWith(fontSize: 14),
                ),
                Text(
                  desc,
                  style: AppTypography.bodySmall(isDark: isDark).copyWith(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount.toStringAsFixed(1),
                style: AppTypography.valueLabel(isDark: isDark).copyWith(
                  color: color,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
              Text(
                'كجم',
                style: AppTypography.bodySmall(isDark: isDark).copyWith(
                  fontSize: 9,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TipItem extends StatelessWidget {
  final String text;
  const _TipItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline_rounded,
            color: Colors.green,
            size: 16,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodySmall(isDark: false).copyWith(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}
