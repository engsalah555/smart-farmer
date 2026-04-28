import 'package:flutter/material.dart';
import 'package:smart_farm2/core/widgets/app_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_typography.dart';
import '../../models/fertilizer_models.dart';
import '../../data/fertilizer_crop_profiles.dart';

class CropTab extends StatelessWidget {
  final List<String> cats;
  final String selectedCat;
  final CropFertilizerProfile? selectedCrop;
  final ValueChanged<String> onCatChanged;
  final ValueChanged<CropFertilizerProfile> onCropSelected;
  final bool isDark;

  const CropTab({
    super.key,
    required this.cats,
    required this.selectedCat,
    required this.selectedCrop,
    required this.onCatChanged,
    required this.onCropSelected,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final filtered = selectedCat == 'الكل'
        ? kCropProfiles
        : kCropProfiles.where((c) => c.category == selectedCat).toList();

    return Column(
      children: [
        _buildCategorySelector(context),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.85,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: filtered.length,
            itemBuilder: (_, i) {
              final crop = filtered[i];
              final isSelected = selectedCrop?.name == crop.name;
              return _buildCropCard(context, crop, isSelected);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelector(BuildContext context) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: context.backgroundColor,
        border: Border(bottom: BorderSide(color: context.border)),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        itemCount: cats.length,
        itemBuilder: (_, i) {
          final cat = cats[i];
          final isSelected = cat == selectedCat;

          return Padding(
            padding: const EdgeInsets.only(left: 10),
            child: GestureDetector(
              onTap: () => onCatChanged(cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: isSelected ? context.primary : context.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? Colors.transparent : context.border,
                    width: 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: context.primary.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getIcon(cat),
                      size: 16,
                      color: isSelected ? Colors.white : context.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      cat,
                      style: context.font14.bold.copyWith(
                        color: isSelected ? Colors.white : context.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getIcon(String cat) {
    switch (cat) {
      case 'محاصيل حقلية':
        return Icons.grass_rounded;
      case 'خضروات':
        return Icons.eco_rounded;
      case 'أشجار فاكهة':
        return Icons.park_rounded;
      case 'أعلاف':
        return Icons.agriculture_rounded;
      default:
        return Icons.grid_view_rounded;
    }
  }

  Widget _buildCropCard(
    BuildContext context,
    CropFertilizerProfile crop,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () => onCropSelected(crop),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: AppDecorations.cardDecoration(isDark: isDark).copyWith(
          border: Border.all(
            color: isSelected
                ? context.primary
                : (isDark ? Colors.white10 : Colors.grey.shade200),
            width: isSelected ? 2 : 1,
          ),
          color: isSelected
              ? context.primary.withValues(alpha: 0.1)
              : (isDark ? AppColors.darkSurface : Colors.white),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? context.primary.withValues(alpha: 0.1)
                    : (isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.grey.shade50),
                shape: BoxShape.circle,
              ),
              child: Text(crop.emoji, style: const TextStyle(fontSize: 28)),
            ),
            const SizedBox(height: 10),
            Text(
              crop.name,
              style: AppTypography.bodySmall(
                isDark: isDark,
              ).copyWith(fontWeight: FontWeight.w900, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            Text(
              '${crop.avgYield} طن/هكتار',
              style: AppTypography.bodySmall(isDark: isDark).copyWith(
                fontSize: 9,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
