import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_typography.dart';
import 'calculator_shared_widgets.dart';

class SoilTab extends StatelessWidget {
  final TextEditingController nCtrl;
  final TextEditingController pCtrl;
  final TextEditingController kCtrl;
  final TextEditingController phCtrl;
  final VoidCallback onPhChange;
  final VoidCallback onCalculate;
  final bool isDark;

  const SoilTab({
    super.key,
    required this.nCtrl,
    required this.pCtrl,
    required this.kCtrl,
    required this.phCtrl,
    required this.onPhChange,
    required this.onCalculate,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel(
            'تحليل حموضة التربة',
            icon: Icons.science_outlined,
          ),
          const SizedBox(height: 12),
          _buildPHCard(context),

          const SizedBox(height: 32),
          const SectionLabel(
            'العناصر المغذية (PPM)',
            icon: Icons.opacity_outlined,
          ),
          const SizedBox(height: 12),
          _buildNutrientsCard(context),

          const SizedBox(height: 32),
          const InfoTip(
            'تعتبر قيم NPK و pH الأساس العلمي لبناء خطة التسميد. للحصول على أدق النتائج، يفضل استخدام أحدث تقرير من المختبر الزراعي.',
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildPHCard(BuildContext context) {
    final double ph = double.tryParse(phCtrl.text) ?? 7.0;
    final Color phColor = _getPHColor(context, ph);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppDecorations.cardDecoration(isDark: isDark).copyWith(
        border: Border.all(color: phColor.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'درجة الحموضة الحالية',
                    style: AppTypography.bodySmall(isDark: isDark).copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getPHStatus(ph),
                    style: AppTypography.h3(
                      isDark: isDark,
                    ).copyWith(color: phColor, fontSize: 15),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: phColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: phColor.withValues(alpha: 0.2)),
                ),
                child: Text(
                  ph.toStringAsFixed(1),
                  style: AppTypography.valueLabel(isDark: isDark).copyWith(
                    color: phColor,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: phColor,
              inactiveTrackColor: phColor.withValues(alpha: 0.1),
              thumbColor: Colors.white,
              overlayColor: phColor.withValues(alpha: 0.2),
              trackHeight: 10,
              thumbShape: _CustomThumbShape(color: phColor),
              trackShape: const RoundedRectSliderTrackShape(),
            ),
            child: Slider(
              value: ph,
              min: 4.0,
              max: 9.0,
              divisions: 50,
              onChanged: (val) {
                phCtrl.text = val.toStringAsFixed(1);
                onPhChange();
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _phLimitLabel('4.0', 'حمضي جداً'),
              _phLimitLabel('7.0', 'متعادل'),
              _phLimitLabel('9.0', 'قلوي جداً'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppDecorations.cardDecoration(isDark: isDark),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: NutrientField(
                  ctrl: nCtrl,
                  label: 'نيتروجين (N)',
                  info: 'النيتروجين ضروري للنمو الخضري والكثافة الورقية.',
                  color: Colors.blue.shade600,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: NutrientField(
                  ctrl: pCtrl,
                  label: 'فوسفور (P)',
                  info: 'الفوسفور يدعم نمو الجذور والتبكير في الإزهار.',
                  color: Colors.orange.shade600,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          NutrientField(
            ctrl: kCtrl,
            label: 'بوتاسيوم (K)',
            info: 'البوتاسيوم يعزز جودة الثمار ومقاومة المحصول للإجهاد.',
            color: Colors.purple.shade600,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _phLimitLabel(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.valueLabel(isDark: isDark).copyWith(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted,
          ),
        ),
        Text(
          label,
          style: AppTypography.bodySmall(isDark: isDark).copyWith(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  Color _getPHColor(BuildContext context, double ph) {
    if (ph < 5.5) return Colors.redAccent;
    if (ph < 6.5) return Colors.orangeAccent;
    if (ph <= 7.5) return context.primary;
    if (ph < 8.5) return Colors.blueAccent;
    return Colors.deepPurpleAccent;
  }

  String _getPHStatus(double ph) {
    if (ph < 5.5) return 'حمضية جداً (تتطلب معالجة)';
    if (ph < 6.5) return 'حمضية قليلاً';
    if (ph <= 7.5) return 'مثالية لغالبية المحاصيل';
    if (ph < 8.5) return 'قلوية قليلاً';
    return 'قلوية جداً (تتطلب معالجة)';
  }
}

class _CustomThumbShape extends SliderComponentShape {
  final Color color;
  const _CustomThumbShape({required this.color});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size(24, 24);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;
    final paintGlow = Paint()
      ..color = color.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(center, 18, paintGlow);

    final paintBg = Paint()..color = Colors.white;
    canvas.drawCircle(center, 12, paintBg);

    final paintFill = Paint()..color = color;
    canvas.drawCircle(center, 8, paintFill);
  }
}
