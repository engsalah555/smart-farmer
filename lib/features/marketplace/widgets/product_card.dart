import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants.dart';
import '../../../core/models/product_model.dart';
import '../../../core/widgets/atoms/custom_image.dart';
import '../../../core/widgets/molecules/pro_max_card.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final bool isFeatured;

  const ProductCard({
    super.key,
    required this.product,
    this.isFeatured = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    if (isFeatured) {
      return _buildFeaturedCard(context, isDark, textPrimary, textSecondary);
    }

    return ProMaxCard(
      onTap: () => context.push('/product_details', extra: product),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 5,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  child: Hero(
                    tag: 'product_store_${product.id}',
                    child: _buildProductImage(product),
                  ),
                ),
                Positioned.fill(
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
                ),
                PositionedDirectional(
                  top: 10,
                  end: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.neutralWhite.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      product.category,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    product.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.add_shopping_cart_rounded,
                          color: AppColors.neutralWhite,
                          size: 16,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${product.price} ريال',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            product.unit,
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
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
        ],
      ),
    );
  }

  Widget _buildFeaturedCard(
    BuildContext context,
    bool isDark,
    Color textPrimary,
    Color textSecondary,
  ) {
    return ProMaxCard(
      onTap: () => context.push('/product_details', extra: product),
      padding: EdgeInsets.zero,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  child: Hero(
                    tag: 'product_store_${product.id}',
                    child: _buildProductImage(product),
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        stops: const [0.6, 1.0],
                        colors: [
                          Colors.transparent,
                          AppColors.neutralBlack.withValues(alpha: isDark ? 0.5 : 0.25),
                        ],
                      ),
                    ),
                  ),
                ),
                PositionedDirectional(
                  top: 8,
                  start: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'مميز',
                      style: TextStyle(
                        color: AppColors.neutralWhite,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    product.category,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    product.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${product.price} ريال',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    product.unit,
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.add_shopping_cart_rounded,
                      color: AppColors.neutralWhite,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(ProductModel product) {
    if (product.images.isEmpty) {
      return Icon(
        Icons.image_not_supported,
        color: AppColors.primary,
        size: 32,
      );
    }
    return CustomImage(imageUrl: product.images.first, fit: BoxFit.cover);
  }
}