import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:smart_farm2/core/widgets/app_fonts.dart';
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
    final bool isDark = context.isDark;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.6,
      maxChildSize: 0.98,
      builder: (_, ctrl) {
        return Container(
          decoration: BoxDecoration(
            color: context.backgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(color: context.border, width: 1.5),
          ),
          child: Column(
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: context.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Expanded(
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: ListView(
                    controller: ctrl,
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    children: [
                      _buildHeader(context, isDark),
                      const SizedBox(height: 32),

                      _buildNPKDashboard(context, isDark),
                      const SizedBox(height: 32),

                      const SectionLabel(
                        'توزيع الاحتياجات الغذائية',
                        icon: Icons.analytics_outlined,
                      ),
                      _NutrientChart(result: result, isDark: isDark),

                      const SizedBox(height: 32),
                      const SectionLabel(
                        'خطة التسميد المقترحة',
                        icon: Icons.science_outlined,
                      ),
                      _buildFertList(context, isDark),

                      const SizedBox(height: 32),
                      const SectionLabel(
                        'الجدول الزمني للتطبيق',
                        icon: Icons.event_note_outlined,
                      ),
                      _FertTimeline(result: result, isDark: isDark),

                      const SizedBox(height: 32),
                      _buildProTips(context, isDark),

                      const SizedBox(height: 40),
                      _buildFooter(context, isDark),
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
      decoration: AppDecorations.cardDecoration(
        isDark: isDark,
      ).copyWith(border: Border.all(color: context.primary, width: 2)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: context.border),
            ),
            child: Text(crop.emoji, style: const TextStyle(fontSize: 44)),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'التوصية الفنية المتقدمة',
                  style: AppTypography.bodySmall(isDark: isDark).copyWith(
                    color: context.primary,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'محصول ${crop.name}',
                  style: AppTypography.h2(
                    isDark: isDark,
                  ).copyWith(fontSize: 28, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _CompactInfoTag(
                      Icons.straighten_rounded,
                      areaDisplay,
                      isDark,
                    ),
                    _CompactInfoTag(
                      Icons.auto_graph_rounded,
                      yieldDisplay,
                      isDark,
                    ),
                    _CompactInfoTag(
                      Icons.science_rounded,
                      'pH ${ph.toStringAsFixed(1)}',
                      isDark,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNPKDashboard(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel(
          'الاحتياج الإجمالي للمزرعة',
          icon: Icons.data_usage_rounded,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: AppDecorations.cardDecoration(isDark: isDark),
          child: Column(
            children: [
              _npkRow('نيتروجين (N)', result.requiredN, context.info, isDark),
              Divider(height: 24, color: context.border),
              _npkRow('فوسفور (P)', result.requiredP, context.warning, isDark),
              Divider(height: 24, color: context.border),
              _npkRow(
                'بوتاسيوم (K)',
                result.requiredK,
                context.primary,
                isDark,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _npkRow(String label, double value, Color color, bool isDark) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: AppTypography.h3(isDark: isDark).copyWith(fontSize: 15),
        ),
        const Spacer(),
        Text(
          value.toStringAsFixed(1),
          style: AppTypography.valueLabel(
            isDark: isDark,
          ).copyWith(color: color, fontSize: 22, fontWeight: FontWeight.w900),
        ),
        const SizedBox(width: 8),
        Text(
          'كجم',
          style: AppTypography.bodySmall(isDark: isDark).copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildFertList(BuildContext context, bool isDark) {
    return Column(
      children: [
        _FertItem(
          icon: Icons.science_outlined,
          name: 'يوريا (46% N)',
          amount: result.urea,
          color: context.info,
          desc: 'المصدر الأساسي للنيتروجين لتعزيز النمو الخضري.',
          isDark: isDark,
        ),
        _FertItem(
          icon: Icons.grain_outlined,
          name: 'DAP (18-46-0)',
          amount: result.dap,
          color: context.warning,
          desc: 'توفير الفسفور لتأسيس الجذور والنيتروجين المبكر.',
          isDark: isDark,
        ),
        _FertItem(
          icon: Icons.eco_outlined,
          name: 'MOP (بُوتاس)',
          amount: result.mop,
          color: context.primary,
          desc: 'تعزيز جودة الثمار ومقاومة المحصول للإجهاد.',
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildProTips(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppDecorations.cardDecoration(isDark: isDark).copyWith(
        border: Border.all(color: context.warning.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                color: context.warning,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'إرشادات التطبيق الميداني',
                style: AppTypography.h3(isDark: isDark).copyWith(
                  fontSize: 16,
                  color: isDark ? AppColors.darkTextPrimary : context.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _TipItem(
            'تجنب خلط الأسمدة في خزانات الري دون التأكد من التوافق الكيميائي.',
          ),
          _TipItem(
            'يفضل تقسيم الجرعات لتقليل الفقد بالتبخر أو الغسيل في التربة الرملية.',
          ),
          _TipItem(
            'التزم بفترة الأمان (PHI) المحددة قبل البدء في عمليات الحصاد.',
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, bool isDark) {
    return Column(
      children: [
        const InfoTip(
          'تعتمد هذه التوصيات على معادلات FAO القياسية. قد تختلف الاحتياجات الفعلية حسب التغيرات المناخية ونوع التربة.',
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton.icon(
            label: Text(
              'اعتماد وحفظ الخطة',
              style: context.font16.semiBold.copyWith(color: context.white),
            ),
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: context.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w900,
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: context.primary),
          const SizedBox(width: 8),
          Text(text, style: context.font14),
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

    return Semantics(
      label:
          'مخطط توزيع العناصر الغذائية: نيتروجين ${result.requiredN}, فوسفور ${result.requiredP}, بوتاسيوم ${result.requiredK}',
      child: Container(
        height: 240,
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(24),
        decoration: AppDecorations.cardDecoration(isDark: isDark),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 4,
                  centerSpaceRadius: 40,
                  sections: [
                    PieChartSectionData(
                      value: result.requiredN,
                      color: context.info,
                      title: 'N',
                      radius: 50,
                      titleStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      value: result.requiredP,
                      color: context.warning,
                      title: 'P',
                      radius: 50,
                      titleStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      value: result.requiredK,
                      color: context.primary,
                      title: 'K',
                      radius: 50,
                      titleStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ChartLegend('N', context.info, result.requiredN, isDark),
                  const SizedBox(height: 16),
                  _ChartLegend('P', context.warning, result.requiredP, isDark),
                  const SizedBox(height: 16),
                  _ChartLegend('K', context.primary, result.requiredK, isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartLegend extends StatelessWidget {
  final String label;
  final Color color;
  final double value;
  final bool isDark;
  const _ChartLegend(this.label, this.color, this.value, this.isDark);

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      const SizedBox(width: 10),
      Text(
        label,
        style: AppTypography.bodySmall(
          isDark: isDark,
        ).copyWith(fontWeight: FontWeight.w900),
      ),
      const Spacer(),
      Text(
        value.toStringAsFixed(1),
        style: AppTypography.valueLabel(
          isDark: isDark,
        ).copyWith(color: color, fontWeight: FontWeight.w900),
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
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          _TimelineStep(
            title: 'مرحلة التأسيس',
            desc: 'إضافة كامل الفوسفور (DAP) ونصف البوتاسيوم.',
            amount: '${(result.dap + result.mop * 0.5).toStringAsFixed(1)} كجم',
            isFirst: true,
            isDark: isDark,
          ),
          _TimelineStep(
            title: 'النمو النشط',
            desc: 'إضافة 50% من اليوريا والنسبة المتبقية من البوتاسيوم.',
            amount:
                '${(result.urea * 0.5 + result.mop * 0.5).toStringAsFixed(1)} كجم',
            isDark: isDark,
          ),
          _TimelineStep(
            title: 'مرحلة التحجيم',
            desc: 'إضافة ما تبقى من اليوريا لدعم الثمار والإنتاج.',
            amount: '${(result.urea * 0.5).toStringAsFixed(1)} كجم',
            isLast: true,
            isDark: isDark,
          ),
        ],
      ),
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
                margin: const EdgeInsets.only(top: 6),
                decoration: BoxDecoration(
                  color: isFirst ? context.primary : context.border,
                  shape: BoxShape.circle,
                  border: Border.all(color: context.backgroundColor, width: 2),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: context.border,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(20),
              decoration: AppDecorations.cardDecoration(isDark: isDark),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: AppTypography.h3(
                          isDark: isDark,
                        ).copyWith(fontSize: 15, fontWeight: FontWeight.w900),
                      ),
                      Text(
                        amount,
                        style: context.font14.bold.copyWith(
                          color: context.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    desc,
                    style: AppTypography.bodySmall(isDark: isDark).copyWith(
                      fontSize: 13,
                      height: 1.4,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
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
      decoration: AppDecorations.cardDecoration(isDark: isDark),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.border),
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
                  style: AppTypography.h3(
                    isDark: isDark,
                  ).copyWith(fontSize: 16, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Text(
                  desc,
                  style: AppTypography.bodySmall(isDark: isDark).copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount.toStringAsFixed(1),
                style: AppTypography.valueLabel(isDark: isDark).copyWith(
                  color: color,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                ),
              ),
              Text(
                'كجم',
                style: AppTypography.bodySmall(isDark: isDark).copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textMuted,
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
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_rounded, color: context.primary, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodySmall(isDark: context.isDark).copyWith(
                fontSize: 13,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
