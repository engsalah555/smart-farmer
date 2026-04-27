import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../features/crops/utils/crop_constants.dart';

class CategoryFilterChips extends StatelessWidget {
  final String selectedFilter;
  final List<String> filters;
  final Function(String) onFilterChanged;
  final bool isDark;

  const CategoryFilterChips({
    super.key,
    required this.selectedFilter,
    required this.filters,
    required this.onFilterChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(left: 10),
            child: GestureDetector(
              onTap: () => onFilterChanged(filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? context.primary
                      : AppColors.getSurface(isDark),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? context.primary
                        : (isDark
                              ? Colors.white10
                              : Colors.black.withValues(alpha: 0.05)),
                    width: 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: context.primary.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isDark ? 0.2 : 0.03,
                            ),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      CropConstants.categoryIcons[filter],
                      size: 16,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.white70 : AppColors.textSecondary),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      filter,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.white70 : AppColors.textPrimary),
                        fontWeight: isSelected
                            ? FontWeight.w800
                            : FontWeight.w600,
                        fontSize: 13,
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
}
