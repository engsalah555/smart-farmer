import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// كلاس أساسي لجميع Providers
/// يوفر وظائف مشتركة لإدارة الحالة
abstract class BaseProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  bool _isDisposed = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  /// تعيين حالة التحميل
  void setLoading(bool value) {
    if (_isDisposed || _isLoading == value) return;
    _isLoading = value;
    notifyListeners();
  }

  /// تعيين رسالة خطأ
  void setError(String? message) {
    if (_isDisposed || _errorMessage == message) return;
    _errorMessage = message;
    notifyListeners();
  }

  /// مسح رسالة الخطأ
  void clearError() {
    if (_isDisposed) return;
    _errorMessage = null;
    notifyListeners();
  }

  /// تنفيذ عملية مع معالجة التحميل والأخطاء
  Future<T?> execute<T>(
    Future<T> Function() operation, {
    String? errorMessage,
    bool showLoading = true,
  }) async {
    try {
      if (showLoading) setLoading(true);
      clearError();

      final result = await operation();
      return result;
    } catch (e) {
      debugPrint('Error in $runtimeType: $e');
      setError(errorMessage ?? e.toString());
      return null;
    } finally {
      if (showLoading) setLoading(false);
    }
  }

  /// تنفيذ عملية بدون معالجة الأخطاء (للعمليات الصامتة)
  Future<T?> executeSilently<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } catch (e) {
      debugPrint('Silent error in $runtimeType: $e');
      return null;
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (_isDisposed) return;

    // منع الخطأ الشهير: setState() or markNeedsBuild() called during build
    // إذا تم استدعاء التنبيه أثناء مرحلة البناء، نقوم بتأجيله إلى الإطار التالي
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (!_isDisposed) super.notifyListeners();
      });
    } else {
      super.notifyListeners();
    }
  }
}
