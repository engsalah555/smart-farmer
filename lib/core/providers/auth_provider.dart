import 'package:shared_preferences/shared_preferences.dart';

import 'base_provider.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

/// مزود حالة المصادقة - يدير حالة تسجيل الدخول والمستخدم الحالي
class AuthProvider extends BaseProvider {
  final AuthService _authService;

  AuthProvider(this._authService);

  // حالة المصادقة
  bool _isAuthenticated = false;
  User? _currentUser;
  bool _rememberMe = false;
  String _savedEmail = '';

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  User? get currentUser => _currentUser;
  bool get rememberMe => _rememberMe;
  String get savedEmail => _savedEmail;

  /// تهيئة المزود - التحقق من حالة تسجيل الدخول وتحميل بيانات "تذكرني"
  Future<void> init() async {
    await execute(() async {
      // تحميل بيانات "تذكرني" — البريد الإلكتروني فقط
      final rememberData = await _authService.getRememberMeData();
      _rememberMe = rememberData['rememberMe'] as bool? ?? false;
      _savedEmail = rememberData['email'] as String? ?? '';

      // التحقق من حالة تسجيل الدخول
      final isLoggedIn = await _authService.isLoggedIn();
      if (isLoggedIn) {
        final userData = await _authService.getUserData();
        if (userData != null) {
          _currentUser = User.fromJson(userData);
          _isAuthenticated = true;
        }
      }
    }, errorMessage: 'فشل التحقق من حالة تسجيل الدخول');
  }

  /// تسجيل الدخول
  Future<bool> login({
    required String email,
    required String password,
    required String userType,
    bool rememberMe = false,
  }) async {
    final success = await execute(() async {
      final data = await _authService.login(
        email: email,
        password: password,
        userType: userType,
      );

      final user = User.fromJson(data['user']);

      // ✅ التحقق من نوع الحساب: إذا حاول الدخول كبائع وهو مستخدم عادي
      if (userType == 'seller' && !user.isSeller) {
        throw Exception('هذا الحساب لمستخدم عادي');
      }

      _currentUser = user;
      _isAuthenticated = true;
      _rememberMe = rememberMe;

      // حفظ بيانات "تذكرني" — بريد فقط، لا كلمة مرور
      await _authService.saveRememberMe(rememberMe: rememberMe, email: email);

      if (rememberMe) {
        _savedEmail = email;
      } else {
        _savedEmail = '';
      }
      return true;
    });

    return success ?? false;
  }

  /// التسجيل (مستخدم عادي)
  Future<bool> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final success = await execute(() async {
      final data = await _authService.registerUser(
        name: name,
        email: email,
        password: password,
      );

      _currentUser = User.fromJson(data['user']);
      _isAuthenticated = true;
      return true;
    });

    return success ?? false;
  }

  /// التسجيل (بائع - مزارع أو تاجر)
  Future<Map<String, dynamic>> registerSeller({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String storeType,
  }) async {
    Map<String, dynamic>? finalResult;
    final success = await execute(() async {
      final data = await _authService.registerSeller(
        name: name,
        email: email,
        password: password,
        phone: phone,
        storeType: storeType,
      );

      if (data['token'] != null) {
        _currentUser = User.fromJson(data['user']);
        _isAuthenticated = true;
      }
      finalResult = {
        'success': true,
        'requiresVerification': data['requiresVerification'] ?? true,
      };
      return true;
    });

    if (success == true) {
      return finalResult!;
    } else {
      return {'success': false, 'message': errorMessage};
    }
  }

  /// استعادة كلمة المرور
  Future<bool> forgotPassword({required String email}) async {
    final success = await execute(() async {
      await _authService.forgotPassword(email: email);
      return true;
    });

    return success ?? false;
  }

  /// تسجيل الخروج
  Future<void> logout() async {
    await execute(() async {
      await _authService.logout();

      // إذا لم يكن "تذكرني" مفعلاً، امسح البيانات المحفوظة
      if (!_rememberMe) {
        await _authService.clearRememberMe();
        _savedEmail = '';
      }

      _isAuthenticated = false;
      _currentUser = null;
    });
  }

  /// تسجيل الخروج القسري محلياً (في حالة انتهاء الجلسة أو 401)
  Future<void> forceLogout() async {
    await executeSilently(() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_data');
      if (!_rememberMe) {
        await _authService.clearRememberMe();
        _savedEmail = '';
      }
      _isAuthenticated = false;
      _currentUser = null;
    });
    notifyListeners();
  }

  /// تحديث الملف الشخصي
  Future<bool> updateProfile({
    required String name,
    String? phone,
    String? currentPassword,
    String? newPassword,
    dynamic profileImage, // File?
  }) async {
    final success = await execute(() async {
      final data = await _authService.updateProfile(
        name: name,
        phone: phone,
        currentPassword: currentPassword,
        newPassword: newPassword,
        profileImagePath: profileImage?.path,
      );

      _currentUser = User.fromJson(data['user'] ?? data);
      return true;
    });

    return success ?? false;
  }

  /// تبديل حالة "تذكرني"
  void toggleRememberMe() {
    _rememberMe = !_rememberMe;
    notifyListeners();
  }

  /// ضبط حالة "تذكرني" مباشرة
  void setRememberMe(bool value) {
    _rememberMe = value;
    notifyListeners();
  }

  /// تحديث بيانات المستخدم الحالية من الخادم
  Future<void> refreshProfile() async {
    await executeSilently(() async {
      final userData = await _authService.getUserData();
      if (userData != null) {
        _currentUser = User.fromJson(userData);
        notifyListeners();
      }
    });
  }

  /// تحديث بيانات المستخدم محلياً (تُستخدم للمزامنة الفورية)
  void updateUserLocally(User user) {
    _currentUser = user;
    notifyListeners();
  }
}

