import 'package:flutter/foundation.dart';
import '../services/home_service.dart';
import '../../../core/services/persistence_service.dart';
import '../../../core/models/post_model.dart';
import '../../../core/models/weather_model.dart';
import '../../../core/services/locator.dart';
import '../../../core/services/weather_service.dart';
import '../../../core/providers/base_provider.dart';

class HomeProvider extends BaseProvider {
  final _homeService = locator<HomeService>();
  final _weatherService = locator<WeatherService>();
  final _persistence = locator<PersistenceService>();

  List<PostModel> _posts = [];
  WeatherModel? _weatherData;
  bool _isWeatherLoading = false;

  List<PostModel> get posts => _posts;
  WeatherModel? get weatherData => _weatherData;
  bool get isWeatherLoading => _isWeatherLoading;

  Future<void> fetchWeather({bool showLoading = true}) async {
    if (showLoading) {
      _isWeatherLoading = true;
      notifyListeners();
    }

    try {
      final weather = await _weatherService.getCurrentWeather();
      if (weather != null) {
        _weatherData = weather;
        _saveCache();
      }
    } catch (e) {
      debugPrint('Home weather fetch error: $e');
    } finally {
      if (showLoading) {
        _isWeatherLoading = false;
      }
      notifyListeners();
    }
  }

  Future<void> init() async {
    // Phase 1: Load Stale Data (Cache) for Instant UI
    await _loadCache();

    // Phase 2: Revalidate concurrently without blocking each other
    await Future.wait([
      _loadPosts(),
      fetchWeather(showLoading: _weatherData == null),
    ]);
  }

  Future<void> _loadPosts() async {
    await execute(
      () async {
        final batchData = await _homeService.getHomeBatchData();
        _posts = batchData.posts.take(2).toList();
        _saveCache();
        notifyListeners();
      },
      showLoading: _posts.isEmpty,
      errorMessage: 'فشل في تحديث بيانات الصفحة الرئيسية',
    );
  }

  Future<void> _loadCache() async {
    try {
      final cachedPosts = await _persistence.get('offline_cache', 'home_posts');
      if (cachedPosts != null) {
        _posts = (cachedPosts as List)
            .map((p) => PostModel.fromJson(Map<String, dynamic>.from(p)))
            .toList();
      }

      final cachedWeather =
          await _persistence.get('offline_cache', 'home_weather');
      if (cachedWeather != null) {
        _weatherData = WeatherModel.fromJson(
          Map<String, dynamic>.from(cachedWeather as Map),
        );
      }

      if (_posts.isNotEmpty || _weatherData != null) {
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Home cache load error: $e');
    }
  }

  void _saveCache() {
    try {
      _persistence.save(
        'offline_cache',
        'home_posts',
        _posts.map((p) => p.toJson()).toList(),
      );

      if (_weatherData != null) {
        _persistence.save(
          'offline_cache',
          'home_weather',
          _weatherData!.toJson(),
        );
      }
    } catch (e) {
      debugPrint('Home cache save error: $e');
    }
  }
}
