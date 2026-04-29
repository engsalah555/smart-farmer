import 'dart:developer';

import 'package:firebase_database/firebase_database.dart';
import '../models/iot_device_model.dart';

class FirebaseIotService {
  final FirebaseDatabase _db = FirebaseDatabase.instance;

  FirebaseIotService();

  Stream<IotDevice> getDeviceStream() {
    // Listen to the root of the database to see all available nodes
    return _db.ref().onValue.map((event) {
      final data = event.snapshot.value;

      log('📡 FIREBASE ROOT DATA: $data');

      if (data == null || data is! Map) {
        return _emptyDevice();
      }

      // Check if data is under 'SmartFarm' or directly in root
      final Map<dynamic, dynamic> rootMap = data;
      final Map<dynamic, dynamic> deviceData = rootMap.containsKey('SmartFarm')
          ? rootMap['SmartFarm'] as Map? ?? {}
          : rootMap;

      final sensors =
          deviceData['Sensors'] as Map? ??
          deviceData['sensors'] as Map? ??
          deviceData;
      final status =
          deviceData['Status'] as Map? ?? deviceData['status'] as Map? ?? {};

      return IotDevice(
        id: 1,
        name: 'نظام المزرعة الذكي',
        status: (status['LastError'] as String? ?? 'OK') == 'OK'
            ? 'active'
            : 'error',
        isIrrigationOn: status['PumpON'] == true,
        autoIrrigation: status['Mode'] == 'AUTO',
        waterConsumption: 0.0,
        deviceId: 'ESP32_FARM_01',
        lastSyncAt: DateTime.now(),
        // Mapping Temp, Hum, Soil keys from Arduino
        temperature: _toDouble(sensors['Temp']),
        humidity: _toDouble(sensors['Hum']),
        soilMoisture: _toDouble(sensors['Soil']),
        waterLevel: _toDouble(sensors['Water']),
        rainLevel: _toDouble(sensors['Rain']),
      );
    });
  }

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Future<void> toggleManualPump(bool on) async {
    await _db.ref('SmartFarm/Settings/ManualPump').set(on);
    // When manually toggling, we usually want to be in MANUAL mode
    if (on) {
      await _db.ref('SmartFarm/Settings/Mode').set('MANUAL');
    }
  }

  Future<void> setMode(String mode) async {
    await _db.ref('SmartFarm/Settings/Mode').set(mode.toUpperCase());
  }

  Future<void> setThreshold(int threshold) async {
    await _db.ref('SmartFarm/Settings/AutoThreshold').set(threshold);
  }

  IotDevice _emptyDevice() {
    return IotDevice(
      id: 0,
      name: 'جاري التحميل...',
      status: 'offline',
      isIrrigationOn: false,
      autoIrrigation: false,
      waterConsumption: 0.0,
      deviceId: '',
    );
  }
}
