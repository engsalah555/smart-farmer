import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  test('Test Insert into iot_devices', () async {
    await dotenv.load(fileName: ".env");
    final url = dotenv.env['SUPABASE_URL'] ?? '';
    final key = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

    final supabase = SupabaseClient(url, key);

    final testData = {
      'device_id': 'ESP32-MASTER-001',
      'name': 'جهاز الاختبار',
      'status': 'online',
      'is_irrigation_on': false,
      'auto_irrigation': false,
      'water_consumption': 0.0,
      'temperature': 25.5,
      'humidity': 60.0,
      'soil_moisture': 40.0,
      'soil_temperature': 22.0,
      'water_level': 'High',
      'rain_detected': false,
      'auto_threshold': 30,
    };

    debugPrint('Attempting to upsert device info...');
    try {
      final response = await supabase.from('iot_devices').upsert(testData).select();
      debugPrint('✅ Success! Row inserted/updated: $response');
    } catch (e) {
      debugPrint('❌ Failed to insert! Error: $e');

      // If failed, let's try a minimal insert to see what's missing
      debugPrint('\nAttempting minimal insert...');
      try {
        final minResponse = await supabase.from('iot_devices').upsert({
          'device_id': 'ESP32-MASTER-001',
          'name': 'جهاز الاختبار',
        }).select();
        debugPrint('✅ Minimal Success: $minResponse');
      } catch (e2) {
        debugPrint('❌ Minimal insert also failed: $e2');
      }
    }
  });
}
