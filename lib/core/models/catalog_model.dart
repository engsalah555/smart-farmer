import '../utils/url_helper.dart';

/// نموذج الكتالوج
/// يمثل تصنيف داخل متجر واحد
class CatalogModel {
  final String id;
  final String storeId;
  final String name;
  final String description;
  final String? imageUrl;
  final int sortOrder;
  final int productsCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CatalogModel({
    required this.id,
    required this.storeId,
    required this.name,
    required this.description,
    this.imageUrl,
    this.sortOrder = 0,
    this.productsCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory CatalogModel.fromJson(Map<String, dynamic> json) {
    return CatalogModel(
      id: json['id'].toString(),
      storeId: json['store_id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: UrlHelper.formatImageUrl(json['image_url']),
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      productsCount: (json['products_count'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'store_id': storeId,
    'name': name,
    'description': description,
    'image_url': imageUrl,
    'sort_order': sortOrder,
    'products_count': productsCount,
  };

  CatalogModel copyWith({
    String? id,
    String? storeId,
    String? name,
    String? description,
    String? imageUrl,
    int? sortOrder,
    int? productsCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CatalogModel(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      sortOrder: sortOrder ?? this.sortOrder,
      productsCount: productsCount ?? this.productsCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is CatalogModel && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
