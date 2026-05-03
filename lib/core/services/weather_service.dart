import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../models/weather_model.dart';
import 'locator.dart';

class WeatherService {
  final Dio _dio = locator<Dio>();

  Future<WeatherModel?> getCurrentWeather() async {
    try {
      double lat, lon;
      String cityName = 'موقعي الحالي';

      LocationPermission permission = await Geolocator.checkPermission();
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (!serviceEnabled ||
          permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        // Fallback to Sana'a, Yemen if location is disabled or denied
        lat = 15.3694;
        lon = 44.1910;
        cityName = 'صنعاء، اليمن';
        debugPrint(
          'Using fallback location: Sanaa (serviceEnabled: $serviceEnabled, permission: $permission)',
        );
      } else {
        Position position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.low,
            distanceFilter: 100,
          ),
        );
        lat = position.latitude;
        lon = position.longitude;
      }

      // ─── اسم المدينة عبر Nominatim (only if not fallback) ─────────────────
      if (cityName == 'موقعي الحالي') {
        try {
          final geoResponse = await _dio.get(
            'https://nominatim.openstreetmap.org/reverse',
            queryParameters: {
              'lat': lat,
              'lon': lon,
              'format': 'json',
              'accept-language': 'ar',
            },
            options: Options(
              headers: {'User-Agent': 'Zarea-Agricultural-Assistant-App '},
              sendTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ),
          );
          if (geoResponse.data != null && geoResponse.data['address'] != null) {
            final address = geoResponse.data['address'];
            cityName =
                address['city'] ??
                address['town'] ??
                address['village'] ??
                address['suburb'] ??
                address['state'] ??
                'موقعي الحالي';
          }
        } catch (e) {
          debugPrint('Reverse geocoding failed: $e');
        }
      }

      // ─── بيانات الطقس الكاملة عبر Open-Meteo ──────────────────────────────
      final weatherResponse = await _dio.get(
        'https://api.open-meteo.com/v1/forecast',
        queryParameters: {
          'latitude': lat,
          'longitude': lon,
          'daily':
              'weather_code,temperature_2m_max,sunrise,sunset,sunshine_duration,'
              'daylight_duration,precipitation_probability_max,precipitation_hours,'
              'precipitation_sum,rain_sum,uv_index_clear_sky_max,wind_speed_10m_max',
          'hourly':
              'temperature_2m,relative_humidity_2m,dew_point_2m,apparent_temperature,'
              'precipitation_probability,weather_code,evapotranspiration,'
              'soil_temperature_6cm,precipitation,rain',
          'current':
              'temperature_2m,relative_humidity_2m,is_day,apparent_temperature,'
              'precipitation,rain,weather_code,cloud_cover,wind_speed_10m',
          'timezone': 'auto',
          'past_days': '0',
          'forecast_days': '7',
        },
      );

      if (weatherResponse.data == null) return null;
      final data = weatherResponse.data as Map<String, dynamic>;

      // ─── البيانات الحالية ─────────────────────────────────────────────────
      final current = data['current'] as Map<String, dynamic>? ?? {};
      final double temp =
          (current['temperature_2m'] as num?)?.toDouble() ?? 0.0;
      final int wCode = (current['weather_code'] as int?) ?? 0;
      final int hum = (current['relative_humidity_2m'] as int?) ?? 0;
      final double? appTemp = (current['apparent_temperature'] as num?)
          ?.toDouble();
      final double? precip = (current['precipitation'] as num?)?.toDouble();
      final double? rainCurrent = (current['rain'] as num?)?.toDouble();
      final int? cloud = current['cloud_cover'] as int?;
      final double? wind = (current['wind_speed_10m'] as num?)?.toDouble();
      final bool isDay = (current['is_day'] as int?) == 1;

      // ─── التوقعات اليومية ─────────────────────────────────────────────────
      final List<DailyForecast> daily = [];
      final dailyData = data['daily'] as Map<String, dynamic>? ?? {};
      final times = (dailyData['time'] as List?)?.cast<String>() ?? [];
      for (int i = 0; i < times.length; i++) {
        T? getVal<T>(String key) {
          final list = dailyData[key] as List?;
          if (list == null || i >= list.length) return null;
          final val = list[i];
          if (val == null) return null;
          if (T == double) return (val as num).toDouble() as T;
          return val as T?;
        }

        daily.add(
          DailyForecast(
            date: DateTime.parse(times[i]),
            weatherCode: getVal<int>('weather_code') ?? 0,
            tempMax: getVal<double>('temperature_2m_max') ?? 0.0,
            sunrise: getVal<String>('sunrise'),
            sunset: getVal<String>('sunset'),
            sunshineDuration: getVal<double>('sunshine_duration'),
            daylightDuration: getVal<double>('daylight_duration'),
            precipitationProbability: getVal<int>(
              'precipitation_probability_max',
            ),
            precipitationHours: getVal<double>('precipitation_hours'),
            precipitationSum: getVal<double>('precipitation_sum'),
            rainSum: getVal<double>('rain_sum'),
            uvIndexMax: getVal<double>('uv_index_clear_sky_max'),
            windSpeedMax: getVal<double>('wind_speed_10m_max'),
          ),
        );
      }

      // ─── البيانات الساعية (24 ساعة فقط) ──────────────────────────────────
      final List<HourlyData> hourly = [];
      final hourlyRaw = data['hourly'] as Map<String, dynamic>? ?? {};
      final hTimes = (hourlyRaw['time'] as List?)?.cast<String>() ?? [];
      final now = DateTime.now();
      int count = 0;
      for (int i = 0; i < hTimes.length && count < 24; i++) {
        final t = DateTime.parse(hTimes[i]);
        if (t.isBefore(now.subtract(const Duration(hours: 1)))) continue;

        T2? hget<T2>(String key) {
          final list = hourlyRaw[key] as List?;
          if (list == null || i >= list.length) return null;
          final val = list[i];
          if (val == null) return null;
          if (T2 == double) return (val as num).toDouble() as T2;
          return val as T2?;
        }

        hourly.add(
          HourlyData(
            time: t,
            temperature: hget<double>('temperature_2m') ?? 0.0,
            humidity: hget<int>('relative_humidity_2m') ?? 0,
            dewPoint: hget<double>('dew_point_2m'),
            apparentTemperature: hget<double>('apparent_temperature'),
            precipitationProbability: hget<int>('precipitation_probability'),
            weatherCode: hget<int>('weather_code') ?? 0,
            evapotranspiration: hget<double>('evapotranspiration'),
            soilTemperature: hget<double>('soil_temperature_6cm'),
            precipitation: hget<double>('precipitation'),
            rain: hget<double>('rain'),
          ),
        );
        count++;
      }

      return WeatherModel(
        temperature: temp,
        weatherCode: wCode,
        cityName: cityName,
        humidity: hum,
        lastUpdated: DateTime.now(),
        apparentTemperature: appTemp,
        precipitation: precip,
        rain: rainCurrent,
        cloudCover: cloud,
        windSpeed: wind,
        isDay: isDay,
        dailyForecasts: daily,
        hourlyData: hourly,
      );
    } catch (e) {
      debugPrint('Weather fetch error: $e');
      return null;
    }
  }
}
