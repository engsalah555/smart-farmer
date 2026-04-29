import '../models/user_model.dart';
import 'base_api_service.dart';

class AdminService extends BaseApiService {
  AdminService(super.dio);

  static const String _baseUrl = 'admin';

  /// الحصول على قائمة المستخدمين مع الترقيم
  Future<Map<String, dynamic>> getUsers({int page = 1, int perPage = 20}) async {
    final response = await get<Map<String, dynamic>>(
      '$_baseUrl/users',
      queryParameters: {'page': page, 'per_page': perPage},
      mapper: (data) => Map<String, dynamic>.from(data),
    );

    if (response != null) {
      return response;
    }
    throw Exception('فشل جلب قائمة المستخدمين');
  }

  /// تبديل حالة توثيق المستخدم
  Future<User> toggleVerification(String userId) async {
    final response = await post<Map<String, dynamic>>(
      '$_baseUrl/users/$userId/toggle-verification',
      mapper: (data) => Map<String, dynamic>.from(data),
    );

    if (response != null && response['success'] == true) {
      // بعد تعديل الباكند، الاستجابة تحتوي على كائن المستخدم كاملاً في data أو response مباشرة
      // حسب هيكلة الـ ApiResponder التي تستخدمها
      final userData = response['data'] ?? response;
      return User.fromJson(userData);
    }
    throw Exception('فشل تغيير حالة التوثيق');
  }

  /// حذف مستخدم
  Future<bool> deleteUser(String userId) async {
    return await delete(
      '$_baseUrl/users/$userId',
    );
  }
}
