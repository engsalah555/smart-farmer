import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/models/product_model.dart';
import '../../../core/widgets/atoms/custom_image.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return isGrid ? _buildGridCard(context, isDark) : _buildListCard(context, isDark);
  }

  Widget _buildGridCard(BuildContext context, bool isDark) {
    return ProMaxCard(
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Product Image
              Expanded(
                flex: 3,
                child: product.images.isNotEmpty
                    ? CustomImage(
                        imageUrl: product.images.first,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        child: const Icon(
                          Icons.image_outlined,
                          color: AppColors.primary,
                          size: 40,
                        ),
                      ),
              ),
              // Product Info
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '${product.price}',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            ' / ${product.unit}',
                            style: TextStyle(
                              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.inventory_outlined,
                                size: 12,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${product.quantity}',
                                style: TextStyle(
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              InkWell(
                                onTap: onEdit,
                                child: const Icon(
                                  Icons.edit_outlined,
                                  size: 16,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: onDelete,
                                child: const Icon(
                                  Icons.delete_outline,
                                  size: 16,
                                  color: Colors.red,
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
          if (product.quantity <= 5 && product.quantity > 0)
            Positioned(
              top: 5,
              right: 5,
              child: _buildBadge('مخزون منخفض', Colors.orange),
            ),
          if (product.quantity <= 0)
            Positioned(
              top: 5,
              right: 5,
              child: _buildBadge('نفذت الكمية', Colors.red),
            ),
        ],
      ),
    );
  }

  Widget _buildListCard(BuildContext context, bool isDark) {
    return ProMaxCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 80,
              height: 80,
              color: AppColors.primary.withValues(alpha: 0.1),
              child: product.images.isNotEmpty
                  ? CustomImage(
                      imageUrl: product.images.first,
                      fit: BoxFit.cover,
                    )
                  : const Icon(Icons.image_outlined, color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 16),
          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${product.price}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      ' / ${product.unit}',
                      style: TextStyle(
                        color: Theme.of(context).hintColor,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (product.quantity > 5)
                      _buildBadge('نشط', Colors.green, fontSize: 10)
                    else if (product.quantity > 0)
                      _buildBadge('مخزون منخفض', Colors.orange, fontSize: 10)
                    else
                      _buildBadge('نفذت الكمية', Colors.red, fontSize: 10),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 12,
                      color: Theme.of(context).hintColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${product.quantity}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Actions
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildActionCircle(Icons.edit_outlined, Colors.blue, onEdit),
              const SizedBox(height: 8),
              _buildActionCircle(Icons.delete_outline, Colors.red, onDelete),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color, {double fontSize = 8}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActionCircle(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}
