import 'package:dio/dio.dart';
import 'base_api_service.dart';

/// خدمة التوثيق - تتعامل مع طلبات توثيق الهوية
class VerificationService extends BaseApiService {
  VerificationService(super.dio);

  static const String _baseUrl = 'verification';

  /// رفع طلب توثيق جديد
  Future<Map<String, dynamic>> submitVerification({
    required String documentType,
    required String imagePath,
  }) async {
    final formData = FormData.fromMap({
      'document_type': documentType,
      'document_image': await MultipartFile.fromFile(
        imagePath,
        filename: imagePath.split('/').last,
      ),
    });

    final data = await post<Map<String, dynamic>>(
      '$_baseUrl/submit',
      data: formData,
      mapper: (data) => Map<String, dynamic>.from(data ?? {}),
    );

    return data ?? {'success': true};
  }

  /// الحصول على حالة طلب التوثيق الحالي
  Future<Map<String, dynamic>?> getVerificationStatus() async {
    return await get<Map<String, dynamic>>(
      '$_baseUrl/status',
      mapper: (data) => data != null ? Map<String, dynamic>.from(data) : {},
    );
  }
}
