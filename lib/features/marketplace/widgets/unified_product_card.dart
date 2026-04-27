import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants.dart';
import '../../../core/widgets/app_fonts.dart';
import '../../../core/models/product_model.dart';
import '../../../core/widgets/atoms/custom_image.dart';
import '../../../core/widgets/molecules/pro_max_card.dart';

enum ProductCardLayout { grid, list, featured }
enum ProductCardMode { buyer, seller }

class UnifiedProductCard extends StatelessWidget {
  final ProductModel product;
  final ProductCardLayout layout;
  final ProductCardMode mode;
  final bool showHero;
  final VoidCallback? onAddToCart;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const UnifiedProductCard({
    super.key,
    required this.product,
    this.layout = ProductCardLayout.grid,
    this.mode = ProductCardMode.buyer,
    this.showHero = true,
    this.onAddToCart,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    switch (layout) {
      case ProductCardLayout.featured:
        return _buildFeaturedCard(context);
      case ProductCardLayout.list:
        return _buildListCard(context);
      case ProductCardLayout.grid:
        return _buildGridCard(context);
    }
  }

  Widget _buildGridCard(BuildContext context) {
    final isDark = context.isDark;
    final stockStatus = _getStockStatus();

    return ProMaxCard(
      onTap: mode == ProductCardMode.buyer 
          ? () {
              HapticFeedback.selectionClick();
              context.push('/product_details', extra: product);
            }
          : null,
      padding: EdgeInsets.zero,
      borderRadius: 24,
      child: Column(
        children: [
          // Image Section
          Expanded(
            flex: 5,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _buildProductImage(useHero: showHero),
                _buildGradientOverlay(isDark),
                
                // Tag (Top Right) - Category for Buyer, Price for Seller
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      mode == ProductCardMode.buyer ? product.category : '${product.price} ريال',
                      style: context.font10.bold.copyWith(color: Colors.white),
                    ),
                  ),
                ),

                // Left Badge (Stock Status for Seller)
                if (mode == ProductCardMode.seller && stockStatus != null)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: stockStatus.color.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        stockStatus.label,
                        style: context.font10.bold.copyWith(color: Colors.white),
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
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: context.font14.bold.copyWith(
                      color: isDark ? Colors.white : Colors.black87,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (mode == ProductCardMode.seller) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.inventory_2_outlined, 
                            size: 12, color: context.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          '${product.quantity} ${product.unit}',
                          style: context.font12.medium.copyWith(color: context.textSecondary),
                        ),
                      ],
                    ),
                  ],
                  const Spacer(),
                  if (mode == ProductCardMode.buyer)
                    _buildBuyerPriceRow(context)
                  else
                    _buildSellerGridActions(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListCard(BuildContext context) {
    final stockStatus = _getStockStatus();

    return ProMaxCard(
      onTap: mode == ProductCardMode.buyer 
          ? () {
              HapticFeedback.selectionClick();
              context.push('/product_details', extra: product);
            }
          : null,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 90,
              height: 90,
              child: _buildProductImage(useHero: showHero),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  style: context.font16.bold.copyWith(
                    color: context.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (mode == ProductCardMode.buyer)
                  Row(
                    children: [
                      Text(
                        '${product.price} ريال',
                        style: context.font16.bold.copyWith(
                          color: context.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '/ ${product.unit}',
                        style: context.font12.copyWith(
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  )
                else
                  _buildInventoryBadge(context, stockStatus),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (mode == ProductCardMode.buyer)
            _buildActionCircle(
              Icons.add_shopping_cart_rounded, 
              context.primary, 
              onAddToCart ?? () {}, 
              size: 36, 
              isSolid: true
            )
          else
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildActionCircle(
                  Icons.edit_outlined, 
                  context.info, 
                  onEdit ?? () {}, 
                  size: 34, 
                  isCircle: true
                ),
                const SizedBox(height: 8),
                _buildActionCircle(
                  Icons.delete_outline, 
                  context.error, 
                  onDelete ?? () {}, 
                  size: 34, 
                  isCircle: true
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildFeaturedCard(BuildContext context) {
    return ProMaxCard(
      onTap: () {
        HapticFeedback.selectionClick();
        context.push('/product_details', extra: product);
      },
      padding: EdgeInsets.zero,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _buildProductImage(useHero: showHero),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        stops: const [0.6, 1.0],
                        colors: [
                          Colors.transparent,
                          AppColors.neutralBlack.withValues(alpha: context.isDark ? 0.5 : 0.25),
                        ],
                      ),
                    ),
                  ),
                ),
                PositionedDirectional(
                  top: 10,
                  start: 10,
                  child: _buildBadge(context, 'مميز', context.primary),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildBadge(
                    context, 
                    product.category, 
                    context.primary.withValues(alpha: 0.1), 
                    textColor: context.primary,
                    isSoft: true
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.title,
                    style: context.font16.bold.copyWith(
                      color: context.textPrimary,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${product.price}',
                            style: context.font18.bold.copyWith(
                              color: context.primary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            product.unit,
                            style: context.font12.medium.copyWith(
                              color: context.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      _buildActionCircle(
                        Icons.add_shopping_cart_rounded, 
                        context.primary, 
                        onAddToCart ?? () {}, 
                        size: 38, 
                        isSolid: true
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

  Widget _buildProductImage({bool useHero = true}) {
    final image = product.images.isNotEmpty
        ? CustomImage(imageUrl: product.images.first, fit: BoxFit.cover)
        : Container(
            color: AppColors.primary.withValues(alpha: 0.05),
            child: const Icon(
              Icons.image_not_supported_outlined,
              color: AppColors.primary,
              size: 32,
            ),
          );

    if (useHero) {
      return Hero(
        tag: 'product_image_${product.id}',
        child: image,
      );
    }
    return image;
  }

  Widget _buildGradientOverlay(bool isDark) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.7, 1.0],
            colors: [
              Colors.transparent,
              AppColors.neutralBlack.withValues(alpha: isDark ? 0.6 : 0.3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBuyerPriceRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${product.price}',
              style: context.font16.bold.copyWith(
                color: context.primary,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              '/ ${product.unit}',
              style: context.font10.medium.copyWith(
                color: context.textSecondary,
              ),
            ),
          ],
        ),
        _buildActionCircle(Icons.add_shopping_cart_rounded, context.primary, onAddToCart ?? () {}),
      ],
    );
  }

  Widget _buildSellerGridActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: context.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                size: 12,
                color: context.primary,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '${product.quantity}',
              style: context.font12.bold.copyWith(
                color: context.textPrimary,
              ),
            ),
          ],
        ),
        Row(
          children: [
            _buildActionCircle(Icons.edit_outlined, context.info, onEdit ?? () {}, size: 28, isCircle: true),
            const SizedBox(width: 4),
            _buildActionCircle(Icons.delete_outline, context.error, onDelete ?? () {}, size: 28, isCircle: true),
          ],
        ),
      ],
    );
  }

  Widget _buildInventoryBadge(BuildContext context, _StockStatus? stockStatus) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: context.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.inventory_2_outlined, size: 12, color: context.primary),
              const SizedBox(width: 4),
              Text(
                '${product.quantity} ${product.unit}',
                style: context.font10.bold.copyWith(color: context.primary),
              ),
            ],
          ),
        ),
        if (stockStatus != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: stockStatus.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              stockStatus.label,
              style: context.font10.bold.copyWith(color: stockStatus.color),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBadge(
    BuildContext context, 
    String text, 
    Color color, 
    {Color textColor = Colors.white, bool isSoft = false, double fontSize = 10}
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isSoft ? color : color.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(isSoft ? 4 : 6),
        boxShadow: isSoft ? null : [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: textColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildActionCircle(
    IconData icon, 
    Color color, 
    VoidCallback onTap, 
    {double size = 34, bool isSolid = false, bool isCircle = false}
  ) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isSolid ? color : color.withValues(alpha: 0.1),
          shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: isCircle ? null : BorderRadius.circular(10),
          border: isSolid ? null : Border.all(color: color.withValues(alpha: 0.2), width: 1),
          boxShadow: isSolid ? [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ] : null,
        ),
        child: Icon(
          icon, 
          color: isSolid ? Colors.white : color, 
          size: size * 0.53
        ),
      ),
    );
  }

  _StockStatus? _getStockStatus() {
    if (product.quantity <= 0) {
      return _StockStatus('نفذت', AppColors.error);
    } else if (product.quantity <= 5) {
      return _StockStatus('مخزون منخفض', AppColors.warning);
    }
    return null;
  }
}

class _StockStatus {
  final String label;
  final Color color;
  _StockStatus(this.label, this.color);
}
