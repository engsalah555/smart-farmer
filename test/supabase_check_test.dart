import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  test('Inspect Supabase Table', () async {
    // Load .env
    await dotenv.load(fileName: ".env");

    final url = dotenv.env['SUPABASE_URL'] ?? '';
    final key = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

    print('Supabase URL: $url');

    final supabase = SupabaseClient(url, key);

    try {
      final response = await supabase.from('iot_devices').select().limit(1);
      if (response.isEmpty) {
        print('Table iot_devices is empty.');
      } else {
        print('Fields in iot_devices:');
        for (var key in response.first.keys) {
          print('- $key');
        }
        print('First row data sample: ${response.first}');
      }
    } catch (e) {
      print('Error querying Supabase: $e');
    }
  });
}
