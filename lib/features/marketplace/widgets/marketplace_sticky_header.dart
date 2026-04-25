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
    // Calculate dynamic height based on features visible
    double headerHeight = 100; // Base height
    if (isBuying) {
      if (searchWidget != null) headerHeight += 65;
      if (filterWidget != null) headerHeight += 55;
    } else {
      headerHeight = 100; 
    }

    return SliverPersistentHeader(
      pinned: true,
      delegate: MarketplaceHeaderDelegate(
        minHeight: headerHeight,
        maxHeight: headerHeight,
        child: Container(
          color: context.backgroundColor,
          child: Container(
            decoration: BoxDecoration(
              color: context.backgroundColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: isBuying
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 16),
                      if (searchWidget != null) ...[
                        searchWidget!,
                        const SizedBox(height: 8),
                      ],
                      if (filterWidget != null) ...[
                        filterWidget!,
                        const SizedBox(height: 4),
                      ],
                      _buildCategoryBar(context),
                    ],
                  )
                : Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: context.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.inventory_2_outlined,
                            color: context.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'إدارة منتجاتي',
                              style: context.font20.bold.copyWith(
                                color: context.textPrimary,
                              ),
                            ),
                            Text(
                              'تحكم في مخزونك وعروضك',
                              style: context.font12.medium.copyWith(
                                color: context.textSecondary,
                              ),
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
    return AnimatedBuilder(
      animation: tabController,
      builder: (context, _) {
        return TabBar(
          controller: tabController,
          isScrollable: true,
          dividerColor: Colors.transparent,
          indicatorColor: Colors.transparent,
          tabAlignment: TabAlignment.start,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          labelPadding: const EdgeInsets.symmetric(horizontal: 4),
          indicator: const BoxDecoration(),
          onTap: onCategoryTap,
          tabs: List.generate(categories.length, (index) {
            final cat = categories[index];
            final isSelected = tabController.index == index;

            return Tab(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? context.primary : context.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? Colors.transparent : context.border.withValues(alpha: 0.5),
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
                      IconHelper.getIconByName(cat['icon']),
                      size: 16,
                      color: isSelected ? Colors.white : context.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      cat['label'] ?? '',
                      style: context.font14.bold.copyWith(
                        color: isSelected ? Colors.white : context.textPrimary.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
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
