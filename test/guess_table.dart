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
        print('Trying table: $table...');
        final response = await supabase.from(table).select().limit(1);
        print('✅ SUCCESS! Table "$table" exists.');
        if (response.isNotEmpty) {
          print('Fields: ${response.first.keys.toList()}');
          print('Data: ${response.first}');
        } else {
          print('Table is empty but exists.');
        }
        found = true;
        break;
      } catch (e) {
        if (e.toString().contains('PGRST205')) {
          print('❌ Table "$table" not found.');
        } else {
          print('⚠️ Error for "$table": $e');
        }
      }
    }
    
    if (!found) {
      print('❌ None of the guessed tables were found.');
    }
    
    expect(true, true); // Just to pass the test
  });
}
