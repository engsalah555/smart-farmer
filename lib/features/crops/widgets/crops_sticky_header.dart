import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants.dart';
import '../../../core/widgets/sliver_header_delegate.dart';
import '../../marketplace/widgets/glassmorphic_search_bar.dart';

class CropsStickyHeader extends StatelessWidget {
  final String searchQuery;
  final Function(String) onSearchChanged;
  final TabController tabController;
  final List<String> tabs;
  final Function(int) onTabTap;

  const CropsStickyHeader({
    super.key,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.tabController,
    required this.tabs,
    required this.onTabTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    double headerHeight = 175; // Adjust based on search bar and tabs height

    return SliverPersistentHeader(
      pinned: true,
      delegate: SliverHeaderDelegate(
        minHeight: headerHeight,
        maxHeight: headerHeight,
        child: Container(
          color: AppColors.primary,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.getBackground(isDark),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                GlassmorphicSearchBar(
                  hintText: 'ابحث عن محصول أو دليل...',
                  onChanged: onSearchChanged,
                  onFilterPressed: () {
                    context.push('/fertilizer_calculator');
                  },
                ),
                const SizedBox(height: 8),
                _buildCategoryBar(context),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Convert tabs strings into categories for styling
    final List<Map<String, dynamic>> categories = tabs.map((t) {
      IconData icon = Icons.grass;
      if (t == 'محاصيلي') icon = Icons.eco_rounded;
      if (t == 'دليل النبات') icon = Icons.menu_book_rounded;
      if (t == 'التحكم بالري') icon = Icons.water_drop_rounded;
      return {'label': t, 'icon': icon};
    }).toList();

    return AnimatedBuilder(
      animation: tabController,
      builder: (context, _) {
        return TabBar(
          controller: tabController,
          isScrollable: true,
          dividerColor: Colors.transparent,
          indicatorColor: Colors.transparent,
          tabAlignment: TabAlignment.start,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          labelPadding: const EdgeInsets.symmetric(horizontal: 6),
          labelColor: Colors.transparent,
          unselectedLabelColor: Colors.transparent,
          indicator: const BoxDecoration(),
          onTap: onTabTap,
          tabs: List.generate(categories.length, (index) {
            final cat = categories[index];
            final isSelected = tabController.index == index;

            return Tab(
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 200),
                tween: Tween(begin: 1.0, end: isSelected ? 1.05 : 1.0),
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.getSurface(isDark),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : AppColors.border(isDark),
                          width: isSelected ? 0 : 1.2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            cat['icon'],
                            size: 16,
                            color: isSelected
                                ? Colors.white
                                : AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            cat['label'] ?? '',
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.getTextColor(
                                      isDark,
                                    ).withValues(alpha: 0.7),
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                              fontSize: 14,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
