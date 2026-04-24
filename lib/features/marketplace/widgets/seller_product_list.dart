import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/widgets/fade_in_slide.dart';
import '../providers/seller_provider.dart';
import 'marketplace_empty_states.dart';
import '../screens/catalog_products_screen.dart';
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
            padding: const EdgeInsets.fromLTRB(20, 15, 20, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'الكتالوجات (التصنيفات)',
                  style: TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold,
                    color: AppColors.getTextColor(Theme.of(context).brightness == Brightness.dark),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (user.canAddProducts) {
                      context.push('/add_product');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'حسابك قيد المراجعة أو غير مصرح له بالبيع.',
                          ),
                        ),
                      );
                    }
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.add_circle_outline_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'إضافة منتج',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  ),
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
                height: 160,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: myCatalogs.length,
                  itemBuilder: (context, index) {
                    final catalog = myCatalogs[index];
                    return FadeInSlide(
                      delay: Duration(milliseconds: 50 * index),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CatalogProductsScreen(
                                catalog: catalog,
                                isSeller: true,
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(25),
                        child: Container(
                          width: 150,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(
                                  alpha: 0.15,
                                ),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(25),
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
                                              color: AppColors.getSurface(Theme.of(context).brightness == Brightness.dark).withValues(alpha: 0.5),
                                              child: Icon(
                                                Icons.category,
                                                size: 50,
                                                color: AppColors.primary.withValues(alpha: 0.4),
                                              ),
                                            ),
                                  )
                                else
                                  Container(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.1,
                                    ),
                                    child: const Icon(
                                      Icons.style,
                                      size: 50,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                // Gradient Overlay
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.black.withValues(alpha: 0.7),
                                        Colors.transparent,
                                      ],
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                    ),
                                  ),
                                ),
                                // Text
                                Positioned(
                                  bottom: 15,
                                  left: 10,
                                  right: 10,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        catalog.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (catalog.description.isNotEmpty)
                                        Text(
                                          catalog.description,
                                          style: TextStyle(
                                            color: Colors.white.withValues(
                                              alpha: 0.8,
                                            ),
                                            fontSize: 12,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: Text(
                'جميع المنتجات',
                style: TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextColor(Theme.of(context).brightness == Brightness.dark),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
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

  void _showDeleteConfirmation(
    BuildContext context,
    ProductModel product,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'تأكيد الحذف',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text('هل أنت متأكد من حذف المنتج "${product.title}"؟'),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: const Text('تراجع'),
          ),
          ElevatedButton(
            onPressed: () => context.pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('حذف الآن'),
          ),
        ],
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
            success ? 'تم الحذف بنجاح' : (provider.errorMessage ?? 'فشل الحذف'),
          ),
          backgroundColor: success ? Colors.green : Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
