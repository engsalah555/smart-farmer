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
          const SizedBox(height: 32),

          const SectionLabel(
            'مواصفات المساحة والإنتاج',
            icon: Icons.straighten_outlined,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: AppDecorations.cardDecoration(isDark: isDark),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      flex: 3,
                      child: StyledField(
                        ctrl: areaCtrl,
                        label: 'المساحة المزروعة',
                        hint: 'أدخل الرقم...',
                        keyboard: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        icon: Icons.square_foot_rounded,
                        isDark: isDark,
                        onChanged: (_) => onAreaChanged(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(flex: 2, child: _buildUnitSelector(context)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildConversionTip(context),
                const SizedBox(height: 32),
                StyledField(
                  ctrl: yieldCtrl,
                  label: 'الإنتاج المستهدف (طن/هكتار)',
                  hint: crop != null ? 'افتراضي: ${crop!.avgYield}' : '0.0',
                  keyboard: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  icon: Icons.trending_up_rounded,
                  isDark: isDark,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
          const InfoTip(
            'حساب المساحة بالهكتار ضروري لتوفير أدق التوصيات السمادية المتوافقة مع المعايير الدولية.',
          ),
        ],
      ),
    );
  }

  Widget _buildCropBanner(BuildContext context) {
    if (crop == null) {
      return const InfoTip('يرجى اختيار المحصول أولاً من تبويب المحاصيل.');
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.cardDecoration(isDark: isDark).copyWith(
        border: Border.all(
          color: context.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
        color: context.primary.withValues(alpha: 0.05),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white24),
            ),
            child: Text(crop!.emoji, style: const TextStyle(fontSize: 32)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  crop!.name,
                  style: AppTypography.h3(
                    isDark: isDark,
                  ).copyWith(fontWeight: FontWeight.w900),
                ),
                Text(
                  'متوسط الإنتاجية: ${crop!.avgYield} طن/هكتار',
                  style: AppTypography.bodySmall(isDark: isDark).copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversionTip(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: context.primary, size: 16),
          const SizedBox(width: 8),
          Text(
            'ما يعادل: ',
            style: AppTypography.bodySmall(isDark: isDark).copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
          Text(
            '${areaHa.toStringAsFixed(3)} هكتار',
            style: AppTypography.valueLabel(isDark: isDark).copyWith(
              fontSize: 14,
              color: context.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 4, bottom: 10),
          child: Text(
            'الوحدة',
            style: AppTypography.bodySmall(isDark: isDark).copyWith(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
        ),
        Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: AppDecorations.inputDecoration(isDark: isDark),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: areaUnit,
              isExpanded: true,
              dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(AppDecorations.inputRadius),
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: context.primary,
              ),
              items: areaUnits.map((u) {
                return DropdownMenuItem(
                  value: u,
                  child: Text(
                    u,
                    style: AppTypography.bodyMedium(
                      isDark: isDark,
                    ).copyWith(fontWeight: FontWeight.bold),
                  ),
                );
              }).toList(),
              onChanged: (v) => onUnitChanged(v!),
            ),
          ),
        ),
      ],
    );
  }
}
