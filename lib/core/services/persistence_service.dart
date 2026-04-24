import 'dart:async';

abstract class PersistenceService {
  Future<void> init();
  
  /// Save a value by key
  Future<void> save(String boxName, String key, dynamic value);
  
  /// Get a value by key
  Future<dynamic> get(String boxName, String key, {dynamic defaultValue});
  
  /// Delete a value by key
  Future<void> delete(String boxName, String key);
  
  /// Clear a box
  Future<void> clear(String boxName);
  
  /// Check if a key exists
  bool has(String boxName, String key);
}
