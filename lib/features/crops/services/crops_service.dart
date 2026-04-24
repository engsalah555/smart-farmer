import '../../../core/constants.dart';
import '../../../core/services/base_api_service.dart';
import '../../../core/models/crop_model.dart';
import '../../../core/models/user_crop_model.dart';

class CropsService extends BaseApiService {
  CropsService(super.dio);

  Future<List<Crop>> getPlants() async {
    return await get<List<Crop>>(
          AppConstants.cropsUrl,
          mapper: (data) {
            final List<dynamic> list = data;
            return list.map((json) => Crop.fromJson(json)).toList();
          },
        ) ??
        [];
  }

  Future<List<Crop>> searchLivePlants(String query) async {
    return await get<List<Crop>>(
          AppConstants.cropSearchUrl,
          queryParameters: {'query': query},
          mapper: (data) {
            final List<dynamic> list = data;
            return list.map((json) => Crop.fromJson(json)).toList();
          },
        ) ??
        [];
  }

  Future<List<UserCropData>> getMyCrops() async {
    return await get<List<UserCropData>>(
          AppConstants.myCropsUrl,
          mapper: (data) =>
              (data as List).map((e) => UserCropData.fromJson(e)).toList(),
        ) ??
        [];
  }

  Future<UserCropData?> addCrop(Map<String, dynamic> cropData) async {
    return await post<UserCropData>(
      AppConstants.farmCropsUrl,
      data: cropData,
      mapper: (data) => UserCropData.fromJson(data),
    );
  }

  Future<bool> deleteCrop(String cropId) async {
    return await delete('${AppConstants.farmCropsUrl}/$cropId');
  }
}
