import 'package:dio/dio.dart';
import '../../../core/constants.dart';
import '../../../core/services/base_api_service.dart';

class AIService extends BaseApiService {
  AIService(super.dio);

  /// Send image for disease detection via Laravel AI Endpoint
  Future<Map<String, dynamic>?> detectDisease(String imagePath) async {
    String fileName = imagePath.split('/').last;
    FormData formData = FormData.fromMap({
      "image": await MultipartFile.fromFile(imagePath, filename: fileName),
    });

    return await post<Map<String, dynamic>>(
      AppConstants.aiAnalyzeUrl,
      data: formData,
      mapper: (data) => {
        "disease": data['result'] ?? "Unknown",
        "confidence": 0.9,
        "recommendation": data['recommendation'] ?? "",
      },
    );
  }

  /// Search or Fetch Plant Guide (Uses Gemini via Laravel)
  Future<List<Map<String, dynamic>>> searchCropGuide(String query) async {
    return await get<List<Map<String, dynamic>>>(
          AppConstants.cropSearchUrl,
          queryParameters: {'query': query},
          mapper: (data) => (data as List).cast<Map<String, dynamic>>(),
        ) ??
        [];
  }
}
