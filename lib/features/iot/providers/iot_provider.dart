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
    _initFirebaseListener();
  }

  IotDevice? _device;
  List<IrrigationLog> _logs = [];
  bool _hasDevice = false;
  String? _message;

  IotDevice? get device => _device;
  List<IrrigationLog> get logs => _logs;
  bool get hasDevice => _hasDevice;
  String? get message => _message;

  void _initFirebaseListener() {
    _deviceSubscription?.cancel();
    _deviceSubscription = _firebaseIotService.getDeviceStream().listen((
      updatedDevice,
    ) {
      _device = updatedDevice;
      _hasDevice = updatedDevice.id != 0;
      notifyListeners();
    });
  }

  Future<void> fetchStatus({bool showLoading = true}) async {
    // We still use this for logs and other non-realtime data from backend
    await execute(() async {
      final data = await _iotService.getStatus();
      // Only update logs and hasDevice from here if needed
      if (data['last_logs'] != null) {
        _logs = (data['last_logs'] as List)
            .map((i) => IrrigationLog.fromJson(i))
            .toList();
      }
    }, showLoading: showLoading);
  }

  Future<bool> toggleIrrigation(bool status) async {
    // Optimistic UI update already handled by Firebase listener usually,
    // but we can also do it here for instant feedback
    try {
      await _firebaseIotService.toggleManualPump(status);
      return true;
    } catch (e) {
      log('Error toggling irrigation: $e');
      return false;
    }
  }

  Future<bool> toggleAutoIrrigation(bool auto) async {
    try {
      await _firebaseIotService.setMode(auto ? 'AUTO' : 'MANUAL');
      return true;
    } catch (e) {
      log('Error toggling auto irrigation: $e');
      return false;
    }
  }

  Future<bool> updateThreshold(int threshold) async {
    try {
      await _firebaseIotService.setThreshold(threshold);
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
