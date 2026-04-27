import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_fonts.dart';
import '../../../core/models/catalog_model.dart';
import '../../../core/widgets/atoms/custom_image.dart';
import '../../../core/widgets/molecules/pro_max_card.dart';

class UnifiedCatalogCard extends StatelessWidget {
  final CatalogModel catalog;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onAddProducts;
  final VoidCallback? onTap;

  const UnifiedCatalogCard({
    super.key,
    required this.catalog,
    this.onEdit,
    this.onDelete,
    this.onAddProducts,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ProMaxCard(
      onTap: onTap ?? onAddProducts,
      padding: EdgeInsets.zero,
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image Section
          Expanded(
            flex: 3,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _buildImage(context),
                _buildGradientOverlay(isDark),
                
                // Product Count Badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.inventory_2_outlined, color: Colors.white, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          '${catalog.productsCount} منتج',
                          style: context.font10.bold.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),

                // Edit/Delete Menu (Top Left)
                Positioned(
                  top: 8,
                  left: 8,
                  child: _buildActionMenu(context),
                ),
              ],
            ),
          ),

          // Content Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  catalog.name,
                  style: context.font16.bold.copyWith(
                    color: context.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  catalog.description.isNotEmpty 
                      ? catalog.description 
                      : 'لا يوجد وصف لهذا الكتالوج',
                  style: context.font12.medium.copyWith(
                    color: context.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                
                // Add Products Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      onAddProducts?.call();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.primary.withValues(alpha: 0.1),
                      foregroundColor: context.primary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_rounded, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'إدارة المنتجات',
                          style: context.font12.bold,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.primary.withValues(alpha: 0.05),
      ),
      child: catalog.imageUrl != null
          ? CustomImage(
              imageUrl: catalog.imageUrl!,
              fit: BoxFit.cover,
            )
          : Center(
              child: Icon(
                Icons.collections_bookmark_outlined,
                size: 48,
                color: context.primary.withValues(alpha: 0.2),
              ),
            ),
    );
  }

  Widget _buildGradientOverlay(bool isDark) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.2),
              Colors.transparent,
              Colors.transparent,
              isDark 
                ? Colors.black.withValues(alpha: 0.1) 
                : Colors.white.withValues(alpha: 0.1),
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildActionMenu(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: PopupMenuButton<String>(
        icon: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
              ),
            ],
          ),
          child: const Icon(Icons.more_vert, size: 18, color: Colors.black87),
        ),
        onSelected: (value) {
          if (value == 'edit') {
            onEdit?.call();
          } else if (value == 'delete') {
            onDelete?.call();
          }
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit_outlined, size: 18, color: context.primary),
                const SizedBox(width: 8),
                const Text('تعديل'),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                const SizedBox(width: 8),
                Text('حذف', style: TextStyle(color: AppColors.error)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
