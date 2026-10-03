import 'package:flutter_test/flutter_test.dart';
import 'package:smart_farm2/core/models/weather_model.dart';

void main() {
  test('WeatherModel toJson and fromJson work correctly', () {
    final now = DateTime.now();
    final weather = WeatherModel(
      temperature: 24.5,
      weatherCode: 1,
      cityName: 'صنعاء، اليمن',
      humidity: 45,
      lastUpdated: now,
      apparentTemperature: 23.0,
      precipitation: 0.0,
      rain: 0.0,
      cloudCover: 10,
      windSpeed: 5.2,
      isDay: true,
      dailyForecasts: [
        DailyForecast(
          date: now,
          weatherCode: 1,
          tempMax: 26.0,
          sunrise: '2026-10-04T05:45:00',
          sunset: '2026-10-04T17:45:00',
        ),
      ],
      hourlyData: [
        HourlyData(
          time: now,
          temperature: 24.5,
          humidity: 45,
          weatherCode: 1,
        ),
      ],
    );

    final json = weather.toJson();
    final deserialized = WeatherModel.fromJson(json);

    expect(deserialized.temperature, 24.5);
    expect(deserialized.cityName, 'صنعاء، اليمن');
    expect(deserialized.weatherCode, 1);
    expect(deserialized.humidity, 45);
    expect(deserialized.dailyForecasts.length, 1);
    expect(deserialized.dailyForecasts.first.tempMax, 26.0);
    expect(deserialized.hourlyData.length, 1);
    expect(deserialized.hourlyData.first.temperature, 24.5);
  });
}
