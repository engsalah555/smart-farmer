import '../models/sensor_data_model.dart';

/// Service for reading farm IoT sensor data.
/// Currently returns mock data; replace with real API call when IoT is connected.
class FarmService {
  Future<SensorData> getSensorData() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return SensorData(
      temperature: 28.5,
      humidity: 65.0,
      soilMoisture: 42.0,
      timestamp: DateTime.now(),
    );
  }
}
