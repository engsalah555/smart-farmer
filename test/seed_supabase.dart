import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  final url = dotenv.env['SUPABASE_URL'] ?? '';
  final key = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  final supabase = SupabaseClient(url, key);

  debugPrint('🚀 Seeding Supabase with master device...');

  try {
    final data = {
      'device_id': 'ESP32-MASTER-001',
      'name': 'المستشعر المركزي',
      'status': 'active',
      'is_irrigation_on': false,
      'auto_irrigation': true,
      'water_consumption': 0.0,
      'temperature': 0.0,
      'humidity': 0.0,
      'soil_moisture': 0.0,
      'soil_temperature': 0.0,
      'water_level': 'Low',
      'rain_detected': false,
      'auto_threshold': 30,
    };

    final response = await supabase.from('iot_devices').upsert(data, onConflict: 'device_id').select();
    debugPrint('✅ Success! Device seeded: $response');
  } catch (e) {
    debugPrint('❌ Error seeding device: $e');
  }
}
