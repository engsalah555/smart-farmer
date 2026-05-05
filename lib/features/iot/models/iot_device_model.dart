import 'irrigation_schedule_model.dart';

class IotDevice {
  final String id;
  final String name;
  final String status;
  final bool isIrrigationOn;
  final bool autoIrrigation;
  final double waterConsumption;
  final DateTime? lastSyncAt;
  final String deviceId;
  final List<IrrigationSchedule> schedules;
  final double? temperature;
  final double? humidity;
  final double? soilMoisture;
  final double? soilTemperature;
  final String? waterLevel;
  final bool? rainDetected;
  final int? autoThreshold;
  final double? rainLevel;


  IotDevice({
    required this.id,
    required this.name,
    required this.status,
    required this.isIrrigationOn,
    required this.autoIrrigation,
    required this.waterConsumption,
    this.lastSyncAt,
    required this.deviceId,
    this.schedules = const [],
    this.temperature,
    this.humidity,
    this.soilMoisture,
    this.soilTemperature,
    this.waterLevel,
    this.rainDetected,
    this.autoThreshold,
    this.rainLevel,
  });


  IotDevice copyWith({
    String? id,
    String? name,
    String? status,
    bool? isIrrigationOn,
    bool? autoIrrigation,
    double? waterConsumption,
    DateTime? lastSyncAt,
    String? deviceId,
    List<IrrigationSchedule>? schedules,
    double? temperature,
    double? humidity,
    double? soilMoisture,
    double? soilTemperature,
    String? waterLevel,
    bool? rainDetected,
    int? autoThreshold,
    double? rainLevel,
  }) {

    return IotDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      isIrrigationOn: isIrrigationOn ?? this.isIrrigationOn,
      autoIrrigation: autoIrrigation ?? this.autoIrrigation,
      waterConsumption: waterConsumption ?? this.waterConsumption,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      deviceId: deviceId ?? this.deviceId,
      schedules: schedules ?? this.schedules,
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      soilMoisture: soilMoisture ?? this.soilMoisture,
      soilTemperature: soilTemperature ?? this.soilTemperature,
      waterLevel: waterLevel ?? this.waterLevel,
      rainDetected: rainDetected ?? this.rainDetected,
      autoThreshold: autoThreshold ?? this.autoThreshold,
      rainLevel: rainLevel ?? this.rainLevel,
    );

  }

  factory IotDevice.fromJson(Map<String, dynamic> json) {
    return IotDevice(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? 'جهاز غير معروف',
      status: json['status'] as String? ?? 'offline',
      isIrrigationOn: json['is_irrigation_on'] == true || json['is_irrigation_on'] == 1,
      autoIrrigation: json['auto_irrigation'] == true || json['auto_irrigation'] == 1,
      waterConsumption: (json['water_consumption'] as num?)?.toDouble() ?? 0.0,
      lastSyncAt: json['last_sync_at'] != null ? DateTime.parse(json['last_sync_at']) : null,
      deviceId: json['device_id'] as String? ?? '',
      schedules: (json['schedules'] as List<dynamic>?)
              ?.map((e) => IrrigationSchedule.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      temperature: (json['temperature'] as num?)?.toDouble(),
      humidity: (json['humidity'] as num?)?.toDouble(),
      soilMoisture: (json['soil_moisture'] as num?)?.toDouble(),
      soilTemperature: (json['soil_temperature'] as num?)?.toDouble(),
      waterLevel: json['water_level']?.toString(),
      rainDetected: json['rain_detected'] == true || json['rain_detected'] == 1,
      autoThreshold: (json['auto_threshold'] as num?)?.toInt(),
      rainLevel: (json['rain_level'] as num?)?.toDouble(),
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status,
      'is_irrigation_on': isIrrigationOn,
      'auto_irrigation': autoIrrigation,
      'water_consumption': waterConsumption,
      'last_sync_at': lastSyncAt?.toIso8601String(),
      'device_id': deviceId,
      'schedules': schedules.map((e) => e.toJson()).toList(),
      'temperature': temperature,
      'humidity': humidity,
      'soil_moisture': soilMoisture,
      'soil_temperature': soilTemperature,
      'water_level': waterLevel,
      'rain_detected': rainDetected,
      'auto_threshold': autoThreshold,
      'rain_level': rainLevel,
    };
  }

}
