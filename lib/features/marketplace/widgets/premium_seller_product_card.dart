import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants.dart';
import '../../../core/models/product_model.dart';
import '../../../core/widgets/atoms/custom_image.dart';
import '../../../core/widgets/app_fonts.dart';
import '../../../core/widgets/molecules/pro_max_card.dart';

class PremiumSellerProductCard extends StatelessWidget {
  final ProductModel product;
  final bool isGrid;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PremiumSellerProductCard({
    super.key,
    required this.product,
    this.isGrid = true,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return isGrid ? _buildGridCard(context) : _buildListCard(context);
  }

  Widget _buildGridCard(BuildContext context) {
    final isDark = context.isDark;
    final stockStatus = _getStockStatus();

    return ProMaxCard(
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 5,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    product.images.isNotEmpty
                        ? CustomImage(
                            imageUrl: product.images.first,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: context.primary.withValues(alpha: 0.1),
                            child: Icon(
                              Icons.image_outlined,
                              color: context.primary,
                              size: 40,
                            ),
                          ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: const [0.6, 1.0],
                            colors: [
                              Colors.transparent,
                              (isDark
                                      ? AppColors.darkBackground
                                      : AppColors.neutralBlack)
                                  .withValues(alpha: isDark ? 0.8 : 0.4),
                            ],
                          ),
                        ),
                      ),
                    ),
                    PositionedDirectional(
                      top: 8,
                      start: 8,
                      child: _buildBadge(
                        context,
                        '${product.price}ريال',
                        context.primary,
                      ),
                    ),
                    if (stockStatus != null)
                      PositionedDirectional(
                        top: 8,
                        end: 8,
                        child: _buildBadge(
                          context,
                          stockStatus.label,
                          stockStatus.color,
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.title,
                        style: context.font14.bold.copyWith(
                          color: context.textPrimary,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        product.unit,
                        style: context.font10.medium.copyWith(
                          color: context.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      Row(
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
                              _buildActionCircle(
                                Icons.edit_outlined,
                                context.info,
                                onEdit,
                                size: 28,
                              ),
                              const SizedBox(width: 4),
                              _buildActionCircle(
                                Icons.delete_outline,
                                context.error,
                                onDelete,
                                size: 28,
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
        ],
      ),
    );
  }

  Widget _buildListCard(BuildContext context) {
    final stockStatus = _getStockStatus();

    return ProMaxCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 90,
              height: 90,
              color: context.primary.withValues(alpha: 0.1),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  product.images.isNotEmpty
                      ? CustomImage(
                          imageUrl: product.images.first,
                          fit: BoxFit.cover,
                        )
                      : Icon(
                          Icons.image_outlined,
                          color: context.primary,
                          size: 32,
                        ),
                  if (stockStatus != null)
                    Positioned(
                      bottom: 6,
                      right: 6,
                      child: _buildBadge(
                        context,
                        stockStatus.label,
                        stockStatus.color,
                        fontSize: 9,
                      ),
                    ),
                ],
              ),
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
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      '${product.price}',
                      style: context.font18.bold.copyWith(
                        color: context.isDark
                            ? context.darkAccent
                            : context.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'ريال',
                      style: context.font12.bold.copyWith(
                        color:
                            (context.isDark
                                    ? context.darkAccent
                                    : context.primary)
                                .withValues(alpha: 0.7),
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
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: context.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 12,
                            color: context.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${product.quantity} ${product.unit}',
                            style: context.font10.bold.copyWith(
                              color: context.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (stockStatus != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: stockStatus.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          stockStatus.label,
                          style: context.font10.bold.copyWith(
                            color: stockStatus.color,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildActionCircle(
                Icons.edit_outlined,
                context.info,
                onEdit,
                size: 36,
              ),
              const SizedBox(height: 8),
              _buildActionCircle(
                Icons.delete_outline,
                context.error,
                onDelete,
                size: 36,
              ),
            ],
          ),
        ],
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

  Widget _buildBadge(
    BuildContext context,
    String text,
    Color color, {
    double fontSize = 10,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: context.font10.bold.copyWith(color: Colors.white),
      ),
    );
  }

  Widget _buildActionCircle(
    IconData icon,
    Color color,
    VoidCallback onTap, {
    double size = 32,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: EdgeInsets.all((size - 20) / 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: size * 0.5),
      ),
    );
  }
}

class _StockStatus {
  final String label;
  final Color color;
  _StockStatus(this.label, this.color);
}
