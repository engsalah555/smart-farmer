import 'package:flutter/foundation.dart';
import '../services/home_service.dart';
import '../../../core/services/persistence_service.dart';
import '../../../core/models/post_model.dart';
import '../../../core/models/weather_model.dart';
import '../../../core/services/locator.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/weather_service.dart';
import '../../../core/providers/base_provider.dart';

class HomeProvider extends BaseProvider {
  final _homeService = locator<HomeService>();
  final _weatherService = locator<WeatherService>();
  final _persistence = locator<PersistenceService>();

  List<PostModel> _posts = [];
  WeatherModel? _weatherData;

  List<PostModel> get posts => _posts;
  WeatherModel? get weatherData => _weatherData;

  Future<void> fetchWeather() async {
    await execute(() async {
      _weatherData = await _weatherService.getCurrentWeather();
      notifyListeners();
    }, showLoading: true, errorMessage: 'فشل في جلب بيانات الطقس');
  }



  Future<void> init() async {
    // Phase 1: Load Stale Data (Cache) for Instant UI
    await _loadCache();
    
    // Phase 2: Revalidate (Batch API Request)
    await execute(() async {
      // Fetch Weather and Batch Data in parallel
      final results = await Future.wait([
        _weatherService.getCurrentWeather(),
        _homeService.getHomeBatchData(),
      ]);

      _weatherData = results[0] as WeatherModel?;
      final batchData = results[1] as HomeBatchData;

      _posts = batchData.posts.take(2).toList();
      
      // Save to cache for next time
      _saveCache();
      
      notifyListeners();
    }, showLoading: _posts.isEmpty, errorMessage: 'فشل في تحديث بيانات الصفحة الرئيسية');
  }

  Future<void> _loadCache() async {
    try {
      final cachedPosts = await _persistence.get('offline_cache', 'home_posts');
      if (cachedPosts != null) {
        _posts = (cachedPosts as List).map((p) => PostModel.fromJson(p)).toList();
      }
      
      if (_posts.isNotEmpty) {
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Home cache load error: $e');
    }
  }

  void _saveCache() {
    try {
      _persistence.save('offline_cache', 'home_posts', _posts.map((p) => p.toJson()).toList());
    } catch (e) {
      debugPrint('Home cache save error: $e');
    }
  }

}
