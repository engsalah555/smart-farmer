import 'dart:async';
import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/iot_device_model.dart';

class FirebaseIotService {
  final _db = FirebaseDatabase.instanceFor(
    app: Firebase.app("smart-farmer"),
    databaseURL: "https://smartfarmdb-9c4f6-default-rtdb.europe-west1.firebasedatabase.app",
  );
  
  final _sensorsPath = 'SmartFarm/Sensors';
  final _statusPath = 'SmartFarm/Status';
  final _settingsPath = 'SmartFarm/Settings';

  FirebaseIotService();

  /// الاستماع لتحديثات الجهاز بشكل لحظي من فايربيس
  Stream<IotDevice> getDeviceStream(String deviceId) {
    log('📡 Starting Firebase Stream for: SmartFarm');
    return _db.ref('SmartFarm').onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) {
        log('⚠️ Received null data from Firebase');
        return _emptyDevice();
      }

      final sensors = Map<dynamic, dynamic>.from(data['Sensors'] ?? {});
      final status = Map<dynamic, dynamic>.from(data['Status'] ?? {});
      final settings = Map<dynamic, dynamic>.from(data['Settings'] ?? {});

      log('🔥 FIREBASE REALTIME DATA: $data');

      return IotDevice(
        id: '1',
        name: 'نظام الري الذكي',
        status: 'active',
        isIrrigationOn: status['PumpON'] == true,
        autoIrrigation: settings['Mode'] == 'AUTO',
        waterConsumption: 0.0,
        lastSyncAt: DateTime.now(),
        deviceId: deviceId,
        temperature: (sensors['Temp'] as num?)?.toDouble(),
        humidity: (sensors['Hum'] as num?)?.toDouble(),
        soilMoisture: (sensors['Soil'] as num?)?.toDouble(),
        waterLevel: "${sensors['Water']}%",
        rainDetected: (sensors['Rain'] as num? ?? 0) > 40,
        autoThreshold: (settings['AutoThreshold'] as num?)?.toInt() ?? 30,
      );
    });
  }

  /// جلب بيانات الجهاز لمرة واحدة (اختياري، يمكن الاعتماد على الـ Stream)
  Future<IotDevice?> getDevice(String deviceId) async {
    try {
      final snapshot = await _db.ref('SmartFarm').get();
      if (!snapshot.exists) return null;
      
      final data = snapshot.value as Map<dynamic, dynamic>;
      final sensors = Map<dynamic, dynamic>.from(data['Sensors'] ?? {});
      final status = Map<dynamic, dynamic>.from(data['Status'] ?? {});
      final settings = Map<dynamic, dynamic>.from(data['Settings'] ?? {});

      return IotDevice(
        id: '1',
        name: 'نظام الري الذكي',
        status: 'active',
        isIrrigationOn: status['PumpON'] == true,
        autoIrrigation: settings['Mode'] == 'AUTO',
        waterConsumption: 0.0,
        lastSyncAt: DateTime.now(),
        deviceId: deviceId,
        temperature: (sensors['Temp'] as num?)?.toDouble(),
        humidity: (sensors['Hum'] as num?)?.toDouble(),
        soilMoisture: (sensors['Soil'] as num?)?.toDouble(),
        waterLevel: "${sensors['Water']}%",
        rainDetected: (sensors['Rain'] as num? ?? 0) > 40,
        autoThreshold: (settings['AutoThreshold'] as num?)?.toInt() ?? 30,
      );
    } catch (e) {
      log('❌ Error fetching device from Firebase: $e');
      return null;
    }
  }

  /// التحكم اليدوي بالمضخة
  Future<void> toggleManualPump(String deviceId, bool on) async {
    try {
      log('👆 Toggling Pump: $on');
      await _db.ref('$_settingsPath/ManualPump').set(on);
      // عند التحكم اليدوي، ننتقل لوضع MANUAL لضمان استجابة ESP32
      if (on) {
        log('🔄 Switching Mode to MANUAL');
        await _db.ref('$_settingsPath/Mode').set('MANUAL');
      }
      log('✅ Pump toggle command sent successfully');
    } catch (e) {
      log('❌ Failed to toggle pump: $e');
      rethrow;
    }
  }

  /// تغيير وضع الري (تلقائي/يدوي)
  Future<void> setMode(String deviceId, String mode) async {
    await _db.ref('$_settingsPath/Mode').set(mode);
  }

  /// تحديد عتبة الرطوبة للري التلقائي
  Future<void> setThreshold(String deviceId, int threshold) async {
    await _db.ref('$_settingsPath/AutoThreshold').set(threshold);
  }

  IotDevice _emptyDevice() {
    return IotDevice(
      id: '0',
      name: 'جاري الاتصال...',
      status: 'offline',
      isIrrigationOn: false,
      autoIrrigation: false,
      waterConsumption: 0.0,
      deviceId: '',
    );
  }
}
