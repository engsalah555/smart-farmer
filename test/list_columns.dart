import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  test('List Columns of iot_devices', () async {
    await dotenv.load(fileName: ".env");
    final url = dotenv.env['SUPABASE_URL'] ?? '';
    final key = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

    final supabase = SupabaseClient(url, key);

    try {
      // Select all rows with a limit to inspect column names
      debugPrint('Attempting to get column names...');
      final response = await supabase.from('iot_devices').select().limit(1);
      if (response.isNotEmpty) {
        debugPrint('Columns: ${response.first.keys.toList()}');
      } else {
        debugPrint('Table is empty, no columns to show.');
      }
    } catch (e) {
      debugPrint('Caught error: $e');
    }
  });
}
