import 'package:hive_flutter/hive_flutter.dart';
import 'persistence_service.dart';

class HivePersistenceService implements PersistenceService {
  final Map<String, Box> _openBoxes = {};

  @override
  Future<void> init() async {
    await Hive.initFlutter();
  }

  Future<Box> _getBox(String boxName) async {
    if (_openBoxes.containsKey(boxName)) {
      return _openBoxes[boxName]!;
    }
    final box = await Hive.openBox(boxName);
    _openBoxes[boxName] = box;
    return box;
  }

  @override
  Future<void> save(String boxName, String key, dynamic value) async {
    final box = await _getBox(boxName);
    await box.put(key, value);
  }

  @override
  Future<dynamic> get(String boxName, String key, {dynamic defaultValue}) async {
    final box = await _getBox(boxName);
    return box.get(key, defaultValue: defaultValue);
  }

  @override
  Future<void> delete(String boxName, String key) async {
    final box = await _getBox(boxName);
    await box.delete(key);
  }

  @override
  Future<void> clear(String boxName) async {
    final box = await _getBox(boxName);
    await box.clear();
  }

  @override
  bool has(String boxName, String key) {
    // Note: This requires the box to be already open. 
    // In our architecture, we usually get/save first which opens it.
    if (!_openBoxes.containsKey(boxName)) return false;
    return _openBoxes[boxName]!.containsKey(key);
  }
}
