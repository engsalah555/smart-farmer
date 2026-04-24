import 'package:flutter/material.dart';
import 'package:smart_farm2/core/widgets/app_fonts.dart';
import '../../../core/constants.dart';
import '../../../core/utils/icon_helper.dart';

class MarketplaceStickyHeader extends StatelessWidget {
  final bool isBuying;
  final TabController tabController;
  final List<Map<String, dynamic>> categories;
  final Function(int) onCategoryTap;
  final Widget? searchWidget;
  final Widget? filterWidget;

  const MarketplaceStickyHeader({
    super.key,
    required this.isBuying,
    required this.tabController,
    required this.categories,
    required this.onCategoryTap,
    this.searchWidget,
    this.filterWidget,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Calculate dynamic height based on features visible
    double headerHeight = 110; // Base height
    if (isBuying) {
      if (searchWidget != null) headerHeight += 65;
      if (filterWidget != null) headerHeight += 55;
    } else {
      headerHeight = 110; // Mirror buyer base height for consistency
    }

    return SliverPersistentHeader(
      pinned: true,
      delegate: MarketplaceHeaderDelegate(
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
            child: isBuying
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 20),
                      if (searchWidget != null) ...[
                        searchWidget!,
                        const SizedBox(height: 8),
                      ],
                      if (filterWidget != null) ...[
                        filterWidget!,
                        const SizedBox(height: 4),
                      ],
                      _buildCategoryBar(context),
                      const SizedBox(height: 8),
                    ],
                  )
                : Container(
                    padding: const EdgeInsets.only(
                      top: 30,
                      left: 24,
                      right: 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(
                                  alpha: 0.15,
                                ),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: const Icon(
                                Icons
                                    .storefront_rounded, // Better icon for store management
                                color: AppColors.primary,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ' منتجاتي',
                                  style: context.font24.semiBold.copyWith(
                                    color: context.textColor,
                                  ),
                                ),
                                Container(
                                  height: 3,
                                  width: 30,
                                  margin: const EdgeInsets.only(top: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
          onTap: onCategoryTap,
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
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.3,
                                  ),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            IconHelper.getIconByName(cat['icon']),
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

class MarketplaceHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double minHeight;
  final double maxHeight;

  MarketplaceHeaderDelegate({
    required this.child,
    required this.minHeight,
    required this.maxHeight,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(covariant MarketplaceHeaderDelegate oldDelegate) {
    return oldDelegate.maxHeight != maxHeight ||
        oldDelegate.minHeight != minHeight ||
        oldDelegate.child != child;
  }
}
