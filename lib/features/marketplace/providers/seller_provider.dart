import '../../../core/services/locator.dart';
import '../services/seller_service.dart';
import '../../../core/models/product_model.dart';
import '../../../core/models/store_model.dart';
import '../../../core/models/catalog_model.dart';
import '../../../core/providers/base_provider.dart';

class SellerProvider extends BaseProvider {
  final SellerService _sellerService = locator<SellerService>();

  // --- State ---
  StoreModel? _myStore;
  final List<ProductModel> _myProducts = [];
  final List<CatalogModel> _myCatalogs = [];
  final List<Map<String, dynamic>> _storeOrders = [];
  final Set<String> _pendingDeleteIds = {};

  // --- Getters ---
  StoreModel? get myStore => _myStore;
  List<ProductModel> get myProducts => List.unmodifiable(_myProducts);
  List<CatalogModel> get myCatalogs => List.unmodifiable(_myCatalogs);
  List<Map<String, dynamic>> get storeOrders => List.unmodifiable(_storeOrders);
  int get pendingOrdersCount => _storeOrders.where((o) => o['status'] == 'pending').length;

  // --- Actions ---

  bool _isLoadingDashboard = false;
  bool _isLoadingStore = false;
  bool _isLoadingOrders = false;

  Future<void> loadSellerDashboardData() async {
    if (_isLoadingDashboard) return;
    _isLoadingDashboard = true;
    
    try {
      await execute(() async {
        // Parallel fetch for store/inventory and orders
        // No need to call loadMyCatalogs separately as myStore includes them
        await Future.wait([
          loadMyStore(),
          loadStoreOrders(),
        ]);
      });
    } finally {
      _isLoadingDashboard = false;
      notifyListeners();
    }
  }

  Future<void> loadMyStore() async {
    if (_isLoadingStore) return;
    _isLoadingStore = true;
    
    try {
      await execute(() async {
        _myStore = await _sellerService.getMyStore();

        if (_myStore != null) {
          final freshProducts = _myStore!.products
              .where((p) => !_pendingDeleteIds.contains(p.id))
              .toList();

          _myProducts.clear();
          _myProducts.addAll(freshProducts);

          _myCatalogs.clear();
          _myCatalogs.addAll(_myStore!.catalogs);
        }
      });
    } finally {
      _isLoadingStore = false;
      notifyListeners();
    }
  }

  Future<bool> updateStoreInfo(
    Map<String, dynamic> updateData, {
    String? logoPath,
    String? coverImagePath,
  }) async {
    final result = await execute(() async {
      _myStore = await _sellerService.updateStore(
        updateData,
        logoPath: logoPath,
        coverImagePath: coverImagePath,
      );
      return true;
    });
    return result ?? false;
  }

  Future<void> loadStoreOrders() async {
    if (_isLoadingOrders) return;
    _isLoadingOrders = true;
    
    try {
      await execute(() async {
        final data = await _sellerService.getStoreOrders();
        _storeOrders.clear();
        _storeOrders.addAll(data);
      });
    } finally {
      _isLoadingOrders = false;
      notifyListeners();
    }
  }

  Future<bool> updateSellerOrderStatus(String orderId, String status) async {
    final result = await execute(() async {
      await _sellerService.updateOrderStatus(orderId, status);
      final orderIndex = _storeOrders.indexWhere((o) => o['id'].toString() == orderId);
      if (orderIndex != -1) {
        _storeOrders[orderIndex]['status'] = status;
      }
      return true;
    });
    return result ?? false;
  }

  // --- Inventory & Catalog Actions ---

  Future<bool> createCatalog(String name, String description, {String? imagePath}) async {
    final result = await execute(() async {
      final newCatalog = await _sellerService.createStoreCatalog({
        'name': name,
        'description': description,
      }, imagePath: imagePath);
      if (newCatalog != null) {
        _myCatalogs.add(newCatalog);
      }
      return true;
    });
    return result ?? false;
  }

