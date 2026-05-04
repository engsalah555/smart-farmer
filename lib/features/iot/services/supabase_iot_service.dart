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

  /// جلب بيانات الجهاز لمرة واحدة
  Future<IotDevice?> getDevice(String deviceId) async {
    try {
      final data = await _supabase
          .from('iot_devices')
          .select()
          .eq('device_id', deviceId)
          .maybeSingle();

      if (data == null) return null;
      return IotDevice.fromJson(data);
    } catch (e) {
      log('❌ Error fetching device from Supabase: $e');
      return null;
    }
  }

  /// جلب سجلات الري من Supabase
  Future<List<Map<String, dynamic>>> getRelayLogs(String deviceId) async {
    try {
      // نستخدم الـ device_id من خلال ربطه بسجلات الحساسات إذا لزم الأمر، 
      // لكن حالياً سنفترض أننا نريد آخر سجلات من جدول relay-log
      final data = await _supabase
          .from('relay-log')
          .select()
          .order('created_at', ascending: false)
          .limit(10);
      
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      log('❌ Error fetching relay logs: $e');
      return [];
    }
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
