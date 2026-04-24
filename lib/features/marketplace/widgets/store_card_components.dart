import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/models/store_model.dart';
import '../../../core/widgets/atoms/custom_image.dart';
import '../../../core/widgets/atoms/rating_badge.dart' as core;

class StoreCoverSection extends StatelessWidget {
  final StoreModel store;
  final double height;
  final double scale;
  final bool isDark;

  const StoreCoverSection({
    super.key,
    required this.store,
    required this.height,
    required this.scale,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          RepaintBoundary(
            child: store.coverImage.isNotEmpty
                ? CustomImage(imageUrl: store.coverImage, fit: BoxFit.cover)
                : Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [
                          AppColors.primary.withValues(alpha: 0.8),
                          AppColors.secondary.withValues(alpha: 0.9),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.storefront_rounded,
                        size: height * 0.42,
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.4, 1.0],
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: isDark ? 0.85 : 0.60),
                  ],
                ),
              ),
            ),
          ),
          PositionedDirectional(
            top: 10 * scale,
            end: 10 * scale,
            child: core.RatingBadge(rating: store.rating, scale: scale),
          ),
          if (store.reviewsCount > 0 && height > 110)
            PositionedDirectional(
              top: 10 * scale,
              start: 10 * scale,
              child: _buildReviewsBadge(store, scale, isDark),
            ),
          PositionedDirectional(
            bottom: 10 * scale,
            end: 12 * scale,
            child: _buildCategoryTag(store, scale),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsBadge(StoreModel store, double scale, bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9 * scale, vertical: 5 * scale),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.messenger_outline_rounded,
            color: AppColors.getTextColor(isDark),
            size: 11 * scale,
          ),
          const SizedBox(width: 4),
          Text(
            '${store.reviewsCount}',
            style: TextStyle(
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 11 * scale,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTag(StoreModel store, double scale) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10 * scale,
        vertical: 4 * scale,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(10 * scale),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 12 * scale,
            offset: Offset(0, 4 * scale),
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Text(
        store.category,
        style: TextStyle(
          color: Colors.white,
          fontSize: (10.5 * scale).clamp(9.5, 12.0),
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
          fontFamily: 'Cairo',
        ),
      ),
    );
  }
}

class StoreInfoSection extends StatelessWidget {
  final StoreModel store;
  final bool isDark;
  final double topPadding;
  final double scale;
  final double horizontalPadding;
  final double verticalPadding;

  const StoreInfoSection({
    super.key,
    required this.store,
    required this.isDark,
    required this.topPadding,
    required this.scale,
    required this.horizontalPadding,
    required this.verticalPadding,
  });

  @override
  Widget build(BuildContext context) {
    final hintColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.textSecondary;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : AppColors.primary.withValues(alpha: 0.1),
            width: 1.5,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          topPadding + (6.0 * scale),
          horizontalPadding,
          verticalPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    store.name,
                    style: TextStyle(
                      fontSize: (16.0 * scale).clamp(14.0, 18.0),
                      fontWeight: FontWeight.w900,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                      letterSpacing: -0.5,
                      height: 1.1,
                      fontFamily: 'Cairo',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 11 * scale,
                        color: AppColors.primary.withValues(alpha: 0.8),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          store.location.isNotEmpty
                              ? store.location
                              : 'غير محدد',
                          style: TextStyle(
                            fontSize: (10.5 * scale).clamp(9.5, 12.0),
                            color: hintColor,
                            height: 1.2,
                            fontFamily: 'Cairo',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildProductCount(scale, isDark),
                  _buildActionArrow(scale),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCount(double scale, bool isDark) {
    return Flexible(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 10 * scale,
          vertical: 5 * scale,
        ),
        margin: EdgeInsetsDirectional.only(end: 8 * scale),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.1),
          borderRadius: BorderRadius.circular(10 * scale),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.22),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 11 * scale,
              color: AppColors.primary,
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                '${store.products.length} منتج',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: (10.5 * scale).clamp(9.5, 12.0),
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Cairo',
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionArrow(double scale) {
    return Container(
      width: 32 * scale,
      height: 32 * scale,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(10 * scale),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.45),
            blurRadius: 10 * scale,
            offset: Offset(0, 4 * scale),
          ),
        ],
      ),
      child: Icon(
        Icons.arrow_back_ios_new_rounded,
        color: Colors.white,
        size: 14 * scale,
        textDirection: TextDirection.ltr,
      ),
    );
  }
}
