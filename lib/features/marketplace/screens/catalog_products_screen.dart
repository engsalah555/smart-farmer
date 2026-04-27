import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants.dart';
import '../../../core/models/catalog_model.dart';
import '../../../core/models/product_model.dart';
import '../../../core/widgets/fade_in_slide.dart';
import '../../../core/widgets/atoms/custom_image.dart';
import '../providers/marketplace_provider.dart';
import '../providers/seller_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/premium_seller_product_card.dart';

class CatalogProductsScreen extends StatefulWidget {
  final CatalogModel catalog;
  final bool isSeller;

  const CatalogProductsScreen({
    super.key,
    required this.catalog,
    this.isSeller = false,
  });

  @override
  State<CatalogProductsScreen> createState() => _CatalogProductsScreenState();
}

class _CatalogProductsScreenState extends State<CatalogProductsScreen> {
  @override
  Widget build(BuildContext context) {
    final products = widget.isSeller
        ? context.select<SellerProvider, List<ProductModel>>(
            (p) => p.myProducts
                .where((p) => p.catalogId == widget.catalog.id)
                .toList(),
          )
        : context.select<MarketplaceProvider, List<ProductModel>>(
            (p) =>
                (p.getStoreDetailsFromCache(widget.catalog.storeId)?.products ??
                        [])
                    .where((p) => p.catalogId == widget.catalog.id)
                    .toList(),
          );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            stretch: true,
            backgroundColor: context.primary,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.catalog.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black45, blurRadius: 10)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (widget.catalog.imageUrl != null)
                    CustomImage(
                      imageUrl: widget.catalog.imageUrl!,
                      fit: BoxFit.cover,
                    )
                  else
                    Container(
                      color: context.primary.withValues(alpha: 0.8),
                      child: const Icon(
                        Icons.category,
                        size: 80,
                        color: Colors.white24,
                      ),
                    ),
                  // Gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.8),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Description & Stats
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInSlide(
                    duration: const Duration(milliseconds: 400),
                    child: Text(
                      widget.catalog.description,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FadeInSlide(
                    duration: const Duration(milliseconds: 500),
                    child: Row(
                      children: [
                        _buildStatCard(
                          context,
                          'المنتجات',
                          products.length.toString(),
                          Icons.inventory_2_outlined,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Product Grid
          if (products.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'لا يوجد منتجات في هذا الكتالوج حالياً',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final product = products[index];
                  return FadeInSlide(
                    duration: Duration(milliseconds: 500 + (index * 100)),
                    child: widget.isSeller
                        ? PremiumSellerProductCard(
                            product: product,
                            isGrid: true,
                            onEdit: () =>
                                context.push('/add_product', extra: product),
                            onDelete: () =>
                                _showDeleteConfirmation(context, product),
                          )
                        : ProductCard(product: product),
                  );
                }, childCount: products.length),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: context.primary, size: 20),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(color: Colors.grey[700], fontSize: 14),
          ),
          Text(
            value,
            style: TextStyle(
              color: context.primary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
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
