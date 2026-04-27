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
          // pH Card
          _buildPHCard(context),
          const SizedBox(height: 24),

          // Nutrients Card
          _buildNutrientsCard(),

          const SizedBox(height: 40),
          _buildCalculateButton(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPHCard(BuildContext context) {
    final double ph = double.tryParse(phCtrl.text) ?? 7.0;
    final Color phColor = _getPHColor(context, ph);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppDecorations.premiumGlassDecorationV2(isDark: isDark)
          .copyWith(
            border: Border.all(
              color: phColor.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                   Icon(
                    Icons.science_rounded,
                    color: context.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'درجة حموضة التربة (pH)',
                    style: AppTypography.h3(
                      isDark: isDark,
                    ).copyWith(fontSize: 16),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: phColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: phColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  ph.toStringAsFixed(1),
                  style: AppTypography.valueLabel(
                    isDark: isDark,
                  ).copyWith(color: phColor, fontSize: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _getPHStatus(ph),
            style: AppTypography.bodyMedium(isDark: isDark).copyWith(
              color: phColor,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 24),

          // Custom Styled Slider
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: phColor,
              inactiveTrackColor: phColor.withValues(alpha: 0.1),
              thumbColor: Colors.white,
              overlayColor: phColor.withValues(alpha: 0.2),
              trackHeight: 12,
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

          const SizedBox(height: 10),
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

  Widget _buildNutrientsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppDecorations.premiumGlassDecorationV2(isDark: isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.opacity_rounded,
                color: AppColors.secondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'العناصر المغذية المتوفرة (PPM)',
                style: AppTypography.h3(isDark: isDark).copyWith(fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: NutrientField(
                  ctrl: nCtrl,
                  label: 'نيتروجين (N)',
                  info:
                      'كمية النيتروجين المتاحة في التربة بوحدة جزء في المليون (ppm). النيتروجين ضروري للنمو الخضري.',
                  isDark: isDark,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: NutrientField(
                  ctrl: pCtrl,
                  label: 'فوسفور (P)',
                  info:
                      'كمية الفوسفور المتاحة في التربة. الفوسفور حيوي لتطور الجذور والأزهار.',
                  isDark: isDark,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          NutrientField(
            ctrl: kCtrl,
            label: 'بوتاسيوم (K)',
            info:
                'كمية البوتاسيوم المتاحة في التربة. البوتاسيوم يعزز جودة الثمار ومقاومة الأمراض.',
            isDark: isDark,
            color: Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildCalculateButton() {
    return Container(
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            AppColors.secondary,
            AppColors.secondary.withValues(alpha: 0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.auto_awesome_rounded, size: 24),
        label: Text(
          'احسب التوصية السمادية',
          style: AppTypography.h3(isDark: true).copyWith(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        onPressed: onCalculate,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  Widget _phLimitLabel(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.valueLabel(
            isDark: isDark,
          ).copyWith(fontSize: 10, color: Colors.grey),
        ),
        Text(
          label,
          style: AppTypography.bodySmall(
            isDark: isDark,
          ).copyWith(fontSize: 9, color: Colors.grey),
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
    if (ph < 5.5) return 'تربة حمضية جداً (تحتاج معالجة)';
    if (ph < 6.5) return 'تربة حمضية قليلاً';
    if (ph <= 7.5) return 'تربة مثالية لغالبية المحاصيل';
    if (ph < 8.5) return 'تربة قلوية قليلاً';
    return 'تربة قلوية جداً (تحتاج معالجة)';
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

    // Draw glow
    final paintGlow = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(center, 16, paintGlow);

    // Draw outer circle
    final paintBg = Paint()..color = Colors.white;
    canvas.drawCircle(center, 12, paintBg);

    // Draw inner circle
    final paintFill = Paint()..color = color;
    canvas.drawCircle(center, 8, paintFill);
  }
}
