import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../services/locator.dart';

class SettingsProvider with ChangeNotifier {
  final Dio _dio = locator<Dio>();

  List<Map<String, dynamic>> _productCategories = [];
  List<String> _units = [];
  List<Map<String, dynamic>> _paymentMethods = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> get productCategories => _productCategories;
  List<String> get units => _units;
  List<Map<String, dynamic>> get paymentMethods => _paymentMethods;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadMetadata() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    debugPrint('📡 Fetching Metadata from: ${_dio.options.baseUrl}/metadata');

    try {
      final response = await _dio.get('/metadata');
      debugPrint('✅ Metadata Response Received: ${response.statusCode}');

      if (response.data != null && response.data['success'] == true) {
        final data = response.data['data']['marketplace'];
        _productCategories = List<Map<String, dynamic>>.from(
          data['categories'],
        );
        _units = List<String>.from(data['units']);
        _paymentMethods = List<Map<String, dynamic>>.from(
          data['payment_methods'],
        );

        // Fallback for payment methods if empty from API
        if (_paymentMethods.isEmpty) {
          _paymentMethods = [
            {'id': 'cash', 'label': 'دفع نقدي', 'icon': 'cash'},
            {'id': 'wallet', 'label': 'محفظة إلكترونية', 'icon': 'wallet'},
            {'id': 'bank', 'label': 'تحويل بنكي', 'icon': 'account_balance'},
          ];
        }

        debugPrint(
          '📦 Loaded ${_productCategories.length} categories, ${_units.length} units, ${_paymentMethods.length} payment methods.',
        );
      } else {
        _errorMessage = 'فشل في تحميل الإعدادات: استجابة غير صحيحة';
        debugPrint('❌ Metadata Error: success is false or data is null');
        _setFallbacks();
      }
    } on DioException catch (e) {
      _errorMessage = 'خطأ في الاتصال: ${e.message}';
      debugPrint('❌ Metadata Network Error: ${e.type} - ${e.message}');
      _setFallbacks();
    } catch (e) {
      _errorMessage = 'خطأ غير متوقع';
      debugPrint('❌ Metadata Unexpected Error: $e');
      _setFallbacks();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _setFallbacks() {
    if (_productCategories.isEmpty) {
      _productCategories = [
        {'id': 'بذور', 'label': 'بذور', 'icon': 'grass'},
        {'id': 'أسمدة', 'label': 'أسمدة', 'icon': 'Science'},
        {'id': 'أدوات', 'label': 'أدوات', 'icon': 'handyman'},
      ];
    }
    if (_units.isEmpty) {
      _units = ['كيلوجرام', 'لتر', 'كيس', 'قطعة'];
    }
    if (_paymentMethods.isEmpty) {
      _paymentMethods = [
        {'id': 'cash', 'label': 'دفع نقدي', 'icon': 'cash'},
        {'id': 'wallet', 'label': 'محفظة إلكترونية', 'icon': 'wallet'},
        {'id': 'bank', 'label': 'تحويل بنكي', 'icon': 'account_balance'},
      ];
    }
  }
}
