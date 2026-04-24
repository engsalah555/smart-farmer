import 'product_model.dart';

/// نموذج السلة
class Cart {
  final List<CartItem> items;

  Cart({this.items = const []});

  /// إجمالي عدد المنتجات
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  /// إجمالي السعر
  double get totalPrice =>
      items.fold(0.0, (sum, item) => sum + item.totalPrice);

  /// إضافة منتج للسلة
  Cart addItem(ProductModel product, {int quantity = 1}) {
    final existingIndex = items.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex >= 0) {
      // المنتج موجود، زيادة الكمية
      final updatedItems = List<CartItem>.from(items);
      updatedItems[existingIndex] = updatedItems[existingIndex].copyWith(
        quantity: updatedItems[existingIndex].quantity + quantity,
      );
      return Cart(items: updatedItems);
    } else {
      // منتج جديد
      return Cart(
        items: [
          ...items,
          CartItem(product: product, quantity: quantity),
        ],
      );
    }
  }

  /// إزالة منتج من السلة
  Cart removeItem(String productId) {
    return Cart(
      items: items.where((item) => item.product.id != productId).toList(),
    );
  }

  /// تحديث كمية منتج
  Cart updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      return removeItem(productId);
    }

    final updatedItems = items.map((item) {
      if (item.product.id == productId) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();

    return Cart(items: updatedItems);
  }

  /// تفريغ السلة
  Cart clear() {
    return Cart(items: []);
  }

  /// التحقق من وجود منتج
  bool hasProduct(String productId) {
    return items.any((item) => item.product.id == productId);
  }

  /// الحصول على كمية منتج
  int getQuantity(String productId) {
    final item = items.firstWhere(
      (item) => item.product.id == productId,
      orElse: () => CartItem(product: ProductModel.empty(), quantity: 0),
    );
    return item.quantity;
  }

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      items:
          (json['items'] as List?)
              ?.map((item) => CartItem.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {'items': items.map((item) => item.toJson()).toList()};
  }

  Cart copyWith({List<CartItem>? items}) {
    return Cart(items: items ?? this.items);
  }
}

/// عنصر في السلة
class CartItem {
  final ProductModel product;
  final int quantity;

  CartItem({required this.product, required this.quantity});

  double get totalPrice {
    return product.price * quantity;
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: ProductModel.fromJson(json['product']),
      quantity: json['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {'product': product.toJson(), 'quantity': quantity};
  }

  CartItem copyWith({ProductModel? product, int? quantity}) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}
