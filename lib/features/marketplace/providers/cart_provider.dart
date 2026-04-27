import '../../../core/services/locator.dart';
import '../../../core/providers/base_provider.dart';
import '../../../core/models/cart_model.dart';


import '../services/marketplace_service.dart';
import '../../../core/models/product_model.dart';

class CartProvider extends BaseProvider {
  final MarketplaceService _marketplaceService = locator<MarketplaceService>();
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => {..._items};

  int get itemCount => _items.length;

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.product.price * cartItem.quantity;
    });
    return total;
  }

  void addItem(ProductModel product, {int quantity = 1}) {
    if (_items.containsKey(product.id)) {
      // increase quantity
      final existingItem = _items[product.id]!;
      final newQuantity = existingItem.quantity + quantity;
      
      _items[product.id] = existingItem.copyWith(
        quantity: newQuantity > product.quantity
            ? product.quantity
            : newQuantity,
      );
    } else {
      // add new item
      final initialQty = quantity > product.quantity
          ? product.quantity
          : quantity;
      if (initialQty > 0) {
        _items[product.id] = CartItem(
          product: product, 
          quantity: initialQty
        );
      }
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) {
      return;
    }
    final existingItem = _items[productId]!;
    if (existingItem.quantity > 1) {
      _items[productId] = existingItem.copyWith(
        quantity: existingItem.quantity - 1,
      );
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  Future<bool> checkout({
    required String paymentMethod,
    required String shippingAddress,
    String? notes,
    String? receiptImagePath,
  }) async {
    if (_items.isEmpty) return false;

    final result = await execute(() async {
      // Group items by storeId for backend processing if needed
      // However, backend service currently takes raw items list
      final orderData = {
        'items': _items.values
            .map(
              (cartItem) => {
                'product_id': cartItem.product.id,
                'quantity': cartItem.quantity,
              },
            )
            .toList(),
        'total_amount': totalAmount,
        'payment_method': paymentMethod,
        'shipping_address': shippingAddress,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      };

      await _marketplaceService.checkout(
        orderData,
        receiptImagePath: receiptImagePath,
      );
      clear();
      return true;
    }, errorMessage: 'Error during checkout');

    return result ?? false;
  }
}
