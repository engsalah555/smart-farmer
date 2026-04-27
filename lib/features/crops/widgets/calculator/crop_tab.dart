import 'package:flutter/material.dart';
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
        // Category chips
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: cats.length,
            itemBuilder: (_, i) {
              final isSelected = cats[i] == selectedCat;
              return GestureDetector(
                onTap: () => onCatChanged(cats[i]),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(left: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: isSelected
                      ? AppDecorations.selectedDecoration(radius: 25).copyWith(
                          boxShadow: [
                            BoxShadow(
                              color: context.primary.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        )
                      : AppDecorations.premiumPillDecoration(isDark: isDark),
                  child: Center(
                    child: Text(
                      cats[i],
                      style: AppTypography.bodyMedium(isDark: isDark).copyWith(
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.white70 : AppColors.textPrimary),
                        fontWeight: isSelected
                            ? FontWeight.w900
                            : FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Grid
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 800
                  ? 6
                  : (constraints.maxWidth > 600 ? 4 : 3);
              return GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 0.82, // Taller for premium feel
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
                itemCount: filtered.length,
                itemBuilder: (_, i) {
                  final crop = filtered[i];
                  final isSel = selectedCrop?.name == crop.name;

                  return TweenAnimationBuilder<double>(
                    duration: Duration(milliseconds: 400 + (i % 12) * 50),
                    tween: Tween(begin: 0.0, end: 1.0),
                    curve: Curves.easeOutBack,
                    builder: (context, value, child) =>
                        Transform.scale(scale: value, child: child),
                    child: GestureDetector(
                      onTap: () => onCropSelected(crop),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        decoration: isSel
                            ? AppDecorations.selectedDecoration(
                                radius: 24,
                              ).copyWith(
                                boxShadow: [
                                  BoxShadow(
                                    color: context.primary.withValues(
                                      alpha: 0.4,
                                    ),
                                    blurRadius: 20,
                                    spreadRadius: -2,
                                  ),
                                ],
                              )
                            : AppDecorations.premiumGlassDecorationV2(
                                isDark: isDark,
                              ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSel
                                    ? Colors.white.withValues(alpha: 0.25)
                                    : (isDark
                                          ? Colors.white.withValues(alpha: 0.05)
                                          : Colors.black.withValues(
                                              alpha: 0.03,
                                            )),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white10),
                              ),
                              child: Text(
                                crop.emoji,
                                style: const TextStyle(fontSize: 32),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              crop.name,
                              textAlign: TextAlign.center,
                              style: AppTypography.bodyMedium(isDark: isDark)
                                  .copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: isSel
                                        ? Colors.white
                                        : (isDark
                                              ? Colors.white
                                              : AppColors.textPrimary),
                                    fontSize: 13,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${crop.avgYield} طن/هكتار',
                              style: AppTypography.valueLabel(isDark: isDark)
                                  .copyWith(
                                    color: isSel
                                        ? Colors.white.withValues(alpha: 0.9)
                                        : Colors.grey,
                                    fontSize: 10,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
