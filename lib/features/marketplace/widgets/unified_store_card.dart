import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants.dart';
import '../../../core/models/store_model.dart';
import '../../../core/widgets/app_fonts.dart';
import '../../../core/widgets/fade_in_slide.dart';
import '../../../core/widgets/atoms/custom_image.dart';
import '../../../core/widgets/atoms/unified_profile_avatar.dart';
import '../../../core/widgets/molecules/pro_max_card.dart';

enum StoreCardLayout { grid, list }

class UnifiedStoreCard extends StatelessWidget {
  final StoreModel store;
  final int index;
  final StoreCardLayout layout;

  const UnifiedStoreCard({
    super.key,
    required this.store,
    required this.index,
    this.layout = StoreCardLayout.grid,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FadeInSlide(
      duration: Duration(milliseconds: 400 + (index * 50)),
      beginOffset: const Offset(0, 0.1),
      child: GestureDetector(
        onTap: () => context.push('/store_details', extra: store),
        child: layout == StoreCardLayout.grid
            ? _buildGridCard(context, isDark)
            : _buildListCard(context, isDark),
      ),
    );
  }

  Widget _buildGridCard(BuildContext context, bool isDark) {
    return ProMaxCard(
      padding: EdgeInsets.zero,
      borderRadius: 24,
      child: Column(
        children: [
          // Cover Image & Logo Section
          Expanded(
            flex: 5,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Cover
                Positioned.fill(
                  child: Hero(
                    tag: 'store_cover_${store.id}',
                    child: Container(
                      color: isDark ? Colors.white10 : Colors.green.withValues(alpha: 0.05),
                      child: CustomImage(
                        imageUrl: store.coverImage,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                // Gradient Overlay for better contrast
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.2),
                        ],
                      ),
                    ),
                  ),
                ),
                // Category Tag (Top Right)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      store.category,
                      style: context.font10.bold.copyWith(color: Colors.white),
                    ),
                  ),
                ),
                // Logo (Overlapping Circle)
                Positioned(
                  bottom: -25,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: UnifiedProfileAvatar(
                      imageUrl: store.logo,
                      radius: 27,
                      borderWidth: 3,
                      borderColor: isDark ? Colors.white10 : Colors.white,
                      hasShadow: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Details Section
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 30, 12, 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          store.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: context.font16.bold.copyWith(
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                      if (store.status == 'verified') ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.verified, color: Colors.green, size: 16),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 14, color: AppColors.primary.withValues(alpha: 0.7)),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          store.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.font12.medium.copyWith(
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Bottom Stats Row
                  Row(
                    children: [
                      // Products Count (Left)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${store.productsCount} منتج',
                          style: context.font12.bold.copyWith(color: AppColors.primary),
                        ),
                      ),
                      const Spacer(),
                      // Rating (Right)
                      Row(
                        children: [
                          Text(
                            '(${store.reviewsCount})',
                            style: context.font10.medium.copyWith(
                              color: isDark ? Colors.white54 : Colors.black45,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            store.rating.toStringAsFixed(1),
                            style: context.font12.bold,
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.star_rounded, size: 18, color: Colors.amber),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListCard(BuildContext context, bool isDark) {
    // Basic list layout for stores if needed in search results or similar
    return ProMaxCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          UnifiedProfileAvatar(
            imageUrl: store.logo,
            radius: 40, // 80x80 total size previously
            borderWidth: 1,
            borderColor: AppColors.border(isDark),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        store.name,
                        style: context.font16.bold,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (store.status == 'verified') ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.verified, color: Colors.green, size: 16),
                    ],
                  ],
                ),
                Text(
                  store.location,
                  style: context.font12.medium.copyWith(color: context.textSecondary),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      store.rating.toStringAsFixed(1),
                      style: context.font12.bold,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${store.productsCount} منتج',
                      style: context.font12.bold.copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.primary),
        ],
      ),
    );
  }
}
