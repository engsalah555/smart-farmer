import '../constants.dart';

/// نموذج بيانات المنتج
/// يحتوي على جميع المعلومات المتعلقة بالمنتج في المتجر
class ProductModel {
  final String id;
  final String slug; // Used for API update/delete URLs (Backend routes by slug)
  final String title;
  final String description;
  final String category; // Not present in backend explicitly yet, use default
  final double price;
  final String unit;
  final int quantity; // Maps to stock_quantity
  final String storeName; // Fetch from nested relation if possible
  final String storeId;
  final String? catalogId;
  final String? catalogName;
  final List<String> images; // Our UI uses list, backend gives image_url
  final List<String> paymentMethods;
  final String location;
  final String phoneNumber;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String sellerId;
  final double rating;
  final int reviewsCount;
  final String storeLogo;
  final String storeCoverImage;

  ProductModel({
    required this.id,
    String? slug,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.unit,
    required this.quantity,
    required this.storeName,
    required this.storeId,
    this.catalogId,
    this.catalogName,
    required this.images,
    required this.paymentMethods,
    required this.location,
    required this.phoneNumber,
    this.notes,
    required this.createdAt,
    this.updatedAt,
    required this.sellerId,
    this.rating = 0.0,
    this.reviewsCount = 0,
    this.storeLogo = '',
    this.storeCoverImage = '',
  }) : slug = slug ?? id; // fallback to id if slug not provided

  /// تحويل من JSON إلى كائن ProductModel
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Handling relation `store` from Laravel
    final store = json['store'] as Map<String, dynamic>?;

    return ProductModel(
      id: json['id'].toString(),
      slug: json['slug']?.toString() ?? json['id'].toString(), // Backend slugs products
      title: json['name'] ?? json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'شامل',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      unit: json['unit'] ?? 'kg',
      quantity: json['stock_quantity'] ?? json['quantity'] ?? 0,
      storeName: store != null
          ? (store['store_name'] ?? store['name'] ?? '')
          : (json['storeName'] ?? 'متجر غير معروف'),
      storeId:
          json['store_id']?.toString() ??
          json['storeId']?.toString() ??
          'default_store',
      catalogId:
          json['catalog_id']?.toString() ?? json['catalogId']?.toString(),
      catalogName: json['catalog']?['name'] ?? json['catalogName'] as String?,
      images: () {
        final List<String> imgUrls = [];
        if (json['image_url'] != null &&
            json['image_url'].toString().isNotEmpty) {
          imgUrls.add(AppConstants.buildUrl(json['image_url'].toString())!);
        }

        final additional = json['additional_images'];
        if (additional != null && additional is List) {
          for (var img in additional) {
            if (img is String && img.isNotEmpty) {
              imgUrls.add(AppConstants.buildUrl(img)!);
            } else if (img is Map && img['image_url'] != null) {
              imgUrls.add(
                AppConstants.buildUrl(img['image_url'].toString())!,
              );
            }
          }
        }

        if (imgUrls.isEmpty && json['images'] != null) {
          imgUrls.addAll(
            List<String>.from(json['images'])
                .where((e) => e.isNotEmpty)
                .map((e) => AppConstants.buildUrl(e)!),
          );
        }
        return imgUrls;
      }(),
      paymentMethods: json['paymentMethods'] != null
          ? List<String>.from(json['paymentMethods'])
          : ['cash'],
      location: store != null
          ? (store['address'] ?? store['location'] ?? 'غير محدد')
          : (json['location'] ?? 'غير محدد'),
      phoneNumber: json['phoneNumber'] ?? '',
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : (json['createdAt'] != null
                ? DateTime.parse(json['createdAt'])
                : DateTime.now()),
      sellerId: json['sellerId'] ?? store?['user_id']?.toString() ?? '',
      // avg_rating من withAvg() في Laravel، يُرجع null إذا لا توجد تقييمات
      rating:
          double.tryParse(
            (json['avg_rating'] ??
                    json['reviews_avg_rating'] ??
                    json['rating'] ??
                    0)
                .toString(),
          ) ??
          0.0,
      reviewsCount:
          (json['reviews_count'] as num?)?.toInt() ??
          (json['reviewsCount'] as num?)?.toInt() ??
          0,
      storeLogo: AppConstants.buildUrl(
        store != null ? (store['logo'] ?? '') : (json['storeLogo'] ?? ''),
      ) ?? '',
      storeCoverImage: AppConstants.buildUrl(
        store != null
            ? (store['cover_image'] ?? store['coverImage'] ?? '')
            : (json['storeCoverImage'] ?? ''),
      ) ?? '',
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  /// تحويل كائن ProductModel إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'slug': slug,
      'name': title, // map to backend "name"
      'description': description,
      'price': price,
      'unit': unit,
      'stock_quantity': quantity,
      'store_id': storeId,
      'catalog_id': catalogId,
      'catalogName': catalogName,
      'category': category,
      'storeName': storeName,
      'images': images,
      'paymentMethods': paymentMethods,
      'location': location,
      'phoneNumber': phoneNumber,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'sellerId': sellerId,
      'rating': rating,
      'reviews_count': reviewsCount,
      'storeLogo': storeLogo,
      'storeCoverImage': storeCoverImage,
    };
  }

  /// نسخ الكائن مع إمكانية تعديل بعض الحقول
  ProductModel copyWith({
    String? id,
    String? slug,
    String? title,
    String? description,
    String? category,
    double? price,
    String? unit,
    int? quantity,
    String? storeName,
    String? storeId,
    String? catalogId,
    String? catalogName,
    List<String>? images,
    List<String>? paymentMethods,
    String? location,
    String? phoneNumber,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? sellerId,
    double? rating,
    int? reviewsCount,
    String? storeLogo,
    String? storeCoverImage,
  }) {
    return ProductModel(
      id: id ?? this.id,
      slug: slug ?? this.slug,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      unit: unit ?? this.unit,
      quantity: quantity ?? this.quantity,
      storeName: storeName ?? this.storeName,
      storeId: storeId ?? this.storeId,
      catalogId: catalogId ?? this.catalogId,
      catalogName: catalogName ?? this.catalogName,
      images: images ?? this.images,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      location: location ?? this.location,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sellerId: sellerId ?? this.sellerId,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      storeLogo: storeLogo ?? this.storeLogo,
      storeCoverImage: storeCoverImage ?? this.storeCoverImage,
    );
  }

  /// التحقق من صحة البيانات
  String? validate() {
    if (title.trim().isEmpty) {
      return 'يرجى إدخال اسم المنتج';
    }
    if (description.trim().isEmpty) {
      return 'يرجى إدخال وصف المنتج';
    }
    if (price <= 0) {
      return 'يرجى إدخال سعر صحيح';
    }
    if (quantity <= 0) {
      return 'يرجى إدخال كمية صحيحة';
    }
    return null; // البيانات صحيحة
  }

  /// إنشاء كائن فارغ للاختبارات أو كقيم افتراضية
  factory ProductModel.empty() {
    return ProductModel(
      id: '',
      title: '',
      description: '',
      category: 'شامل',
      price: 0.0,
      unit: 'kg',
      quantity: 0,
      storeName: '',
      storeId: '',
      images: [],
      paymentMethods: ['cash'],
      location: '',
      phoneNumber: '',
      createdAt: DateTime.now(),
      sellerId: '',
      storeLogo: '',
      storeCoverImage: '',
    );
  }
}
