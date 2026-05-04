import 'dart:async';
import 'dart:developer';
import 'package:smart_farm2/core/providers/base_provider.dart';
import '../models/iot_device_model.dart';
import '../models/irrigation_log_model.dart';
import '../services/iot_service.dart';
import '../services/supabase_iot_service.dart';

class IotProvider extends BaseProvider {
  final IotService _iotService;
  final SupabaseIotService _supabaseIotService;
  StreamSubscription? _deviceSubscription;

  IotProvider(this._iotService, this._supabaseIotService) {
    log('🏗️ IotProvider Initialized');
  }

  IotDevice? _device;
  List<IrrigationLog> _logs = [];
  bool _hasDevice = false;
  String? _message;

  IotDevice? get device => _device;
  List<IrrigationLog> get logs => _logs;
  bool get hasDevice => _hasDevice;
  String? get message => _message;

  void _initSupabaseListener(String deviceId) {
    log('📡 Initializing Supabase Listener for: $deviceId');
    try {
      _deviceSubscription?.cancel();
      _deviceSubscription = _supabaseIotService.getDeviceStream(deviceId).listen((
        updatedDevice,
      ) {
        log('🔄 Received data from Supabase: ${updatedDevice.id}');
        _device = updatedDevice;
        _hasDevice = updatedDevice.id != '0';
        notifyListeners();
      }, onError: (error) {
        log('❌ Supabase Stream Error: $error');
      });
    } catch (e) {
      log('❌ Failed to start Supabase listener: $e');
    }
  }


  Future<void> fetchStatus({bool showLoading = true}) async {
    log('🔍 Fetching IoT Status from Backend...');
    await execute(() async {
      try {
        final data = await _iotService.getStatus();
        log('📦 Backend Response Data: $data');
        
        _hasDevice = data['has_device'] ?? false;
        _message = data['message'];

        final deviceData = data['device'];
        if (_hasDevice && deviceData != null && deviceData['device_id'] != null) {
          _initSupabaseListener(deviceData['device_id']);
        } else {
          log('⚠️ No active device found for this user according to backend.');
          _deviceSubscription?.cancel();
          _device = null;
        }

        if (data['last_logs'] != null) {
          _logs = (data['last_logs'] as List)
              .map((i) => IrrigationLog.fromJson(i))
              .toList();
        }
      } catch (e) {
        log('❌ Error in fetchStatus: $e');
        _message = 'حدث خطأ أثناء تحميل البيانات';
      }
    }, showLoading: showLoading);
  }

  Future<bool> toggleIrrigation(bool status) async {
    if (_device == null) return false;
    try {
      await _supabaseIotService.toggleManualPump(_device!.deviceId, status);
      return true;
    } catch (e) {
      log('Error toggling irrigation: $e');
      return false;
    }
  }

  Future<bool> toggleAutoIrrigation(bool auto) async {
    if (_device == null) return false;
    try {
      await _supabaseIotService.setMode(_device!.deviceId, auto ? 'AUTO' : 'MANUAL');
      return true;
    } catch (e) {
      log('Error toggling auto irrigation: $e');
      return false;
    }
  }

  Future<bool> updateThreshold(int threshold) async {
    if (_device == null) return false;
    try {
      await _supabaseIotService.setThreshold(_device!.deviceId, threshold);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Rest of the methods (schedules, etc.) can still use _iotService if they are backend-managed
  Future<bool> addSchedule(String time, List<String> days) async {
    final schedule = await execute(() async {
      final result = await _iotService.addSchedule(time, days);
      if (result == null) throw 'فشل إضافة الجدول';
      return result;
    });

    if (schedule != null) {
      executeSilently(() => fetchStatus());
      return true;
    }
    return false;
  }

  Future<bool> deleteSchedule(int id) async {
    final success = await execute(() async {
      final result = await _iotService.deleteSchedule(id);
      if (!result) throw 'فشل حذف الجدول';
      return true;
    }, showLoading: false);

    if (success == true) {
      executeSilently(() => fetchStatus());
      return true;
    }
    return false;
  }

  Future<bool> requestService() async {
    final success = await execute(() async {
      final result = await _iotService.requestService();
      if (!result) throw 'فشل إرسال الطلب';
      await fetchStatus();
      return true;
    });
    return success == true;
  }

  @override
  void dispose() {
    _deviceSubscription?.cancel();
    super.dispose();
  }
}
