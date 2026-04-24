import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/models/crop_model.dart';

/// Offline-first cache for plant guide data using Hive.
/// Provider reads from cache first → then fetches from API on background.
class CropsLocalCache {
  static const _boxName = 'plants_cache';
  static const _plantsKey = 'all_plants';
  static const _timestampKey = 'plants_fetched_at';

  // Cache TTL: 24 hours — sufficient for agricultural reference data
  static const _cacheTtl = Duration(hours: 24);

  late Box _box;
  bool _isInitialized = false;

  Future<void> init() async {
    if (!_isInitialized) {
      _box = await Hive.openBox(_boxName);
      _isInitialized = true;
    }
  }

  /// Returns cached plants or null if cache is empty / stale.
  Future<List<Crop>?> getCachedPlants() async {
    await init();
    final raw = _box.get(_plantsKey);
    if (raw == null) return null;

    // Check freshness
    final fetchedAt = _box.get(_timestampKey);
    if (fetchedAt is int) {
      final age = DateTime.now()
          .difference(DateTime.fromMillisecondsSinceEpoch(fetchedAt));
      if (age > _cacheTtl) return null; // stale — force refresh
    }

    try {
      final list = (raw as List<dynamic>).cast<String>();
      return list
          .map((json) => Crop.fromJson(jsonDecode(json) as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null; // corrupt cache — ignore
    }
  }

  /// Persists plants to local cache with current timestamp.
  Future<void> savePlants(List<Crop> plants) async {
    await init();
    final encoded =
        plants.map((p) => jsonEncode(p.toJson())).toList();
    await _box.put(_plantsKey, encoded);
    await _box.put(_timestampKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Clears the plant cache (useful for pull-to-refresh).
  Future<void> clearPlants() async {
    await init();
    await _box.delete(_plantsKey);
    await _box.delete(_timestampKey);
  }

  Future<bool> get hasCachedData async {
    await init();
    return _box.containsKey(_plantsKey);
  }
}
