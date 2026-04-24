import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants.dart';
import '../../../core/widgets/fade_in_slide.dart';
import '../../../core/models/store_model.dart';
import '../providers/marketplace_provider.dart';
import '../../../core/widgets/atoms/custom_image.dart';
import '../widgets/product_card.dart';

class StoreDetailsScreen extends StatefulWidget {
  final StoreModel store;

  const StoreDetailsScreen({super.key, required this.store});

  @override
  State<StoreDetailsScreen> createState() => _StoreDetailsScreenState();
}

class _StoreDetailsScreenState extends State<StoreDetailsScreen> {
  String? _selectedCatalogId;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<MarketplaceProvider>();
      provider.loadStoreDetails(widget.store.id);
      provider.loadStoreProducts(widget.store.id, catalogId: _selectedCatalogId);
    });
  }

  void _onCatalogSelected(String? catalogId) {
    if (_selectedCatalogId == catalogId) return;
    setState(() {
      _selectedCatalogId = catalogId;
    });
    context.read<MarketplaceProvider>().loadStoreProducts(
      widget.store.id, 
      catalogId: catalogId,
    );
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification is ScrollEndNotification &&
        notification.metrics.extentAfter < 500) {
      context.read<MarketplaceProvider>().loadStoreProducts(
        widget.store.id,
        loadMore: true,
        catalogId: _selectedCatalogId,
      );
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final marketplaceProvider = context.watch<MarketplaceProvider>();
    
    // Use cached store details if available
    final store =
        marketplaceProvider.getStoreDetailsFromCache(widget.store.id) ?? widget.store;
    
    final products = marketplaceProvider.getStoreProductsList(widget.store.id);
    final isLoadingMore = marketplaceProvider.isStoreProductsLoading(widget.store.id);
    final hasNext = marketplaceProvider.hasNextStoreProductsPage(widget.store.id);
    final catalogs = store.catalogs;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.getBackground(isDark),
      body: NotificationListener<ScrollNotification>(
        onNotification: _onScrollNotification,
        child: CustomScrollView(
          slivers: [
            // AppBar (Cover and Logo)
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              backgroundColor: AppColors.primary,
              elevation: 0,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              leading: _buildBackButton(context, isDark),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Cover Image
                    store.coverImage.isNotEmpty
                        ? CustomImage(
                            imageUrl: store.coverImage,
                            fit: BoxFit.cover,
                          )
                        : Container(color: AppColors.primary),
                    // Gradient Overlay
                    Container(
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
                    // Store Info
                    Positioned(
                      bottom: 20,
                      right: 20,
                      left: 20,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Store Logo
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: AppColors.getSurface(isDark),
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.border(isDark), width: 2),
                            ),
                            child: ClipOval(
                              child: store.logo.isNotEmpty
                                  ? CustomImage(
                                      imageUrl: store.logo,
                                      fit: BoxFit.cover,
                                      width: 70,
                                      height: 70,
                                    )
                                  : const Icon(
                                      Icons.store,
                                      size: 40,
                                      color: AppColors.primary,
                                    ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Store Name & Rating
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  store.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${store.rating} (${store.reviewsCount} تقييم)',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Icon(
                                      Icons.location_on,
                                      color: Colors.white70,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      store.location,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
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
      
            // Store Description
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'نبذة عن المتجر',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      store.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).hintColor,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'منتجات المتجر',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.titleLarge?.color,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
      
            // Premium Sticky Catalog Filter Bar
            if (catalogs.isNotEmpty)
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickyCatalogFilterDelegate(
                  SizedBox(
                    height: 75,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.getBackground(isDark),
                        boxShadow: [
                          BoxShadow(
                            color: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                _buildFilterChip(
                                  label: 'الكل',
                                  isSelected: _selectedCatalogId == null,
                                  isDark: isDark,
                                  onTap: () => _onCatalogSelected(null),
                                ),
                                ...catalogs.map(
                                  (cat) => _buildFilterChip(
                                    label: cat.name,
                                    isSelected: _selectedCatalogId == cat.id,
                                    isDark: isDark,
                                    onTap: () => _onCatalogSelected(cat.id),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
      
            // Products Grid
            products.isEmpty && !isLoadingMore
                ? SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 64,
                              color: Theme.of(
                                context,
                              ).hintColor.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'لا توجد منتجات في هذا القسم حالياً',
                              style: TextStyle(
                                color: Theme.of(context).hintColor,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 220,
                            childAspectRatio:
                                0.7, // Slightly taller for premium cards
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return FadeInSlide(
                          delay: Duration(milliseconds: 30 * index),
                          duration: const Duration(milliseconds: 400),
                          child: ProductCard(product: products[index]),
                        );
                      }, childCount: products.length),
                    ),
                  ),
      
            // Loading Indicator at bottom
            if (isLoadingMore)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
      
            if (!hasNext && products.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      'نهاية القائمة',
                      style: TextStyle(color: Theme.of(context).hintColor),
                    ),
                  ),
                ),
              ),
      
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : AppColors.glass(isDark),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.border(isDark),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.getTextColor(isDark),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context, bool isDark) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.glass(isDark),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }
}

/// Delegate for sticky catalog header
class _StickyCatalogFilterDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _StickyCatalogFilterDelegate(this.child);

  @override
  Widget build(context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 75; // Approximately the height of the container
  @override
  double get minExtent => 75;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}
