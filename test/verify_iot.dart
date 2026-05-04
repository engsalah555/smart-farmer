import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  test('Verify IoT Setup', () async {
    await dotenv.load(fileName: ".env");
    final url = dotenv.env['SUPABASE_URL'] ?? '';
    final key = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

    final supabase = SupabaseClient(url, key);

    debugPrint('Checking connection to Supabase...');
    try {
      final response = await supabase.from('iot_devices').select().limit(1);
      debugPrint('✅ Connection successful.');
      debugPrint('✅ Current data in iot_devices: $response');
      
      if (response.isNotEmpty) {
         debugPrint('✅ Table Columns: ${response.first.keys.toList()}');
      } else {
         debugPrint('⚠️ Table is empty. Please run the SQL script in Supabase Editor.');
      }
    } catch (e) {
      debugPrint('❌ Error: $e');
      if (e.toString().contains('rain_detected')) {
        debugPrint('💡 Hint: The "rain_detected" column is definitely missing. Run the SQL script.');
      } else if (e.toString().contains('Unauthorized') || e.toString().contains('42501')) {
        debugPrint('💡 Hint: RLS is blocking access. Run the SQL script to add the policy.');
      }
    }
  });
}
