import '../../../core/services/locator.dart';
import '../services/marketplace_service.dart';
import '../../../core/services/persistence_service.dart';
import '../../../core/models/product_model.dart';
import '../../../core/models/store_model.dart';
import '../../../core/models/order_model.dart' as order_model;
import '../../../core/providers/base_provider.dart';
import 'package:flutter/foundation.dart';

/// Focused on Public Marketplace Browsing & Buyer Actions
class MarketplaceProvider extends BaseProvider {
  final MarketplaceService _marketplaceService = locator<MarketplaceService>();
  final PersistenceService _persistence = locator<PersistenceService>();

  static const String _boxName = 'marketplace_cache';

  // --- State ---
  final List<ProductModel> _products = [];
  final List<StoreModel> _stores = [];
  final List<order_model.Order> _myOrders = [];
  final List<Map<String, dynamic>> _categories = [];
  
  // Cache for public store details
  final Map<String, StoreModel> _storeDetailsCache = {};
  final Map<String, List<ProductModel>> _storeProductsCache = {};
  final Map<String, int> _storeProductsCurrentPage = {};
  final Map<String, bool> _storeProductsHasNext = {};
  final Map<String, bool> _storeProductsLoading = {};

  // Pagination State - Products
  int _currentProductsPage = 1;
  bool _hasNextProductsPage = true;
  bool _isLoadingMoreProducts = false;

  // Pagination State - Stores
  int _currentStoresPage = 1;
  bool _hasNextStoresPage = true;
  bool _isLoadingMoreStores = false;

  // Pagination State - Orders
  int _currentOrdersPage = 1;
  bool _hasNextOrdersPage = true;
  bool _isLoadingMoreOrders = false;

  bool _isRefreshing = false;

  // --- Getters ---
  List<ProductModel> get products => List.unmodifiable(_products);
  List<StoreModel> get stores => List.unmodifiable(_stores);
  List<order_model.Order> get myOrders => List.unmodifiable(_myOrders);
  
  bool get isLoadingMoreProducts => _isLoadingMoreProducts;
  bool get hasNextProductsPage => _hasNextProductsPage;

  bool get isLoadingMoreStores => _isLoadingMoreStores;
  bool get hasNextStoresPage => _hasNextStoresPage;

  bool get isLoadingMoreOrders => _isLoadingMoreOrders;
  bool get hasNextOrdersPage => _hasNextOrdersPage;

  List<ProductModel> getStoreProductsList(String storeId) => _storeProductsCache[storeId] ?? [];
  bool isStoreProductsLoading(String storeId) => _storeProductsLoading[storeId] ?? false;
  bool hasNextStoreProductsPage(String storeId) => _storeProductsHasNext[storeId] ?? true;

  MarketplaceProvider() {
    // Delay init to avoid calling notifyListeners during widget tree build
    Future.microtask(_initFromCache);
  }

  Future<void> _initFromCache() async {
    try {
      final results = await Future.wait([
        _persistence.get(_boxName, 'products'),
        _persistence.get(_boxName, 'stores'),
        _persistence.get(_boxName, 'categories'),
      ]);

      bool hasData = false;
      final cachedProducts = results[0];
      final cachedStores = results[1];
      final cachedCats = results[2];

      if (cachedProducts is Iterable && cachedProducts.isNotEmpty) {
        _products.clear();
        _products.addAll(cachedProducts.map((e) => ProductModel.fromJson(Map<String, dynamic>.from(e as Map))));
        hasData = true;
      }
      if (cachedStores is Iterable && cachedStores.isNotEmpty) {
        _stores.clear();
        _stores.addAll(cachedStores.map((e) => StoreModel.fromJson(Map<String, dynamic>.from(e as Map))));
        hasData = true;
      }
      if (cachedCats is Iterable && cachedCats.isNotEmpty) {
        _categories.clear();
        _categories.addAll(cachedCats.map((e) => Map<String, dynamic>.from(e as Map)));
      }
      // Only notify once after all cache is loaded, and only if there's data worth showing
      if (hasData) notifyListeners();
    } catch (e) {
      debugPrint('Error initializing marketplace cache: $e');
    }
  }

