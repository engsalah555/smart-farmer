import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  test('Guess Supabase Table Name', () async {
    await dotenv.load(fileName: ".env");
    final url = dotenv.env['SUPABASE_URL'] ?? '';
    final key = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

    final supabase = SupabaseClient(url, key);

    final tablesToTry = [
      'iot_devices',
      'devices',
      'sensor_data',
      'esp32',
      'farm_iot',
      'iot_data',
      'sensors',
      'smart_farm',
      'device_data',
      'readings'
    ];

    bool found = false;
    for (var table in tablesToTry) {
      try {
        debugPrint('Trying table: $table...');
        final response = await supabase.from(table).select().limit(1);
        debugPrint('✅ Table "$table" exists. Content: ${response.isNotEmpty ? "Data found" : "Empty"}');
        found = true;
        if (response.isNotEmpty) {
          debugPrint('Fields in "$table": ${response.first.keys.toList()}');
        }
      } catch (e) {
        if (e.toString().contains('PGRST205')) {
          debugPrint('❌ Table "$table" not found.');
        } else {
          debugPrint('⚠️ Error for "$table": $e');
        }
      }
    }
    
    if (!found) {
      debugPrint('❌ None of the guessed tables were found.');
    }
    
    expect(true, true); // Just to pass the test
  });
}
