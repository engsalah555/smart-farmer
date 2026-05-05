import 'dart:async';
import 'dart:developer';
import 'package:smart_farm2/core/providers/base_provider.dart';
import '../models/iot_device_model.dart';
import '../models/irrigation_log_model.dart';
import '../services/iot_service.dart';
import '../services/firebase_iot_service.dart';


class IotProvider extends BaseProvider {
  final IotService _iotService;
  final FirebaseIotService _firebaseIotService;
  StreamSubscription? _deviceSubscription;

  IotProvider(this._iotService, this._firebaseIotService) {


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

  void _initFirebaseListener(String deviceId) {
    log('🔥 Initializing Firebase Listener for: $deviceId');
    try {
      _deviceSubscription?.cancel();
      _deviceSubscription = _firebaseIotService.getDeviceStream(deviceId).listen((
        updatedDevice,
      ) {
        log('🔄 Received: Temp=${updatedDevice.temperature}, Soil=${updatedDevice.soilMoisture}, Water=${updatedDevice.waterLevel}, Rain=${updatedDevice.rainLevel}%');
        _device = updatedDevice;

        _hasDevice = updatedDevice.deviceId != '0' && updatedDevice.deviceId.isNotEmpty;
        notifyListeners();
      }, onError: (error) {
        log('❌ Firebase Stream Error: $error');
      });
    } catch (e) {
      log('❌ Failed to start Firebase listener: $e');
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
        
        // Fetch initial data once from Firebase
        await _fetchFirebaseData(deviceId);
        
        // Start real-time listener
        _initFirebaseListener(deviceId);
      }
    }, showLoading: showLoading);
  }

  Future<void> _fetchFirebaseData(String deviceId) async {
    log('📥 Fetching initial data from Firebase for: $deviceId');
    
    final initialDevice = await _firebaseIotService.getDevice(deviceId);
    if (initialDevice != null) {
      log('✅ Found initial device state in Firebase');
      _device = initialDevice;
      notifyListeners();
    }
  }


  Future<bool> toggleIrrigation(bool status) async {
    if (_device == null) return false;
    log('🖱️ Toggle Irrigation Clicked: $status');
    try {
      // Optimistic update for better UI response
      _device = _device!.copyWith(isIrrigationOn: status);
      notifyListeners();

      await _firebaseIotService.toggleManualPump(_device!.deviceId, status);
      log('✨ Irrigation toggle command processed');
      return true;
    } catch (e) {
      log('❌ Error toggling irrigation in provider: $e');
      // Rollback on error if necessary (the next stream update will fix it anyway)
      return false;
    }
  }

  Future<bool> toggleAutoIrrigation(bool auto) async {
    if (_device == null) return false;
    log('🖱️ Toggle Auto Irrigation Clicked: $auto');
    try {
      // Optimistic update
      _device = _device!.copyWith(autoIrrigation: auto);
      notifyListeners();

      await _firebaseIotService.setMode(_device!.deviceId, auto ? 'AUTO' : 'MANUAL');
      return true;
    } catch (e) {
      log('❌ Error toggling auto irrigation: $e');
      return false;
    }
  }


  Future<bool> updateThreshold(int threshold) async {
    if (_device == null) return false;
    log('🖱️ Updating Threshold: $threshold');
    try {
      // Optimistic update
      _device = _device!.copyWith(autoThreshold: threshold);
      notifyListeners();

      await _firebaseIotService.setThreshold(_device!.deviceId, threshold);
      return true;
    } catch (e) {
      log('❌ Error updating threshold: $e');
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
