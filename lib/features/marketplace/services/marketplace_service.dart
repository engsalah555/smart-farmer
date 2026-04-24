import 'package:dio/dio.dart';
import '../../../core/constants.dart';
import '../../../core/models/product_model.dart';
import '../../../core/models/store_model.dart';
import '../../../core/models/order_model.dart' as order_model;
import '../../../core/services/base_api_service.dart';
import '../../../core/models/paginated_response.dart';

class MarketplaceService extends BaseApiService {
  MarketplaceService(super.dio);

  // =========================================================
  // METADATA
  // =========================================================

  Future<Map<String, dynamic>?> getMetadata() async {
    return await get<Map<String, dynamic>>(
      'metadata',
      mapper: (data) => data as Map<String, dynamic>,
    );
  }

  // =========================================================
  // PRODUCTS — Public
  // =========================================================

  /// جلب المنتجات مع Pagination
  Future<PaginatedResponse<ProductModel>> getProducts({
    int page = 1,
    int perPage = 20,
  }) async {
    return await get<PaginatedResponse<ProductModel>>(
          AppConstants.productsUrl,
          queryParameters: {'page': page, 'per_page': perPage},
          mapper: (data) => PaginatedResponse.fromJson(
            data,
            (item) => ProductModel.fromJson(item as Map<String, dynamic>),
          ),
        ) ??
        PaginatedResponse.empty();
  }

  /// جلب منتجات متجر معين مع فلترة اختيارية بالكتالوج
  Future<PaginatedResponse<ProductModel>> getStoreProducts(
    String storeId, {
    String? catalogId,
    int page = 1,
    int perPage = 20,
  }) async {
    return await get<PaginatedResponse<ProductModel>>(
          '${AppConstants.storesUrl}/$storeId/products',
          queryParameters: {
            'page': page,
            'per_page': perPage,
            'catalog_id': catalogId,
          },
          mapper: (data) => PaginatedResponse.fromJson(
            data,
            (item) => ProductModel.fromJson(item as Map<String, dynamic>),
          ),
        ) ??
        PaginatedResponse.empty();
  }

  // =========================================================
  // STORES — Public
  // =========================================================

  /// قائمة جميع المتاجر مع Pagination
  Future<PaginatedResponse<StoreModel>> getStores({
    int page = 1,
    int perPage = 20,
  }) async {
    return await get<PaginatedResponse<StoreModel>>(
          AppConstants.storesUrl,
          queryParameters: {'page': page, 'per_page': perPage},
          mapper: (data) => PaginatedResponse.fromJson(
            data,
            (item) => StoreModel.fromJson(item as Map<String, dynamic>),
          ),
        ) ??
        PaginatedResponse.empty();
  }

  /// تفاصيل متجر محدد مع كتالوجاته
  Future<StoreModel?> getStoreDetails(String storeId) async {
    return await get<StoreModel>(
      '${AppConstants.storesUrl}/$storeId',
      mapper: (data) => StoreModel.fromJson(data),
    );
  }

  // =========================================================
  // REVIEWS
  // =========================================================

  /// جلب تقييمات منتج
  Future<Map<String, dynamic>> getProductReviews(String productId) async {
    try {
      final response = await dio.get(
        '${AppConstants.productsUrl}/$productId/reviews',
      );

      if (response.data['success'] == true) {
        return {
          'reviews': (response.data['data'] as List? ?? []),
          'avg_rating':
              double.tryParse((response.data['avg_rating'] ?? 0).toString()) ??
              0.0,
          'reviews_count':
              (response.data['reviews_count'] as num?)?.toInt() ?? 0,
        };
      }
      return {'reviews': [], 'avg_rating': 0.0, 'reviews_count': 0};
    } catch (_) {
      return {'reviews': [], 'avg_rating': 0.0, 'reviews_count': 0};
    }
  }

  /// إرسال تقييم جديد (أو تحديث تقييم موجود)
  Future<Map<String, dynamic>?> submitReview(
    String productId, {
    required double rating,
    String? comment,
  }) async {
    return await post<Map<String, dynamic>>(
      '${AppConstants.productsUrl}/$productId/reviews',
      data: {
        'rating': rating,
        if (comment != null && comment.isNotEmpty) 'comment': comment,
      },
      mapper: (data) => data as Map<String, dynamic>,
    );
  }

  // =========================================================
  // ORDERS
  // =========================================================

  /// إتمام الشراء
  Future<Map<String, dynamic>?> checkout(
    Map<String, dynamic> orderData, {
    String? receiptImagePath,
  }) async {
    if (receiptImagePath != null && receiptImagePath.isNotEmpty) {
      final formData = FormData();

      formData.fields
        ..add(MapEntry('total_amount', orderData['total_amount'].toString()))
        ..add(
          MapEntry('payment_method', orderData['payment_method'].toString()),
        )
        ..add(
          MapEntry(
            'shipping_address',
            orderData['shipping_address'].toString(),
          ),
        );

      if (orderData.containsKey('notes')) {
        formData.fields.add(MapEntry('notes', orderData['notes'].toString()));
      }

      final items = orderData['items'] as List<dynamic>;
      for (int i = 0; i < items.length; i++) {
        final item = items[i] as Map<String, dynamic>;
        formData.fields
          ..add(
            MapEntry('items[$i][product_id]', item['product_id'].toString()),
          )
          ..add(MapEntry('items[$i][quantity]', item['quantity'].toString()));
      }

      formData.files.add(
        MapEntry(
          'receipt_image',
          await MultipartFile.fromFile(
            receiptImagePath,
            filename: receiptImagePath.split('/').last,
          ),
        ),
      );

      return await post<Map<String, dynamic>>(
        AppConstants.checkoutUrl,
        data: formData,
        mapper: (data) => data as Map<String, dynamic>,
      );
    }

    return await post<Map<String, dynamic>>(
      AppConstants.checkoutUrl,
      data: orderData,
      mapper: (data) => data as Map<String, dynamic>,
    );
  }

  /// طلباتي كمشتري
  Future<PaginatedResponse<order_model.Order>> getOrders({
    int page = 1,
    int perPage = 20,
  }) async {
    return await get<PaginatedResponse<order_model.Order>>(
          AppConstants.ordersUrl,
          queryParameters: {'page': page, 'per_page': perPage},
          mapper: (data) => PaginatedResponse.fromJson(
            data,
            (item) => order_model.Order.fromJson(item as Map<String, dynamic>),
          ),
        ) ??
        PaginatedResponse.empty();
  }
}
