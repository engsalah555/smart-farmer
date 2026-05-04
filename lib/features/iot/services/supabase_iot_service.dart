import 'dart:async';
import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/iot_device_model.dart';

class SupabaseIotService {
  final _supabase = Supabase.instance.client;

  SupabaseIotService();

  /// الاستماع لتحديثات الجهاز بشكل لحظي
  Stream<IotDevice> getDeviceStream(String deviceId) {
    return _supabase
        .from('iot_devices')
        .stream(primaryKey: ['id'])
        .eq('device_id', deviceId)
        .map((List<Map<String, dynamic>> data) {
          if (data.isEmpty) return _emptyDevice();
          final deviceData = data.first;
          log('📡 SUPABASE REALTIME DATA: $deviceData');

          return IotDevice.fromJson(deviceData);
        });
  }


  /// التحكم اليدوي بالمضخة
  Future<void> toggleManualPump(String deviceId, bool on) async {
    await _supabase
        .from('iot_devices')
        .update({'is_irrigation_on': on})
        .eq('device_id', deviceId);
  }

  /// تغيير وضع الري (تلقائي/يدوي)
  Future<void> setMode(String deviceId, String mode) async {
    await _supabase
        .from('iot_devices')
        .update({'auto_irrigation': mode == 'AUTO'})
        .eq('device_id', deviceId);
  }

  /// تحديد عتبة الرطوبة للري التلقائي
  Future<void> setThreshold(String deviceId, int threshold) async {
    await _supabase
        .from('iot_devices')
        .update({'auto_threshold': threshold})
        .eq('device_id', deviceId);
  }

  IotDevice _emptyDevice() {
    return IotDevice(
      id: '0',
      name: 'جاري التحميل...',
      status: 'offline',
      isIrrigationOn: false,
      autoIrrigation: false,
      waterConsumption: 0.0,
      deviceId: '',
    );
  }
}
