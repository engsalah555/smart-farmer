import '../constants.dart';
import 'product_model.dart';
import 'catalog_model.dart';

/// نموذج بيانات المتجر
class StoreModel {
  final String id;
  final String name;
  final String ownerId;
  final String description;
  final String logo;
  final String coverImage;
  final double rating;
  final int reviewsCount;
  final String location;
  final String category;
  final double? latitude;
  final double? longitude;
  final List<ProductModel> products;
  final List<CatalogModel> catalogs;
  final String status; // 'pending', 'verified', 'rejected'
  final int productsCount;

  StoreModel({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.description,
    required this.logo,
    required this.coverImage,
    required this.rating,
    required this.reviewsCount,
    required this.location,
    required this.category,
    this.status = 'pending',
    this.latitude,
    this.longitude,
    this.products = const [],
    this.catalogs = const [],
    this.productsCount = 0,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['id'].toString(),
      name: json['store_name'] ?? json['name'] ?? '',
      ownerId: json['user_id']?.toString() ?? json['ownerId']?.toString() ?? '',
      description: json['description'] ?? '',
      logo: AppConstants.buildUrl(json['logo']?.toString() ?? '') ?? '',
      coverImage: AppConstants.buildUrl(
            json['cover_image']?.toString() ?? json['coverImage']?.toString() ?? '',
          ) ??
          '',
      rating: double.tryParse((json['rating'] ?? 0).toString()) ?? 0.0,
      reviewsCount: json['reviewsCount'] ?? 0,
      location: json['address'] ?? json['location'] ?? 'غير محدد',
      category: json['store_type'] ?? json['category'] ?? 'شامل',
      status: json['status'] ?? 'pending',
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
      products: json['products'] != null
          ? (json['products'] as List)
                .map((e) => ProductModel.fromJson(e))
                .toList()
          : [],
      catalogs: json['catalogs'] != null
          ? (json['catalogs'] as List)
                .map((e) => CatalogModel.fromJson(e))
                .toList()
          : [],
      productsCount: (json['products_count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'store_name': name,
      'user_id': ownerId,
      'description': description,
      'logo': logo,
      'coverImage': coverImage,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'address': location,
      'store_type': category,
      'status': status,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