  Future<void> refreshMarketplace() async {
    if (_isRefreshing) return;
    _isRefreshing = true;
    notifyListeners();
    try {
      // Run sequentially to avoid race conditions and excess rebuilds
      await loadMetadata();
      await loadStores();
      await loadProducts();
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  // --- Public Methods ---

  Future<void> loadProducts({bool loadMore = false}) async {
    if (loadMore) {
      if (!_hasNextProductsPage || _isLoadingMoreProducts) return;
      _isLoadingMoreProducts = true;
      notifyListeners();
    } else {
      _currentProductsPage = 1;
      _hasNextProductsPage = true;
    }

    // ✅ Fix: capture current page BEFORE async call to avoid race condition
    final nextPage = loadMore ? _currentProductsPage + 1 : 1;

    await execute(() async {
      final result = await _marketplaceService.getProducts(page: nextPage);
      
      if (!loadMore) {
        _products.clear();
        // Save first page to cache only — not all pages
        await _persistence.save(
          _boxName,
          'products',
          result.data.map((e) => e.toCacheJson()).toList(),
        );
      }
      _products.addAll(result.data);
      _currentProductsPage = result.currentPage;
      _hasNextProductsPage = result.hasNextPage;

      // Fallback: build store list from products if stores haven't loaded yet
      if (_stores.isEmpty && result.data.isNotEmpty) {
        for (var product in result.data) {
          if (!_stores.any((s) => s.id == product.storeId)) {
            _stores.add(_createFallbackStore(product));
          }
        }
      }
    });

    if (loadMore) {
      _isLoadingMoreProducts = false;
      notifyListeners();
    }
  }

  Future<void> loadStores({bool loadMore = false, double? latitude, double? longitude}) async {
    if (loadMore) {
      if (!_hasNextStoresPage || _isLoadingMoreStores) return;
      _isLoadingMoreStores = true;
      notifyListeners();
    } else {
      _currentStoresPage = 1;
      _hasNextStoresPage = true;
    }

    // ✅ Fix: capture page number before async gap
    final nextPage = loadMore ? _currentStoresPage + 1 : 1;

    await execute(() async {
      final result = await _marketplaceService.getStores(
        page: nextPage,
        latitude: latitude,
        longitude: longitude,
      );
      
      if (!loadMore) {
        _stores.clear();
        await _persistence.save(_boxName, 'stores', result.data.map((e) => e.toJson()).toList());
      }
      _stores.addAll(result.data);
      _currentStoresPage = result.currentPage;
      _hasNextStoresPage = result.hasNextPage;
    });

    if (loadMore) {
      _isLoadingMoreStores = false;
      notifyListeners();
    }
  }

  Future<void> loadMetadata() async {
    await execute(() async {
      final metadata = await _marketplaceService.getMetadata();
      if (metadata != null && metadata.containsKey('marketplace')) {
        final marketData = metadata['marketplace'] as Map<String, dynamic>;
        final List<dynamic> cats = marketData['categories'] ?? [];
        _categories.clear();
        final List<Map<String, dynamic>> mappedCats = cats.map((e) => {
          'id': e['id'],
          'label': e['label'],
          'icon': e['icon'],
        }).toList();
        _categories.addAll(mappedCats);
        await _persistence.save(_boxName, 'categories', mappedCats);
        notifyListeners();
      }
    });
  }

  Future<void> loadStoreProducts(String storeId, {bool loadMore = false, String? catalogId}) async {
    if (loadMore) {
      if (!hasNextStoreProductsPage(storeId) || isStoreProductsLoading(storeId)) return;
      _storeProductsLoading[storeId] = true;
      notifyListeners();
    } else {
      _storeProductsCurrentPage[storeId] = 1;
      _storeProductsHasNext[storeId] = true;
      _storeProductsCache[storeId] = [];
    }

    await execute(() async {
      final result = await _marketplaceService.getStoreProducts(
        storeId,
        catalogId: catalogId,
        page: loadMore ? (_storeProductsCurrentPage[storeId] ?? 1) + 1 : 1,
      );
      
      final currentList = _storeProductsCache[storeId] ?? [];
      currentList.addAll(result.data);
      _storeProductsCache[storeId] = currentList;
      _storeProductsCurrentPage[storeId] = result.currentPage;
      _storeProductsHasNext[storeId] = result.hasNextPage;
    });

    if (loadMore) {
      _storeProductsLoading[storeId] = false;
      notifyListeners();
    }
  }

  Future<void> loadStoreDetails(String storeId, {bool forceRefresh = false}) async {
    final cachedStore = _storeDetailsCache[storeId];
    if (!forceRefresh && cachedStore != null) return;

    await execute(() async {
      final store = await _marketplaceService.getStoreDetails(storeId);
      if (store != null) {
        _storeDetailsCache[storeId] = store;
        final index = _stores.indexWhere((s) => s.id == storeId);
        if (index != -1) _stores[index] = store;
      }
    });
  }

  Future<void> loadMyOrders({bool loadMore = false}) async {
    if (loadMore) {
      if (!_hasNextOrdersPage || _isLoadingMoreOrders) return;
      _isLoadingMoreOrders = true;
      notifyListeners();
    } else {
      _currentOrdersPage = 1;
      _hasNextOrdersPage = true;
    }

    await execute(() async {
      final result = await _marketplaceService.getOrders(
        page: loadMore ? _currentOrdersPage + 1 : 1,
      );
      
      if (!loadMore) {
        _myOrders.clear();
      }
      _myOrders.addAll(result.data);
      _currentOrdersPage = result.currentPage;
      _hasNextOrdersPage = result.hasNextPage;
    });

    if (loadMore) {
      _isLoadingMoreOrders = false;
      notifyListeners();
    }
  }

  Future<bool> submitReview(String productId, double rating, {String? comment}) async {
    final result = await execute(() async {
      final success = await _marketplaceService.submitReview(productId, rating: rating, comment: comment);
      if (success != null) {
        await loadProducts(); 
        return true;
      }
      return false;
    });
    return result ?? false;
  }

  Future<Map<String, dynamic>> getProductReviews(String productId) async {
    return await execute(() async {
      return await _marketplaceService.getProductReviews(productId);
    }) ?? {'reviews': [], 'avg_rating': 0.0, 'reviews_count': 0};
  }

  // --- Filtering & Search ---

  List<ProductModel> getProductsByCategory(String category) {
    if (category == 'الكل') return products;
    return _products.where((p) => p.category == category).toList();
  }

  List<ProductModel> searchProducts(String query) {
    if (query.trim().isEmpty) return products;
    final lowerQuery = query.toLowerCase();
    return _products.where((p) {
      return p.title.toLowerCase().contains(lowerQuery) ||
          p.description.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  List<Map<String, dynamic>> get dynamicCategories {
    final List<Map<String, dynamic>> result = [
      {'id': 'all', 'label': 'الكل', 'icon': 'apps'}
    ];
    
    // Set to track normalized labels to prevent duplicates
    final Set<String> seenLabels = {'الكل'};

    // Helper to normalize category labels (Robust Arabic Normalization)
    String normalize(String label) {
      String l = label.trim();
      
      // Basic Arabic Unification
      String unify(String s) {
        return s.replaceAll('أ', 'ا')
                .replaceAll('إ', 'ا')
                .replaceAll('آ', 'ا')
                .replaceAll('ة', 'ه')
                .replaceAll('ى', 'ي')
                .replaceAll('  ', ' '); // Remove double spaces
      }

      final unified = unify(l);
      
      // Mapping common variations to standard names using unified comparison
      if (unified.contains('محصول') || unified.contains('محاصيل') || unified.contains('منتجات زراعي')) {
        return 'منتجات زراعية';
      }
      if (unified.contains('معدات') || unified.contains('ادوات') || unified.contains('الات زراعي')) {
        return 'معدات وأدوات';
      }
      if (unified.contains('بذر') || unified.contains('تقاوي')) {
        return 'بذور زراعية';
      }
      if (unified.contains('مشتل') || unified.contains('نبات')) {
        return 'مشاتل';
      }
      if (unified.contains('سماد') || unified.contains('اسمده') || unified.contains('مخصب')) {
        return 'أسمدة';
      }
      if (unified.contains('مبيد') || unified.contains('حمايه')) {
        return 'مبيدات زراعية';
      }
      if (unified.contains('ري') || unified.contains('طاقه')) {
        return 'أنظمة ري وطاقة';
      }
      
      return l; // Return original if no match, but Set will handle uniqueness
    }

    // 1. Add categories from API (Metadata)
    for (var cat in _categories) {
      final label = normalize(cat['label'].toString());
      if (!seenLabels.contains(label)) {
        result.add({
          ...cat,
          'label': label,
        });
        seenLabels.add(label);
      }
    }

    // 2. Add fallback categories if API list is empty
    if (_categories.isEmpty) {
      final fallbacks = [
        {'id': 'seeds', 'label': 'بذور زراعية', 'icon': 'eco'},
        {'id': 'fertilizers', 'label': 'أسمدة', 'icon': 'opacity'},
        {'id': 'pesticides', 'label': 'مبيدات زراعية', 'icon': 'bug_report'},
        {'id': 'irrigation', 'label': 'أنظمة ري وطاقة', 'icon': 'solar_power'},
        {'id': 'tools', 'label': 'معدات وأدوات', 'icon': 'construction'},
        {'id': 'nurseries', 'label': 'مشاتل', 'icon': 'yard'},
        {'id': 'products', 'label': 'منتجات زراعية', 'icon': 'shopping_basket'},
      ];
      for (var fb in fallbacks) {
        final label = normalize(fb['label'].toString());
        if (!seenLabels.contains(label)) {
          result.add(fb);
          seenLabels.add(label);
        }
      }
    }

    // 3. Add dynamic categories from loaded stores
    for (var store in _stores) {
      if (store.category.isNotEmpty && store.category != 'شامل') {
        final label = normalize(store.category);
        if (!seenLabels.contains(label)) {
          result.add({'id': label, 'label': label, 'icon': 'store'});
          seenLabels.add(label);
        }
      }
    }

    return result;
  }

  StoreModel? getStoreDetailsFromCache(String storeId) => _storeDetailsCache[storeId];

  StoreModel _createFallbackStore(ProductModel product) {
    final cachedStore = _storeDetailsCache[product.storeId];
    return StoreModel(
      id: product.storeId,
      name: product.storeName,
      ownerId: product.sellerId,
      description: '',
      logo: product.storeLogo,
      coverImage: product.storeCoverImage,
      rating: 0.0,
      reviewsCount: 0,
      location: product.location,
      category: cachedStore?.category ?? 'شامل',
    );
  }

  void clearState() {
    _products.clear();
    _stores.clear();
    _myOrders.clear();
    _storeDetailsCache.clear();
    _storeProductsCache.clear();
    _storeProductsCurrentPage.clear();
    _storeProductsHasNext.clear();
    _storeProductsLoading.clear();
    _currentProductsPage = 1;
    _hasNextProductsPage = true;
    _isLoadingMoreProducts = false;
    _currentStoresPage = 1;
    _hasNextStoresPage = true;
    _isLoadingMoreStores = false;
    _currentOrdersPage = 1;
    _hasNextOrdersPage = true;
    _isLoadingMoreOrders = false;
    _isRefreshing = false;
    notifyListeners();
  }
}
