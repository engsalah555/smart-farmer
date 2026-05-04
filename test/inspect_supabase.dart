import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  test('Inspect Supabase Tables', () async {
    await dotenv.load(fileName: ".env");
    final url = dotenv.env['SUPABASE_URL'] ?? '';
    final key = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

    final supabase = SupabaseClient(url, key);

    final tables = ['iot_devices', 'iot_devices_', 'sensor-data', 'relay-log'];

    for (var table in tables) {
      debugPrint('\n--- Inspecting Table: $table ---');
      try {
        final response = await supabase.from(table).select().limit(5);
        if (response.isNotEmpty) {
          debugPrint('✅ Fields in "$table": ${response.first.keys.toList()}');
          debugPrint('✅ Count: ${response.length}');
          debugPrint('✅ Data: $response');
        } else {
          debugPrint('⚠️ Table "$table" exists but is empty.');
        }
      } catch (e) {
        if (e.toString().contains('PGRST205')) {
          debugPrint('❌ Table "$table" not found.');
        } else {
          debugPrint('❌ Error for "$table": $e');
        }
      }
    }
  });
}