  Future<bool> deleteCatalog(String catalogId) async {
    final result = await execute(() async {
      await _sellerService.deleteStoreCatalog(catalogId);
      _myCatalogs.removeWhere((c) => c.id == catalogId);
      return true;
    });
    return result ?? false;
  }

  Future<bool> updateCatalog(String id, String name, String description, {String? imagePath}) async {
    final result = await execute(() async {
      final updatedCatalog = await _sellerService.updateStoreCatalog(id, {
        'name': name,
        'description': description,
      }, imagePath: imagePath);
      if (updatedCatalog != null) {
        final index = _myCatalogs.indexWhere((c) => c.id == id);
        if (index != -1) _myCatalogs[index] = updatedCatalog;
      }
      return true;
    });
    return result ?? false;
  }

  Future<bool> addProduct(
    ProductModel product, {
    String? imagePath,
    List<String>? otherImagePaths,
  }) async {
    final result = await execute(() async {
      final validationError = product.validate();
      if (validationError != null) throw Exception(validationError);

      final newProduct = await _sellerService.addProduct(
        product.toJson(),
        imagePath: imagePath,
        otherImagePaths: otherImagePaths,
      );

      if (newProduct != null) {
        _myProducts.insert(0, newProduct);
      }
      return true;
    });
    return result ?? false;
  }

  Future<bool> updateProduct(
    ProductModel product, {
    String? imagePath,
    List<String>? otherImagePaths,
  }) async {
    final result = await execute(() async {
      final validationError = product.validate();
      if (validationError != null) throw Exception(validationError);

      final updatedProduct = await _sellerService.updateProduct(
        product.slug,
        product.toJson(),
        imagePath: imagePath,
        otherImagePaths: otherImagePaths,
      );

      if (updatedProduct != null) {
        final myIndex = _myProducts.indexWhere((p) => p.id == product.id);
        if (myIndex != -1) _myProducts[myIndex] = updatedProduct;
      }
      return true;
    });
    return result ?? false;
  }

  Future<bool> deleteProduct(String productId) async {
    String slug = productId;
    try {
      slug = _myProducts.firstWhere((p) => p.id == productId).slug;
    } catch (_) {}

    _myProducts.removeWhere((p) => p.id == productId);
    _pendingDeleteIds.add(productId);
    notifyListeners();

    final result = await execute(() async {
      await _sellerService.deleteProduct(slug);
      return true;
    });

    if (result != true) {
      _pendingDeleteIds.remove(productId);
      await loadMyStore();
    }
    return result ?? false;
  }

  /// Fetches catalogs explicitly if needed. 
  /// Note: loadMyStore() already includes catalogs.
  Future<void> loadMyCatalogs() async {
    await execute(() async {
      final catalogs = await _sellerService.getStoreCatalogs();
      _myCatalogs.clear();
      _myCatalogs.addAll(catalogs);
    });
  }

  Future<bool> assignProductsToCatalog(String catalogId, List<String> productIds) async {
    final success = await execute(() async {
      final success = await _sellerService.assignProductsToCatalog(catalogId, productIds);
      if (success) {
        for (int i = 0; i < _myProducts.length; i++) {
          if (_myProducts[i].catalogId == catalogId) {
            _myProducts[i] = _myProducts[i].copyWith(catalogId: null);
          }
        }
        for (var pid in productIds) {
          final index = _myProducts.indexWhere((p) => p.id == pid);
          if (index != -1) {
            _myProducts[index] = _myProducts[index].copyWith(catalogId: catalogId);
          }
        }
        notifyListeners();
      }
      return success;
    });
    return success ?? false;
  }

  void clearState() {
    _myStore = null;
    _myProducts.clear();
    _myCatalogs.clear();
    _storeOrders.clear();
    _pendingDeleteIds.clear();
    _isLoadingDashboard = false;
    _isLoadingStore = false;
    _isLoadingOrders = false;
    notifyListeners();
  }
}
