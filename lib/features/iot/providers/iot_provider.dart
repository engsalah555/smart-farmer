import 'package:smart_farm2/core/providers/base_provider.dart';
import 'package:smart_farm2/core/services/auth_service.dart';
import 'package:smart_farm2/core/services/locator.dart';
import '../models/iot_device_model.dart';
import '../models/irrigation_log_model.dart';
import '../services/iot_service.dart';

class IotProvider extends BaseProvider {
  final IotService _iotService;
  final AuthService _authService = locator<AuthService>();

  IotProvider(this._iotService);

  IotDevice? _device;
  List<IrrigationLog> _logs = [];
  bool _hasDevice = false;
  String? _message;

  IotDevice? get device => _device;
  List<IrrigationLog> get logs => _logs;
  bool get hasDevice => _hasDevice;
  String? get message => _message;

  Future<void> fetchStatus({bool showLoading = true}) async {
    await execute(() async {
      final data = await _iotService.getStatus();
      _hasDevice = data['has_device'] ?? false;
      
      if (_hasDevice && data['device'] != null) {
        _device = IotDevice.fromJson(data['device']);
        if (data['last_logs'] != null) {
          _logs = (data['last_logs'] as List)
              .map((i) => IrrigationLog.fromJson(i))
              .toList();
        }
      } else {
        _message = data['message'];
      }
    }, showLoading: showLoading);
  }


  Future<bool> toggleIrrigation(bool status) async {
    final previousStatus = _device?.isIrrigationOn;
    if (_device != null && previousStatus != null) {
      _device = _device!.copyWith(isIrrigationOn: status);
      notifyListeners();
    }

    final success = await execute(() async {
      final result = await _iotService.toggleIrrigation(status);
      if (!result) throw 'فشل تغيير حالة الري';
      return true;
    }, showLoading: false);
    
    if (success == true) {
      // Background fetch to ensure consistency
      executeSilently(() => fetchStatus());
      return true;
    } else {
      // Revert optimistic update
      if (_device != null && previousStatus != null) {
        _device = _device!.copyWith(isIrrigationOn: previousStatus);
        notifyListeners();
      }
      return false;
    }
  }

  Future<bool> toggleAutoIrrigation(bool auto) async {
    final previousAuto = _device?.autoIrrigation;
    if (_device != null && previousAuto != null) {
      _device = _device!.copyWith(autoIrrigation: auto);
      notifyListeners();
    }

    final success = await execute(() async {
      final result = await _iotService.updateAutoIrrigation(auto);
      if (!result) throw 'فشل تغيير حالة الري التلقائي';
      return true;
    }, showLoading: false);
    
    if (success == true) {
      executeSilently(() => fetchStatus());
      return true;
    } else {
      if (_device != null && previousAuto != null) {
        _device = _device!.copyWith(autoIrrigation: previousAuto);
        notifyListeners();
      }
      return false;
    }
  }

  Future<bool> addSchedule(String time, List<String> days) async {
    // Cannot easily be optimistic since we need the generated ID
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
    // Optimistic delete
    final previousSchedules = _device?.schedules;
    if (_device != null && previousSchedules != null) {
      final updatedSchedules = previousSchedules.where((s) => s.id != id).toList();
      _device = _device!.copyWith(schedules: updatedSchedules);
      notifyListeners();
    }

    final success = await execute(() async {
      final result = await _iotService.deleteSchedule(id);
      if (!result) throw 'فشل حذف الجدول';
      return true;
    }, showLoading: false);
    
    if (success == true) {
      executeSilently(() => fetchStatus());
      return true;
    } else {
      if (_device != null && previousSchedules != null) {
        _device = _device!.copyWith(schedules: previousSchedules);
        notifyListeners();
      }
      return false;
    }
  }

  Future<bool> requestService() async {
    final success = await execute(() async {
      final result = await _iotService.requestService();
      if (!result) throw 'فشل إرسال الطلب';
      
      // Re-fetch status immediately to update UI to 'pending' state
      await fetchStatus();
      
      return true;
    });
    return success == true;
  }
}
