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
        log('🔄 Received data from Supabase: ID=${updatedDevice.id}, Temp=${updatedDevice.temperature}, Hum=${updatedDevice.humidity}');
        _device = updatedDevice;
        _hasDevice = updatedDevice.deviceId != '0' && updatedDevice.deviceId.isNotEmpty;
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
        _message = data['message'];

        if (data['last_logs'] != null && (data['last_logs'] as List).isNotEmpty) {
          _logs = (data['last_logs'] as List)
              .map((i) => IrrigationLog.fromJson(i))
              .toList();
        }
      } catch (e) {
        log('❌ Error in fetchStatus (Backend): $e');
        _message = 'استخدمنا البيانات المباشرة لتجاوز خطأ الخادم';
      } finally {
        const deviceId = 'ESP32-MASTER-001';
        // For graduation project: Force device connection
        _hasDevice = true;
        
        // Fetch initial data once from Supabase
        await _fetchSupabaseData(deviceId);
        
        // Start real-time listener
        _initSupabaseListener(deviceId);
      }
    }, showLoading: showLoading);
  }

  Future<void> _fetchSupabaseData(String deviceId) async {
    log('📥 Fetching initial data from Supabase for: $deviceId');
    
    // 1. Fetch Device State
    final initialDevice = await _supabaseIotService.getDevice(deviceId);
    if (initialDevice != null) {
      log('✅ Found initial device state in Supabase');
      _device = initialDevice;
      notifyListeners();
    }

    // 2. Fetch Relay Logs from Supabase (as fallback or addition)
    final rawLogs = await _supabaseIotService.getRelayLogs(deviceId);
    if (rawLogs.isNotEmpty) {
      log('📜 Found ${rawLogs.length} relay logs in Supabase');
      final supabaseLogs = rawLogs.map((json) {
        final status = json['relay_status'] == true || json['relay_status'] == 1;
        final reason = json['trigger_reason']?.toString() ?? '';
        
        String action = 'unknown';
        if (reason == 'frontend-command') {
          action = status ? 'manual_on' : 'manual_off';
        } else if (reason == 'auto_threshold' || reason.contains('auto')) {
          action = status ? 'auto_on' : 'auto_off';
        } else {
          action = status ? 'on' : 'off';
        }

        return IrrigationLog(
          id: json['id'] as int? ?? 0,
          action: action,
          duration: 0, 
          waterUsed: 0.0,
          createdAt: DateTime.parse(json['created_at']),
        );
      }).toList();

      // If we don't have logs from backend, use Supabase logs
      if (_logs.isEmpty) {
        _logs = supabaseLogs;
      }
      notifyListeners();
    }
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
