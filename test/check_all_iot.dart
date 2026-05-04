import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  test('Check All IoT Tables', () async {
    await dotenv.load(fileName: ".env");
    final url = dotenv.env['SUPABASE_URL'] ?? '';
    final key = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

    final supabase = SupabaseClient(url, key);

    final tables = ['iot_devices', 'iot_devices_', 'sensor-data', 'relay-log'];

    for (var table in tables) {
      try {
        debugPrint('--- Checking table: $table ---');
        final response = await supabase.from(table).select().limit(1);
        if (response.isEmpty) {
          debugPrint('Table "$table" exists but is empty.');
        } else {
          debugPrint('Table "$table" has data! First row keys: ${response.first.keys.toList()}');
          debugPrint('Data: ${response.first}');
        }
      } catch (e) {
        debugPrint('Error checking "$table": $e');
      }
    }
  });
}
