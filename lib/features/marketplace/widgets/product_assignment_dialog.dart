import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/catalog_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_fonts.dart';
import '../../../core/widgets/atoms/custom_image.dart';
import '../providers/seller_provider.dart';

class ProductAssignmentDialog extends StatefulWidget {
  final CatalogModel catalog;

  const ProductAssignmentDialog({super.key, required this.catalog});

  static Future<void> show(BuildContext context, {required CatalogModel catalog}) {
    return showDialog(
      context: context,
      builder: (context) => ProductAssignmentDialog(catalog: catalog),
    );
  }

  @override
  State<ProductAssignmentDialog> createState() =>
      _ProductAssignmentDialogState();
}

class _ProductAssignmentDialogState extends State<ProductAssignmentDialog> {
  late List<String> selectedProductIds;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final provider = context.read<SellerProvider>();
    final allProducts = provider.myProducts;
    selectedProductIds = allProducts
        .where((p) => p.catalogId == widget.catalog.id)
        .map((p) => p.id)
        .toList();
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    context.pop();

    final provider = context.read<SellerProvider>();
    final success = await provider.assignProductsToCatalog(
      widget.catalog.id,
      selectedProductIds,
    );

    if (mounted) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'تم تحديث المنتجات بنجاح'
                : 'حدث خطأ في تحديث المنتجات',
          ),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  void _toggleProduct(String productId, bool? value) {
    HapticFeedback.selectionClick();
    setState(() {
      if (value == true) {
        selectedProductIds.add(productId);
      } else {
        selectedProductIds.remove(productId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<SellerProvider>();
    final allProducts = provider.myProducts;

    return Dialog(
      backgroundColor: context.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
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
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'إضافة منتجات',
                        style: context.font18.bold.copyWith(
                          color: context.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.catalog.name,
                        style: context.font12.bold.copyWith(
                          color: context.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: context.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${selectedProductIds.length} محدد',
                    style: context.font12.bold.copyWith(
                      color: context.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: context.surface,
                borderRadius: BorderRadius.circular(2),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: selectedProductIds.length,
                    child: Container(
                      decoration: BoxDecoration(
                        color: context.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  if (allProducts.isNotEmpty)
                    Expanded(
                      flex: allProducts.length - selectedProductIds.length,
                      child: Container(),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: allProducts.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: allProducts.length,
                      separatorBuilder: (_, i) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final product = allProducts[index];
                        final isSelected = selectedProductIds.contains(product.id);
                        final isInOtherCatalog =
                            product.catalogId != null &&
                            product.catalogId != widget.catalog.id;

                        return _buildProductTile(context, product, isSelected, isInOtherCatalog);
                      },
                    ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: context.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'إلغاء',
                      style: context.font14.semiBold.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.save_rounded, size: 18),
                              const SizedBox(width: 8),
                              const Text(
                                'حفظ التغييرات',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: context.warning.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              color: context.warning,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'لا يوجد لديك منتجات حالياً',
            style: context.font16.bold.copyWith(
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'أضف منتجاتك أولاً من شاشة إضافة منتج',
            style: context.font12.medium.copyWith(
              color: context.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProductTile(BuildContext context, dynamic product, bool isSelected, bool isInOtherCatalog) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isSelected
            ? context.primary.withValues(alpha: 0.08)
            : context.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected
              ? context.primary.withValues(alpha: 0.5)
              : context.border,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isInOtherCatalog ? null : () => _toggleProduct(product.id, !isSelected),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 48,
                    height: 48,
                    color: context.primary.withValues(alpha: 0.1),
                    child: product.images.isNotEmpty
                        ? CustomImage(
                            imageUrl: product.images.first,
                            fit: BoxFit.cover,
                          )
                        : Icon(
                            Icons.image_outlined,
                            color: context.primary,
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.title,
                        style: context.font14.bold.copyWith(
                          color: context.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '${product.price} ريال',
                            style: context.font12.bold.copyWith(
                              color: context.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '/ ${product.unit}',
                            style: context.font10.medium.copyWith(
                              color: context.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isInOtherCatalog)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: context.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.warning_amber_rounded, color: context.warning, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          'في كتالوج آخر',
                          style: context.font10.bold.copyWith(
                            color: context.warning,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isSelected ? context.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? context.primary : context.border,
                        width: 1.5,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
