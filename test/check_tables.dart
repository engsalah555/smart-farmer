import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

void main() async {
  // Load .env
  await dotenv.load(fileName: '.env');

  final url = dotenv.env['SUPABASE_URL'];
  final key = dotenv.env['SUPABASE_ANON_KEY'];

  if (url == null || key == null) {
    debugPrint('❌ Missing SUPABASE_URL or SUPABASE_ANON_KEY in .env');
    return;
  }

  await Supabase.initialize(url: url, anonKey: key);
  final client = Supabase.instance.client;

  debugPrint('🚀 Connected to Supabase: $url');

  try {
    // Try to fetch from iot_devices
    debugPrint('🧐 Checking table: iot_devices...');
    try {
      final res = await client.from('iot_devices').select().limit(1);
      debugPrint('✅ Table [iot_devices] exists. Count: ${res.length}');
    } catch (e) {
      debugPrint('❌ Table [iot_devices] error: $e');
    }

    // Try to fetch from iot_devices_
    debugPrint('🧐 Checking table: iot_devices_...');
    try {
      final res = await client.from('iot_devices_').select().limit(1);
      debugPrint('✅ Table [iot_devices_] exists. Count: ${res.length}');
    } catch (e) {
      debugPrint('❌ Table [iot_devices_] error: $e');
    }

    // Try to fetch from sensor-data
    debugPrint('🧐 Checking table: sensor-data...');
    try {
      final res = await client.from('sensor-data').select().limit(1);
      debugPrint('✅ Table [sensor-data] exists. Count: ${res.length}');
    } catch (e) {
      debugPrint('❌ Table [sensor-data] error: $e');
    }

    // List all rows in iot_devices (or iot_devices_) to find the device_id
    debugPrint('\n--- Device List ---');
    final tablesToTry = ['iot_devices', 'iot_devices_'];
    for (var table in tablesToTry) {
      try {
        final devices = await client.from(table).select();
        debugPrint('Table [$table] devices:');
        for (var d in devices) {
          debugPrint('  - ID: ${d['id']}, device_id: ${d['device_id']}, name: ${d['name']}');
        }
      } catch (_) {}
    }

  } catch (e) {
    debugPrint('❌ Unexpected error: $e');
  }

  exit(0);
}
