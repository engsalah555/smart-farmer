import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/constants.dart';
import '../../../core/widgets/fade_in_slide.dart';
import '../providers/marketplace_provider.dart';
import '../providers/seller_provider.dart';
import '../widgets/marketplace_sliver_app_bar.dart';
import '../widgets/glassmorphic_search_bar.dart';
import '../widgets/marketplace_sticky_header.dart';
import '../widgets/marketplace_premium_filter_bar.dart';
import '../widgets/buyer_store_grid.dart';
import '../widgets/seller_product_list.dart';
import '../widgets/marketplace_shimmer_loader.dart'; // [New] Premium Loader

/// شاشة المتجر (Marketplace) - النسخة المحسنة هندسياً (Clean Code)
/// تم فصل منطق التحديث (State Management) عن مرحلة البناء (Build Phase)
/// لضمان استقرار واجهة المستخدم ومنع أي تعارضات في دورة حياة الويجت.
class MarketplaceScreen extends StatefulWidget {
  final Function(int)? onBack;
  const MarketplaceScreen({super.key, this.onBack});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen>
    with TickerProviderStateMixin {
  bool isBuying = true;
  String _searchQuery = '';
  bool _isSearchVisible = false;

  // State Controllers
  TabController? _tabController;
  late ScrollController _scrollController;
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'trending';
  late MarketplaceProvider _marketplaceProvider;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _marketplaceProvider = context.read<MarketplaceProvider>();
    // Optimized: Scroll listener removed to prevent excess rebuilds
    // Standard SliverAppBar handles its own animations

    // [Clean Code] تهيئة مبدئية لتجنب الـ null في أول بناء
    _tabController = TabController(length: 1, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
      _setupProviderListener();
    });
  }

  void _setupProviderListener() {
    _marketplaceProvider.addListener(_onProviderUpdated);
    _syncTabControllerWithCategories(_marketplaceProvider.dynamicCategories.length);
  }

  void _onProviderUpdated() {
    if (!mounted) return;
    final provider = context.read<MarketplaceProvider>();
    _syncTabControllerWithCategories(provider.dynamicCategories.length);
  }

  void _initializeData() {
    final provider = context.read<MarketplaceProvider>();
    if (provider.stores.isEmpty || provider.products.isEmpty) {
      provider.refreshMarketplace();
    }
    
    final user = context.read<AuthProvider>().currentUser;
    if (user != null && user.isSeller) {
      context.read<SellerProvider>().loadSellerDashboardData();
    }
    
    if (user != null && !user.canSell && !isBuying) {
      setState(() => isBuying = true);
    }
  }

  /// [Clean Code] فصلنا منطق مزامنة الـ TabController ليكون مبنياً على الأحداث (Event-driven)
  /// وليس على مرحلة البناء (Build-driven) لتجنب Element.inflateWidget Crash.
  void _syncTabControllerWithCategories(int length) {
    if (length == 0) length = 1; // Fallback to prevent crash

    if (_tabController?.length != length) {
      final oldIndex = _tabController?.index ?? 0;
      final oldController = _tabController; // احتفظ بالقديم

      _tabController = TabController(
        length: length,
        vsync: this,
        initialIndex: oldIndex.clamp(0, length - 1),
      );

      _tabController!.addListener(() {
        if (_tabController!.indexIsChanging && mounted) setState(() {});
      });

      // [Clean Code] تأخير الحذف حتى يكتمل بناء الإطار الحالي
      // لمنع الأخطاء عندما تحاول عناصر الواجهة القديمة فك ارتباطها بمتحكم محذوف
      WidgetsBinding.instance.addPostFrameCallback((_) {
        oldController?.dispose();
      });

      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    // Remove listener using stored reference to avoid deactivated context crash
    _marketplaceProvider.removeListener(_onProviderUpdated);
    _tabController?.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: AppColors.getBackground(isDark),
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.getBackground(
          isDark,
        ), // [Fixed] Dynamic background
        body: RefreshIndicator(
          onRefresh: _onRefresh,
          child: NotificationListener<ScrollNotification>(
            onNotification: _handleScrollNotification,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildAppBar(),
                _buildStickyHeaderSliver(),
                _buildMainContentSliver(),
                _buildLoadingSliver(),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onRefresh() async {
    final marketplaceProvider = context.read<MarketplaceProvider>();
    final sellerProvider = context.read<SellerProvider>();
    
    await Future.wait([
      marketplaceProvider.refreshMarketplace(),
      sellerProvider.loadSellerDashboardData(),
    ]);
  }

  bool _handleScrollNotification(ScrollNotification scrollInfo) {
    if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
      final provider = context.read<MarketplaceProvider>();
      if (isBuying) {
        if (provider.hasNextStoresPage && !provider.isLoadingMoreStores) {
          provider.loadStores(loadMore: true);
        }
      } else {
        // Handle seller products if needed
      }
    }
    return false;
  }

  Widget _buildAppBar() {
    return MarketplaceSliverAppBar(
      onBack: widget.onBack,
      searchQuery: _searchQuery,
      onSearchChanged: (val) => setState(() => _searchQuery = val),
      isSearchVisible: _isSearchVisible,
      onToggleSearch: () {
        HapticFeedback.mediumImpact();
        setState(() => _isSearchVisible = !_isSearchVisible);
      },
      isBuying: isBuying,
      onToggleChanged: (val) {
        HapticFeedback.mediumImpact();
        // Reset search when toggling modes
        setState(() {
          isBuying = val;
          _searchQuery = '';
          _searchController.clear();
        });
      },
    );
  }


  Widget _buildStickyHeaderSliver() {
    final provider = context.watch<MarketplaceProvider>();
    final dynamicCategories = provider.dynamicCategories;
    if (_tabController == null ||
        _tabController!.length != dynamicCategories.length) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return MarketplaceStickyHeader(
      key: ValueKey('sticky_header_${dynamicCategories.length}_$_isSearchVisible'),
      isBuying: isBuying,
      tabController: _tabController!,
      categories: dynamicCategories,
      onCategoryTap: (index) => setState(() {}),
      searchWidget: _isSearchVisible 
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FadeInSlide(
                duration: const Duration(milliseconds: 300),
                beginOffset: const Offset(0, -0.1),
                child: GlassmorphicSearchBar(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ),
            ) 
          : null,
      filterWidget: isBuying 
          ? MarketplacePremiumFilterBar(
              selectedFilter: _selectedFilter,
              onFilterSelected: (val) => setState(() => _selectedFilter = val),
            )
          : null,
    );
  }

  Widget _buildMainContentSliver() {
    final provider = context.watch<MarketplaceProvider>();

    // [Aesthetics] عرض مؤشر التحميل الاحترافي في حالة البداية
    if (provider.stores.isEmpty &&
        provider.products.isEmpty &&
        !provider.isLoadingMoreProducts) {
      return const MarketplaceShimmerLoader(isGrid: true);
    }

    if (isBuying) {
      return BuyerStoreGrid(
        provider: provider,
        searchQuery: _searchQuery,
        selectedFilter: _selectedFilter,
        selectedCategoryIndex: _tabController?.index ?? 0,
        categories: provider.dynamicCategories,
      );
    }

    return SellerProductList(provider: context.watch<SellerProvider>());
  }

  Widget _buildLoadingSliver() {
    final provider = context.watch<MarketplaceProvider>();

    bool isLoadingMore = isBuying ? provider.isLoadingMoreStores : provider.isLoadingMoreProducts;

    if (!isLoadingMore) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return const SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
    );
  }
}
