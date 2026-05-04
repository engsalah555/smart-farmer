import 'package:timezone/timezone.dart' as tz;

import '../../../core/providers/base_provider.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/locator.dart';
import '../../../core/models/crop_model.dart';
import '../../../core/models/user_crop_model.dart';
import '../services/crops_service.dart';
import '../data/crops_local_cache.dart';

class CropsProvider extends BaseProvider {
  final CropsService _cropsService;
  final CropsLocalCache _cache = CropsLocalCache();

  CropsProvider(this._cropsService);

  List<Crop> _allPlants = [];
  List<UserCropData> _myCrops = [];

  List<Crop> get allPlants => _allPlants;
  List<UserCropData> get myCrops => _myCrops;

  /// Initialize local cache. Call once at app startup.
  Future<void> initCache() async => _cache.init();

  /// Fetch professional plants guide — Offline-First:
  /// 1. Instantly show cached data (if fresh).
  /// 2. Refresh from API in background and update cache.
  Future<void> fetchPlants({bool forceRefresh = false}) async {
    // 1. Serve cached data immediately (non-blocking)
    if (!forceRefresh) {
      final cached = await _cache.getCachedPlants();
      if (cached != null && cached.isNotEmpty) {
        _allPlants = cached;
        notifyListeners();
        // Background refresh (don't show loading spinner for cache hit)
        _refreshPlantsInBackground();
        return;
      }
    }

    // 2. No cache or forced refresh — full API fetch with loading state
    await execute(() async {
      _allPlants = await _cropsService.getPlants();
      await _cache.savePlants(_allPlants);
    });
  }

  Future<void> _refreshPlantsInBackground() async {
    try {
      final fresh = await _cropsService.getPlants();
      _allPlants = fresh;
      await _cache.savePlants(fresh);
      notifyListeners();
    } catch (_) {
      // Silent failure — cached data is still shown
    }
  }

  /// Search and add a live plant from the web to the guide
  Future<void> searchLivePlant(String query) async {
    await execute(() async {
      final livePlants = await _cropsService.searchLivePlants(query);
      if (livePlants.isNotEmpty) {
        // Add to the top of the guide without duplicating names
        _allPlants.removeWhere((p) => p.name == livePlants.first.name);
        _allPlants.insert(0, livePlants.first);
      } else {
        throw Exception('عذراً، لم نجد معلومات حول "$query"');
      }
    });
  }

  /// Fetch user specific crops
  Future<void> fetchMyCrops() async {
    await execute(() async {
      _myCrops = await _cropsService.getMyCrops();
    });
  }

  /// Add a plant to user's farm
  Future<bool> addCropToFarm(
    String userId,
    String plantId, {
    String? notes,
  }) async {
    bool success = false;
    await execute(() async {
      if (_myCrops.length >= 8) {
        throw Exception('لقد وصلت للحد الأقصى المسموح به (8 محاصيل). يرجى حذف محصول قبل إضافة جديد.');
      }

      final plant = _allPlants.firstWhere(
        (p) => p.id == plantId,
        orElse: () => throw Exception('النبات غير موجود في الدليل'),
      );

      final cropData = {
        'plant_id': plant.id,
        'name': plant.name,
        'crop_type': plant.category,
        'plantation_date': DateTime.now().toIso8601String().split('T')[0],
        'notes': notes,
      };

      final newCrop = await _cropsService.addCrop(cropData);
      if (newCrop != null) {
        _myCrops.insert(0, newCrop);

        // Schedule watering reminder if nextWatering is available
        if (newCrop.nextWatering != null) {
          final notificationId = newCrop.id.hashCode;
          locator<NotificationService>().scheduleWateringReminder(
            id: notificationId,
            plantName: newCrop.plant.name,
            scheduledDate: tz.TZDateTime.from(newCrop.nextWatering!, tz.local),
          );
        }
        success = true;
      }
    });
    return success;
  }

  /// Remove a plant from user's farm
  Future<bool> removeCropFromFarm(String userCropId) async {
    bool success = false;
    await execute(() async {
      final result = await _cropsService.deleteCrop(userCropId);
      if (result) {
        _myCrops.removeWhere((crop) => crop.id == userCropId);
        // Cancel the notification automatically
        locator<NotificationService>().cancelReminder(userCropId.hashCode);
        success = true;
      }
    });
    return success;
  }
}
