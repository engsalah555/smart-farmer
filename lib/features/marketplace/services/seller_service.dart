import 'package:dio/dio.dart';
import '../../../core/constants.dart';
import '../../../core/models/product_model.dart';
import '../../../core/models/store_model.dart';
import '../../../core/models/catalog_model.dart';
import '../../../core/services/base_api_service.dart';

class SellerService extends BaseApiService {
  SellerService(super.dio);

  // --- Store Management ---

  Future<StoreModel?> getMyStore() async {
    return await get<StoreModel>(
      AppConstants.myStoreUrl,
      mapper: (data) => StoreModel.fromJson(data),
    );
  }

  Future<StoreModel?> updateStore(
    Map<String, dynamic> storeData, {
    String? logoPath,
    String? coverImagePath,
  }) async {
    final filteredData = <String, dynamic>{};
    storeData.forEach((key, value) {
      if (value != null && value != 'null' && value is! Map) {
        if (value is List) {
          for (int i = 0; i < value.length; i++) {
            filteredData['$key[$i]'] = value[i].toString();
          }
        } else {
          filteredData[key] = value.toString();
        }
      }
    });

    final formData = FormData.fromMap(filteredData);

    if (logoPath != null && logoPath.isNotEmpty && !logoPath.startsWith('http')) {
      formData.files.add(MapEntry('logo', await MultipartFile.fromFile(logoPath, filename: logoPath.split('/').last)));
    }

    if (coverImagePath != null && coverImagePath.isNotEmpty && !coverImagePath.startsWith('http')) {
      formData.files.add(MapEntry('cover_image', await MultipartFile.fromFile(coverImagePath, filename: coverImagePath.split('/').last)));
    }

    return await post<StoreModel>(
      AppConstants.storeUpdateUrl,
      data: formData,
      mapper: (data) => StoreModel.fromJson(data),
    );
  }

  // --- Inventory Management ---

  Future<ProductModel?> addProduct(
    Map<String, dynamic> productData, {
    String? imagePath,
    List<String>? otherImagePaths,
  }) async {
    final filteredData = <String, dynamic>{};
    productData.forEach((key, value) {
      if (value != null && value != 'null' && value is! Map) {
        if (value is List) {
          for (int i = 0; i < value.length; i++) {
            filteredData['$key[$i]'] = value[i].toString();
          }
        } else {
          filteredData[key] = value.toString();
        }
      }
    });

    final formData = FormData.fromMap(filteredData);

    if (imagePath != null && imagePath.isNotEmpty && !imagePath.startsWith('http')) {
      formData.files.add(MapEntry('image', await MultipartFile.fromFile(imagePath, filename: imagePath.split('/').last)));
    }

    if (otherImagePaths != null) {
      for (final path in otherImagePaths) {
        if (path.isNotEmpty && !path.startsWith('http')) {
          formData.files.add(MapEntry('other_images[]', await MultipartFile.fromFile(path, filename: path.split('/').last)));
        }
      }
    }

    return await post<ProductModel>(
      AppConstants.sellerProductsUrl,
      data: formData,
      mapper: (data) => ProductModel.fromJson(data),
    );
  }

  Future<ProductModel?> updateProduct(
    String productId,
    Map<String, dynamic> updateData, {
    String? imagePath,
    List<String>? otherImagePaths,
  }) async {
    final filteredData = <String, dynamic>{};
    updateData.forEach((key, value) {
      if (value != null && value != 'null' && value is! Map) {
        if (value is List) {
          for (int i = 0; i < value.length; i++) {
            filteredData['$key[$i]'] = value[i].toString();
          }
        } else {
          filteredData[key] = value.toString();
        }
      }
    });

    final formData = FormData.fromMap(filteredData);

    if (imagePath != null && imagePath.isNotEmpty && !imagePath.startsWith('http')) {
      formData.files.add(MapEntry('image', await MultipartFile.fromFile(imagePath, filename: imagePath.split('/').last)));
    }

    if (otherImagePaths != null) {
      for (final path in otherImagePaths) {
        if (path.isNotEmpty && !path.startsWith('http')) {
          formData.files.add(MapEntry('other_images[]', await MultipartFile.fromFile(path, filename: path.split('/').last)));
        }
      }
    }

    return await post<ProductModel>(
      '${AppConstants.sellerProductsUrl}/$productId',
      data: formData,
      mapper: (data) => ProductModel.fromJson(data),
    );
  }

  Future<bool> deleteProduct(String productId) async {
    return await delete('${AppConstants.sellerProductsUrl}/$productId');
  }

  // --- Catalog Management ---

  Future<List<CatalogModel>> getStoreCatalogs() async {
    return await get<List<CatalogModel>>(
      AppConstants.catalogsUrl,
      mapper: (data) => (data as List).map((e) => CatalogModel.fromJson(e)).toList(),
    ) ?? [];
  }

  Future<CatalogModel?> createStoreCatalog(
    Map<String, dynamic> catalogData, {
    String? imagePath,
  }) async {
    final formData = FormData.fromMap(catalogData);
    if (imagePath != null && imagePath.isNotEmpty && !imagePath.startsWith('http')) {
      formData.files.add(MapEntry('image', await MultipartFile.fromFile(imagePath, filename: imagePath.split('/').last)));
    }

    return await post<CatalogModel>(
      AppConstants.catalogsUrl,
      data: formData,
      mapper: (data) => CatalogModel.fromJson(data),
    );
  }

  Future<CatalogModel?> updateStoreCatalog(String catalogId, Map<String, dynamic> updateData, {String? imagePath}) async {
    final formData = FormData.fromMap(updateData);
    if (imagePath != null && imagePath.isNotEmpty && !imagePath.startsWith('http')) {
      formData.files.add(MapEntry('image', await MultipartFile.fromFile(imagePath, filename: imagePath.split('/').last)));
    }

    return await post<CatalogModel>(
      '${AppConstants.catalogsUrl}/$catalogId',
      data: formData,
      mapper: (data) => CatalogModel.fromJson(data),
    );
  }

  Future<bool> deleteStoreCatalog(String catalogId) async {
    return await delete('${AppConstants.catalogsUrl}/$catalogId');
  }

  Future<bool> assignProductsToCatalog(String catalogId, List<String> productIds) async {
    final result = await post<bool>(
      '${AppConstants.catalogsUrl}/$catalogId/assign-products',
      data: {'product_ids': productIds},
      mapper: (_) => true,
    );
    return result ?? false;
  }

  // --- Order Fulfillment ---

  Future<List<Map<String, dynamic>>> getStoreOrders() async {
    return await get<List<Map<String, dynamic>>>(
      AppConstants.storeOrdersUrl,
      mapper: (data) {
        if (data is Map && data.containsKey('data')) {
          return (data['data'] as List).cast<Map<String, dynamic>>();
        }
        return (data as List).cast<Map<String, dynamic>>();
      },
    ) ?? [];
  }

  Future<bool> updateOrderStatus(String orderId, String status) async {
    final result = await post<bool>(
      '${AppConstants.storeOrdersUrl}/$orderId/status',
      data: {'status': status},
      mapper: (_) => true,
    );
    return result ?? false;
  }
}
