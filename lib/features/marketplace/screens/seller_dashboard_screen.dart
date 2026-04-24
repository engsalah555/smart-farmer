import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farm2/core/widgets/app_fonts.dart';
import 'package:smart_farm2/features/marketplace/widgets/catalog_chip.dart';
import 'catalog_products_screen.dart';
import '../../../core/constants.dart';
import '../../../core/widgets/atoms/custom_image.dart';
import '../../../core/widgets/fade_in_slide.dart';
import '../providers/marketplace_provider.dart';
import '../providers/seller_provider.dart';
import '../../../core/models/store_model.dart';
import '../../../core/models/product_model.dart';
import '../../../core/models/catalog_model.dart';
import '../widgets/premium_seller_product_card.dart';
import 'seller_orders_screen.dart';

class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({super.key});

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  String _selectedCatalogId = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<SellerProvider>().loadSellerDashboardData();
      }
    });
  }

  void _onCatalogSelected(String id) {
    setState(() {
      _selectedCatalogId = id;
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = context.select<SellerProvider, StoreModel?>((p) => p.myStore);
    final myCatalogsCount = context.select<SellerProvider, int>(
      (p) => p.myCatalogs.length,
    );
    final allMyProducts = context.select<SellerProvider, List<ProductModel>>(
      (p) => p.myProducts,
    );
    final catalogs = context.select<SellerProvider, List<CatalogModel>>(
      (p) => p.myCatalogs,
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Filter products locally
    final filteredProducts = _selectedCatalogId == 'all'
        ? allMyProducts
        : allMyProducts
              .where((p) => p.catalogId == _selectedCatalogId)
              .toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: RefreshIndicator(
          onRefresh: () async {
            final sellerProvider = context.read<SellerProvider>();
            final marketplaceProvider = context.read<MarketplaceProvider>();
            await Future.wait([
              sellerProvider.loadMyStore(),
              marketplaceProvider.loadProducts(),
              sellerProvider.loadMyCatalogs(),
              sellerProvider.loadStoreOrders(),
            ]);
          },
          child: CustomScrollView(
            slivers: [
              // --- Premium Header (SliverAppBar) ---
              SliverAppBar(
                expandedHeight: 240,
                pinned: true,
                stretch: true,
                backgroundColor: AppColors.primary,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () => context.pop(),
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.settings_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () => context.push('/store_settings'),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.collections_bookmark_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () => context.push('/catalog_manager'),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [
                    StretchMode.zoomBackground,
                    StretchMode.blurBackground,
                  ],
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Cover Image
                      store?.coverImage != null && store!.coverImage.isNotEmpty
                          ? CustomImage(
                              imageUrl: store.coverImage,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.primary,
                                    AppColors.secondary,
                                  ],
                                ),
                              ),
                            ),
                      // Gradient Overlay
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.7),
                            ],
                          ),
                        ),
                      ),
                      // Store Info Overlay
                      Positioned(
                        bottom: 20,
                        right: 20,
                        left: 20,
                        child: Row(
                          children: [
                            // Logo
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(13),
                                child:
                                    store?.logo != null &&
                                        store!.logo.isNotEmpty
                                    ? CustomImage(
                                        imageUrl: store.logo,
                                        fit: BoxFit.cover,
                                      )
                                    : const Icon(
                                        Icons.store,
                                        color: AppColors.primary,
                                        size: 40,
                                      ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            // Name & Verification
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        store?.name ?? 'متجري',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    store?.category ?? 'تاجر زراعي',
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.8,
                                      ),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // --- Dashboard Body ---
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Quick Stats Row (Glassmorphism Style)
                      Row(
                        children: [
                          Expanded(
                            child: _buildGlassStatCard(
                              context,
                              title: 'المنتجات',
                              value: '${allMyProducts.length}',
                              icon: Icons.inventory_2_outlined,
                              color: AppColors.primary,
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: _buildGlassStatCard(
                              context,
                              title: 'طلبات جديدة',
                              value:
                                  '${context.watch<SellerProvider>().pendingOrdersCount}',
                              icon: Icons.shopping_bag_outlined,
                              color: Colors.orange,
                              isDark: isDark,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const SellerOrdersScreen(
                                        initialStatus: 'pending',
                                      ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: _buildGlassStatCard(
                              context,
                              title: 'الكتالوجات',
                              value: '$myCatalogsCount',
                              icon: Icons.collections_bookmark_outlined,
                              color: Colors.purple,
                              isDark: isDark,
                              onTap: () => context.push('/catalog_manager'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: _buildActionButton(
                              context,
                              icon: Icons.local_shipping_outlined,
                              label: 'إدارة الطلبات',
                              onTap: () => context.push('/seller_orders'),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: _buildActionButton(
                              context,
                              icon: Icons.analytics_outlined,
                              label: 'التقارير',
                              onTap: () => context.push('/seller_reports'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 35),

                      // --- Horizontal Catalog Filter Bar ---
                      if (catalogs.isNotEmpty) ...[
                        Text(
                          'تصفية حسب الكتالوج',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 45,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              CatalogChip(
                                label: 'الكل',
                                isSelected: _selectedCatalogId == 'all',
                                onTap: () => _onCatalogSelected('all'),
                              ),
                              ...catalogs.map(
                                (catalog) => CatalogChip(
                                  label: catalog.name,
                                  isSelected: _selectedCatalogId == catalog.id,
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          CatalogProductsScreen(
                                            catalog: catalog,
                                            isSeller: true,
                                          ),
                                    ),
                                  ),
                                  imageUrl: catalog.imageUrl,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],

                      // Products Section Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'منتجات المتجر',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                              ),
                              Container(
                                height: 4,
                                width: 40,
                                margin: const EdgeInsets.only(top: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ],
                          ),
                          TextButton.icon(
                            onPressed: () => context.push('/add_product'),
                            icon: const Icon(
                              Icons.add_circle_outline,
                              size: 20,
                            ),
                            label: const Text('إضافة جديد'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              textStyle: context.font14.bold,
                            ),
                            
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      if (filteredProducts.isEmpty)
                        _buildEmptyState(context, isDark)
                      else
                        GridView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 15,
                                mainAxisSpacing: 15,
                                childAspectRatio: 0.85,
                              ),
                          itemCount: filteredProducts.length,
                          itemBuilder: (context, index) {
                            final product = filteredProducts[index];
                            return FadeInSlide(
                              delay: Duration(milliseconds: 50 * index),
                              child: PremiumSellerProductCard(
                                product: product,
                                isGrid: true,
                                onEdit: () => context.push(
                                  '/add_product',
                                  extra: product,
                                ),
                                onDelete: () =>
                                    _showDeleteConfirmation(context, product),
                              ),
                            );
                          },
                        ),

                      const SizedBox(height: 100), // Bottom padding
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'dashboard_add_btn',
          onPressed: () => context.push('/add_product'),
          backgroundColor: AppColors.primary,
          elevation: 4,
          icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
          label: const Text(
            'أضف منتجاً جديداً',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : color.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).hintColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.03)
              : Colors.grey.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  // Products Grid implemented with PremiumSellerProductCard

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

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 50.0),
        child: Column(
          children: [
            Opacity(
              opacity: 0.5,
              child: Icon(Icons.storefront, size: 80, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            const Text(
              'لا توجد منتجات حالياً',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'ابدأ بإضافة منتجاتك لجذب المشترين!',
              style: TextStyle(color: Theme.of(context).hintColor),
            ),
          ],
        ),
      ),
    );
  }
}
