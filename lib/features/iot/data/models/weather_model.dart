import '../../../../core/utils/formatters.dart';

/// نموذج بيانات الطقس الكامل من Open-Meteo
class WeatherModel {
  // ─── البيانات الحالية ───────────────────────────────────────────────────────
  final double temperature;
  final int weatherCode;
  final String cityName;
  final int humidity;
  final double? apparentTemperature;
  final double? precipitation;
  final double? rain;
  final int? cloudCover;
  final double? windSpeed;
  final bool isDay;

  // ─── التوقعات اليومية (7 أيام) ────────────────────────────────────────────
  final List<DailyForecast> dailyForecasts;

  // ─── البيانات الساعية ─────────────────────────────────────────────────────
  final List<HourlyData> hourlyData;

  final DateTime lastUpdated;

  const WeatherModel({
    required this.temperature,
    required this.weatherCode,
    required this.cityName,
    required this.humidity,
    required this.lastUpdated,
    this.apparentTemperature,
    this.precipitation,
    this.rain,
    this.cloudCover,
    this.windSpeed,
    this.isDay = true,
    this.dailyForecasts = const [],
    this.hourlyData = const [],
  });

  /// وصف حالة الطقس بالعربية
  String get conditionText {
    switch (weatherCode) {
      case 0:
        return 'صافٍ';
      case 1:
      case 2:
      case 3:
        return 'غائم جزئياً';
      case 45:
      case 48:
        return 'ضباب';
      case 51:
      case 53:
      case 55:
        return 'رذاذ خفيف';
      case 61:
      case 63:
      case 65:
        return 'ممطر';
      case 71:
      case 73:
      case 75:
        return 'ثلوج';
      case 80:
      case 81:
      case 82:
        return 'أمطار غزيرة';
      case 95:
        return 'عواصف رعدية';
      case 96:
      case 99:
        return 'عواصف مع برَد';
      default:
        return 'غير معروف';
    }
  }
  /// الوقت منذ آخر تحديث بالعربية
  String get relativeUpdateTime {
    return DateFormatter.formatRelative(lastUpdated);
  }
}

/// توقع يومي واحد
class DailyForecast {
  final DateTime date;
  final int weatherCode;
  final double tempMax;
  final String? sunrise;
  final String? sunset;
  final double? sunshineDuration; // ثواني
  final double? daylightDuration; // ثواني
  final int? precipitationProbability;
  final double? precipitationHours;
  final double? precipitationSum;
  final double? rainSum;
  final double? uvIndexMax;
  final double? windSpeedMax;

  const DailyForecast({
    required this.date,
    required this.weatherCode,
    required this.tempMax,
    this.sunrise,
    this.sunset,
    this.sunshineDuration,
    this.daylightDuration,
    this.precipitationProbability,
    this.precipitationHours,
    this.precipitationSum,
    this.rainSum,
    this.uvIndexMax,
    this.windSpeedMax,
  });

  /// وصف حالة الطقس باختصار
  String get conditionText {
    switch (weatherCode) {
      case 0:
        return 'صافٍ';
      case 1:
      case 2:
      case 3:
        return 'غائم جزئياً';
      case 45:
      case 48:
        return 'ضباب';
      case 51:
      case 53:
      case 55:
        return 'رذاذ';
      case 61:
      case 63:
      case 65:
        return 'مطر';
      case 71:
      case 73:
      case 75:
        return 'ثلوج';
      case 80:
      case 81:
      case 82:
        return 'أمطار غزيرة';
      case 95:
      case 96:
      case 99:
        return 'عواصف';
      default:
        return 'غير محدد';
    }
  }

  /// اسم اليوم بالعربية
  String get dayName {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final forecastDate = DateTime(date.year, date.month, date.day);
    
    if (forecastDate == today) return 'اليوم';
    if (forecastDate == today.add(const Duration(days: 1))) return 'غداً';

    const days = [
      'الإثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];
    return days[date.weekday - 1];
  }

  /// اليوم والشهر بالأرقام
  String get dateLabel {
    final months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  /// مدة سطوع الشمس بالساعات
  double? get sunshineDurationHours =>
      sunshineDuration != null ? sunshineDuration! / 3600 : null;

  /// مدة النهار بالساعات
  double? get daylightDurationHours =>
      daylightDuration != null ? daylightDuration! / 3600 : null;

  /// وقت الشروق بتنسيق 12 ساعة عربي
  String get sunriseLabel {
    if (sunrise == null) return '--:--';
    try {
      final dt = DateTime.parse(sunrise!);
      final h = dt.hour;
      final m = dt.minute.toString().padLeft(2, '0');
      if (h == 0) return '12:$m ص';
      if (h < 12) return '$h:$m ص';
      if (h == 12) return '12:$m م';
      return '${h - 12}:$m م';
    } catch (_) {
      return '--:--';
    }
  }

  /// وقت الغروب بتنسيق 12 ساعة عربي
  String get sunsetLabel {
    if (sunset == null) return '--:--';
    try {
      final dt = DateTime.parse(sunset!);
      final h = dt.hour;
      final m = dt.minute.toString().padLeft(2, '0');
      if (h == 0) return '12:$m ص';
      if (h < 12) return '$h:$m ص';
      if (h == 12) return '12:$m م';
      return '${h - 12}:$m م';
    } catch (_) {
      return '--:--';
    }
  }
}

/// بيانات ساعية واحدة
class HourlyData {
  final DateTime time;
  final double temperature;
  final int humidity;
  final double? dewPoint;
  final double? apparentTemperature;
  final int? precipitationProbability;
  final int weatherCode;
  final double? evapotranspiration;
  final double? soilTemperature;
  final double? precipitation;
  final double? rain;

  const HourlyData({
    required this.time,
    required this.temperature,
    required this.humidity,
    this.dewPoint,
    this.apparentTemperature,
    this.precipitationProbability,
    required this.weatherCode,
    this.evapotranspiration,
    this.soilTemperature,
    this.precipitation,
    this.rain,
  });

  /// الساعة بتنسيق عربي (12-ساعة)
  String get hourLabel {
    final now = DateTime.now();
    
    // إذا كانت الساعة الحالية
    if (time.hour == now.hour && 
        time.day == now.day && 
        time.month == now.month && 
        time.year == now.year) {
      return 'الآن';
    }

    // إذا كانت بداية اليوم التالي
    if (time.hour == 0 && time.isAfter(now)) {
      return 'غداً';
    }

    final h = time.hour;
    if (h == 0) return '12 ص';
    if (h < 12) return '$h ص';
    if (h == 12) return '12 م';
    return '${h - 12} م';
  }
}
