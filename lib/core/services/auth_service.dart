import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

import '../models/user_model.dart';
import 'base_api_service.dart';

/// خدمة المصادقة - تتعامل مع تسجيل الدخول، التسجيل، وإدارة الجلسات
class AuthService extends BaseApiService {
  // Base URL pointing to Laravel Backend
  static String get _baseUrl => '/auth';
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _rememberMeKey = 'remember_me';
  static const String _savedEmailKey = 'saved_email';

  AuthService(super.dio);

  User? _currentUser;

  /// الحصول على المستخدم الحالي (متزامن)
  User? get currentUser => _currentUser;

  /// تهيئة الخدمة وتحميل بيانات المستخدم المحفوظة
  Future<void> init() async {
    final userData = await getUserData();
    if (userData != null) {
      _currentUser = User.fromJson(userData);
    }
  }

  /// تسجيل الدخول
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    required String userType,
  }) async {
    final data = await post<Map<String, dynamic>>(
      '$_baseUrl/login',
      data: {'email': email, 'password': password, 'user_type': userType},
      mapper: (data) => Map<String, dynamic>.from(data),
    );

    if (data != null && data['user'] != null) {
      _currentUser = User.fromJson(data['user']);
      await _saveAuthData(
        token: data['token']?.toString() ?? '',
        userData: data['user'],
      );
      return {
        'success': true,
        'user': data['user'],
        'token': data['token'],
      };
    }
    throw Exception('استجابة غير متوقعة من الخادم');
  }

  /// التسجيل (مستخدم عادي)
  Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final data = await post<Map<String, dynamic>>(
      '$_baseUrl/register',
      data: {
        'name': name,
        'email': email,
        'password': password,
        'user_type': 'user',
      },
      mapper: (data) => Map<String, dynamic>.from(data),
    );

    if (data != null && data['user'] != null) {
      _currentUser = User.fromJson(data['user']);
      await _saveAuthData(
        token: data['token']?.toString() ?? '',
        userData: data['user'],
      );
      return {
        'success': true,
        'user': data['user'],
        'token': data['token'],
      };
    }
    throw Exception('استجابة غير متوقعة من الخادم');
  }

  /// التسجيل (بائع - مزارع أو تاجر)
  Future<Map<String, dynamic>> registerSeller({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String storeType, // 'crops' or 'supplies'
  }) async {
    final data = await post<Map<String, dynamic>>(
      '$_baseUrl/register',
      data: {
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
        'user_type': 'seller',
        'store_type': storeType,
      },
      mapper: (data) => Map<String, dynamic>.from(data),
    );

    if (data != null && data['user'] != null) {
      _currentUser = User.fromJson(data['user']);
      await _saveAuthData(
        token: data['token']?.toString() ?? '',
        userData: data['user'],
      );

      return {
        'success': true,
        'user': data['user'],
        'token': data['token'],
        'requiresVerification': data['requiresVerification'] ?? true,
      };
    }
    throw Exception('استجابة غير متوقعة من الخادم');
  }

  /// استعادة كلمة المرور
  Future<Map<String, dynamic>> forgotPassword({required String email}) async {
    await post(
      '$_baseUrl/forgot-password',
      data: {'email': email},
      mapper: (data) => data,
    );

    return {
      'success': true,
      'message': 'تم إرسال رمز التحقق إلى بريدك الإلكتروني',
    };
  }

  /// تحديث الملف الشخصي
  Future<Map<String, dynamic>> updateProfile({
    required String name,
    String? phone,
    String? currentPassword,
    String? newPassword,
    String? profileImagePath,
  }) async {
    final formData = <String, dynamic>{'name': name};
    if (phone != null && phone.isNotEmpty) formData['phone'] = phone;
    if (currentPassword != null && currentPassword.isNotEmpty) {
      formData['current_password'] = currentPassword;
    }
    if (newPassword != null && newPassword.isNotEmpty) {
      formData['new_password'] = newPassword;
    }

    final dioFormData = FormData.fromMap(formData);

    if (profileImagePath != null && profileImagePath.isNotEmpty) {
      final normalizedPath = profileImagePath.replaceAll('\\', '/');
      final fileName = normalizedPath.split('/').last;
      dioFormData.files.add(
        MapEntry(
          'profile_image',
          await MultipartFile.fromFile(profileImagePath, filename: fileName),
        ),
      );
    }

    final data = await post<Map<String, dynamic>>(
      '$_baseUrl/profile/update',
      data: dioFormData,
      mapper: (data) => Map<String, dynamic>.from(data),
    );

    if (data != null) {
      await _saveAuthData(
        token: (await getToken()) ?? '',
        userData: data,
      );
      return {'success': true, 'user': data};
    }
    throw Exception('فشل تحديث الملف الشخصي');
  }

  /// تسجيل الخروج
  Future<void> logout() async {
    try {
      await post('$_baseUrl/logout', mapper: (data) => data);
    } catch (e) {
      debugPrint('Logout API failed: $e');
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  /// الحصول على الملف الشخصي من الخادم
  Future<Map<String, dynamic>> getProfile() async {
    final data = await get<Map<String, dynamic>>(
      '$_baseUrl/profile',
      mapper: (data) => Map<String, dynamic>.from(data),
    );
    if (data != null) {
      await _saveAuthData(
        token: (await getToken()) ?? '',
        userData: data,
      );
      return data;
    }
    throw Exception('فشل الحصول على بيانات الملف الشخصي');
  }

  /// الحصول على التوكن المحفوظ
  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      debugPrint('خطأ في الحصول على التوكن: $e');
      return null;
    }
  }

  /// الحصول على بيانات المستخدم المحفوظة
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      if (userJson != null) {
        final decoded = jsonDecode(userJson);
        if (decoded is Map<String, dynamic>) return decoded;
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      }
      return null;
    } catch (e) {
      debugPrint('خطأ في الحصول على بيانات المستخدم: $e');
      return null;
    }
  }

  /// التحقق من حالة تسجيل الدخول
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// حفظ بيانات المصادقة
  Future<void> _saveAuthData({
    required String token,
    required Map<String, dynamic> userData,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);

      // Convert userData Map to JSON String before saving
      await prefs.setString(_userKey, jsonEncode(userData));
    } catch (e) {
      debugPrint('خطأ في حفظ بيانات المصادقة: $e');
    }
  }

  /// حفظ بيانات "تذكرني" — يحفظ فقط البريد الإلكتروني لملء الحقل تلقائياً
  /// لا يتم حفظ كلمة المرور أبداً لأسباب أمنية
  Future<void> saveRememberMe({
    required bool rememberMe,
    required String email,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_rememberMeKey, rememberMe);
      if (rememberMe) {
        await prefs.setString(_savedEmailKey, email);
      } else {
        await prefs.remove(_savedEmailKey);
      }
    } catch (e) {
      debugPrint('خطأ في حفظ بيانات تذكرني: $e');
    }
  }

  /// استرجاع بيانات "تذكرني" — البريد الإلكتروني فقط
  Future<Map<String, dynamic>> getRememberMeData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rememberMe = prefs.getBool(_rememberMeKey) ?? false;
      final email = prefs.getString(_savedEmailKey) ?? '';
      return {'rememberMe': rememberMe, 'email': email};
    } catch (e) {
      debugPrint('خطأ في استرجاع بيانات تذكرني: $e');
      return {'rememberMe': false, 'email': ''};
    }
  }

  /// مسح بيانات "تذكرني" عند تسجيل الخروج
  Future<void> clearRememberMe() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_rememberMeKey);
      await prefs.remove(_savedEmailKey);
    } catch (e) {
      debugPrint('خطأ في مسح بيانات تذكرني: $e');
    }
  }


}
