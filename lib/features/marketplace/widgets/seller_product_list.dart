import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farm2/core/widgets/app_fonts.dart';
import '../../../core/constants.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/widgets/fade_in_slide.dart';
import '../providers/seller_provider.dart';
import 'marketplace_empty_states.dart';
import '../../../core/models/product_model.dart';
import 'premium_seller_product_card.dart';

class SellerProductList extends StatelessWidget {
  final SellerProvider provider;

  const SellerProductList({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null || !user.isSeller) return const NoStoreSliver();

    final myProducts = provider.myProducts;
    final myCatalogs = provider.myCatalogs;

    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مجموعات المنتجات',
                      style: context.font20.bold.copyWith(
                        color: context.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'نظم منتجاتك في كتالوجات احترافية',
                      style: context.font12.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                _buildModernAddButton(
                  context,
                  label: 'منتج جديد',
                  icon: Icons.add_rounded,
                  onTap: () {
                    if (user.canAddProducts) {
                      context.push('/add_product');
                    } else {
                      _showRestrictionSnackBar(context);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        if (provider.isLoading)
          const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          )
        else if (myProducts.isEmpty && myCatalogs.isEmpty)
          const NoProductsSliver()
        else ...[
          if (myCatalogs.isNotEmpty)
            SliverToBoxAdapter(
              child: SizedBox(
                height: 180,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: myCatalogs.length,
                  itemBuilder: (context, index) {
                    final catalog = myCatalogs[index];
                    return FadeInSlide(
                      delay: Duration(milliseconds: 50 * index),
                      child: Padding(
                        padding: const EdgeInsetsDirectional.only(end: 16),
                        child: InkWell(
                          onTap: () {
                            context.push(
                              '/catalog_products',
                              extra: {'catalog': catalog, 'isSeller': true},
                            );
                          },
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            width: 140,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: context.primary.withValues(alpha: 0.1),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  if (catalog.imageUrl != null &&
                                      catalog.imageUrl!.isNotEmpty)
                                    Image.network(
                                      catalog.imageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                                color: context.primary
                                                    .withValues(alpha: 0.05),
                                                child: Icon(
                                                  Icons.category_outlined,
                                                  color: context.primary,
                                                  size: 40,
                                                ),
                                              ),
                                    )
                                  else
                                    Container(
                                      color: context.primary.withValues(
                                        alpha: 0.05,
                                      ),
                                      child: Icon(
                                        Icons.style_outlined,
                                        color: context.primary,
                                        size: 40,
                                      ),
                                    ),
                                  // Premium Gradient Overlay
                                  Positioned.fill(
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          stops: const [0.4, 1.0],
                                          colors: [
                                            Colors.transparent,
                                            Colors.black.withValues(
                                              alpha: 0.85,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Text Content
                                  Positioned(
                                    bottom: 12,
                                    left: 12,
                                    right: 12,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          catalog.name,
                                          style: context.font14.bold.copyWith(
                                            color: Colors.white,
                                            height: 1.1,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (catalog.description.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            catalog.description,
                                            style: context.font10.medium
                                                .copyWith(
                                                  color: Colors.white
                                                      .withValues(alpha: 0.7),
                                                ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Text(
                    'قائمة المنتجات',
                    style: context.font20.bold.copyWith(
                      color: context.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: context.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${myProducts.length}',
                      style: context.font12.bold.copyWith(
                        color: context.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final product = myProducts[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: FadeInSlide(
                    delay: Duration(milliseconds: 50 * index),
                    child: PremiumSellerProductCard(
                      product: product,
                      isGrid: false,
                      onEdit: () =>
                          context.push('/add_product', extra: product),
                      onDelete: () => _showDeleteConfirmation(context, product),
                    ),
                  ),
                );
              }, childCount: myProducts.length),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildModernAddButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: context.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: context.primary.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: context.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: context.font14.bold.copyWith(color: context.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRestrictionSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('حسابك قيد المراجعة أو غير مصرح له بالبيع حالياً.'),
        backgroundColor: context.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    ProductModel product,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: context.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.red,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'تأكيد الحذف',
                style: context.font20.bold.copyWith(color: context.textPrimary),
              ),
              const SizedBox(height: 12),
              Text(
                'هل أنت متأكد من حذف المنتج "${product.title}"؟ لا يمكن التراجع عن هذا الإجراء.',
                textAlign: TextAlign.center,
                style: context.font14.copyWith(color: context.textSecondary),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.pop(false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: context.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'تراجع',
                        style: context.font14.bold.copyWith(
                          color: context.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => context.pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('حذف الآن', style: context.font14.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirm == true) {
      if (!context.mounted) return;
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      final provider = context.read<SellerProvider>();
      final success = await provider.deleteProduct(product.id);
      if (!context.mounted) return;

      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'تم حذف المنتج بنجاح'
                : (provider.errorMessage ?? 'فشل في عملية الحذف'),
          ),
          backgroundColor: success ? AppColors.success : AppColors.error,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }
}
