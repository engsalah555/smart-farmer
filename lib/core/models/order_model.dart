/// نموذج الطلب في السوق
class Order {
  final String id;
  final String userId;
  final String userName;
  final List<OrderItem> items;
  final double totalPrice;
  final OrderStatus status;
  final String shippingAddress;
  final String? phoneNumber;
  final DateTime createdAt;
  final DateTime? deliveredAt;
  final String? notes;

  Order({
    required this.id,
    required this.userId,
    required this.userName,
    required this.items,
    required this.totalPrice,
    required this.status,
    required this.shippingAddress,
    this.phoneNumber,
    required this.createdAt,
    this.deliveredAt,
    this.notes,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id']?.toString() ?? '',
      userId: (json['user_id'] ?? json['userId'] ?? '').toString(),
      userName: json['user_name'] ?? json['userName'] ?? 'مستخدم',
      items: (json['items'] as List?)
              ?.map((item) => OrderItem.fromJson(item))
              .toList() ??
          [],
      totalPrice: double.tryParse((json['total_price'] ?? json['totalPrice'] ?? 0).toString()) ?? 0.0,
      status: OrderStatus.fromString(json['status'] ?? 'pending'),
      shippingAddress: json['shipping_address'] ?? json['shippingAddress'] ?? '',
      phoneNumber: json['phone_number'] ?? json['phoneNumber'],
      createdAt: json['created_at'] != null || json['createdAt'] != null
          ? DateTime.parse((json['created_at'] ?? json['createdAt']).toString())
          : DateTime.now(),
      deliveredAt: json['delivered_at'] != null
          ? DateTime.parse(json['delivered_at'])
          : (json['deliveredAt'] != null ? DateTime.parse(json['deliveredAt']) : null),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'items': items.map((item) => item.toJson()).toList(),
      'totalPrice': totalPrice,
      'status': status.value,
      'shippingAddress': shippingAddress,
      'phoneNumber': phoneNumber,
      'createdAt': createdAt.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
      'notes': notes,
    };
  }

  Order copyWith({
    String? id,
    String? userId,
    String? userName,
    List<OrderItem>? items,
    double? totalPrice,
    OrderStatus? status,
    String? shippingAddress,
    String? phoneNumber,
    DateTime? createdAt,
    DateTime? deliveredAt,
    String? notes,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      items: items ?? this.items,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      notes: notes ?? this.notes,
    );
  }
}

/// عنصر في الطلب
class OrderItem {
  final String productId;
  final String productName;
  final int quantity;
  final double price;
  final String? imageUrl;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    this.imageUrl,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: (json['product_id'] ?? json['productId'] ?? '').toString(),
      productName: json['product_name'] ?? json['productName'] ?? '',
      quantity: json['quantity'] ?? 1,
      price: double.tryParse((json['price'] ?? 0).toString()) ?? 0.0,
      imageUrl: json['product_image'] ?? json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'price': price,
      'imageUrl': imageUrl,
    };
  }

  double get totalPrice => price * quantity;
}

/// حالة الطلب
enum OrderStatus {
  pending('pending', 'قيد الانتظار'),
  confirmed('confirmed', 'مؤكد'),
  processing('processing', 'قيد التجهيز'),
  shipped('shipped', 'تم الشحن'),
  delivered('delivered', 'تم التوصيل'),
  cancelled('cancelled', 'ملغي');

  final String value;
  final String arabicName;

  const OrderStatus(this.value, this.arabicName);

  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => OrderStatus.pending,
    );
  }
}
