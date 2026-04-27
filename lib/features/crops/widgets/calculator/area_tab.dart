import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_typography.dart';
import '../../models/fertilizer_models.dart';
import 'calculator_shared_widgets.dart';

class AreaTab extends StatelessWidget {
  final CropFertilizerProfile? crop;
  final TextEditingController areaCtrl;
  final TextEditingController yieldCtrl;
  final String areaUnit;
  final List<String> areaUnits;
  final double areaHa;
  final ValueChanged<String> onUnitChanged;
  final VoidCallback onAreaChanged;
  final VoidCallback onNext;
  final bool isDark;

  const AreaTab({
    super.key,
    required this.crop,
    required this.areaCtrl,
    required this.yieldCtrl,
    required this.areaUnit,
    required this.areaUnits,
    required this.areaHa,
    required this.onUnitChanged,
    required this.onAreaChanged,
    required this.onNext,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCropBanner(context),
          const SizedBox(height: 24),

          // Area Info Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: AppDecorations.premiumGlassDecorationV2(isDark: isDark),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.straighten_rounded,
                      color: context.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'المساحة المزروعة',
                      style: AppTypography.h3(
                        isDark: isDark,
                      ).copyWith(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: StyledField(
                        ctrl: areaCtrl,
                        label: 'المساحة',
                        keyboard: TextInputType.number,
                        isDark: isDark,
                        icon: Icons.aspect_ratio_rounded,
                        onChanged: (_) => onAreaChanged(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: _buildUnitSelector(context)),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: context.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: context.primary.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: context.primary,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'ما يعادل: ',
                        style: AppTypography.bodySmall(isDark: isDark).copyWith(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : Colors.grey,
                        ),
                      ),
                      Text(
                        '${areaHa.toStringAsFixed(4)} هكتار',
                        style: AppTypography.valueLabel(
                          isDark: isDark,
                        ).copyWith(fontSize: 14, color: context.primary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Yield Info Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: AppDecorations.premiumGlassDecorationV2(isDark: isDark),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.trending_up_rounded,
                      color: AppColors.secondary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'الإنتاجية المخطط لها',
                      style: AppTypography.h3(
                        isDark: isDark,
                      ).copyWith(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                StyledField(
                  ctrl: yieldCtrl,
                  label: 'الإنتاجية المستهدفة (طن/هكتار)',
                  hint: crop != null ? 'افتراضي: ${crop!.avgYield}' : '0.0',
                  keyboard: TextInputType.number,
                  isDark: isDark,
                  icon: Icons.auto_graph_rounded,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.science_outlined, size: 18),
              label: Text(
                'التالي: تحليل التربة',
                style: AppTypography.bodyMedium(
                  isDark: false,
                ).copyWith(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                elevation: 4,
                shadowColor: context.primary.withValues(alpha: 0.4),
              ),
              onPressed: onNext,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCropBanner(BuildContext context) {
    if (crop == null) return const InfoTip('يرجى اختيار المحصول أولاً');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: AppDecorations.premiumGlassDecorationV2(isDark: isDark)
          .copyWith(
            border: Border.all(color: context.primary.withValues(alpha: 0.2)),
            gradient: LinearGradient(
              colors: [
                context.primary.withValues(alpha: 0.1),
                AppColors.secondary.withValues(alpha: 0.05),
              ],
            ),
          ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24),
            ),
            child: Text(crop!.emoji, style: const TextStyle(fontSize: 36)),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  crop!.name,
                  style: AppTypography.h3(
                    isDark: isDark,
                  ).copyWith(fontSize: 22, fontWeight: FontWeight.w900),
                ),
                Text(
                  'متوسط الإنتاجية: ${crop!.avgYield} طن/هكتار',
                  style: AppTypography.bodySmall(isDark: isDark).copyWith(
                    color: isDark ? AppColors.darkTextSecondary : Colors.grey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitSelector(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.primary.withValues(alpha: 0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: areaUnit,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: context.primary,
          ),
          items: areaUnits
              .map(
                (u) => DropdownMenuItem(
                  value: u,
                  child: Text(
                    u,
                    style: AppTypography.bodySmall(
                      isDark: isDark,
                    ).copyWith(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              )
              .toList(),
          onChanged: (v) => onUnitChanged(v!),
        ),
      ),
    );
  }
}
