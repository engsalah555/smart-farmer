import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/constants.dart';
import '../../../core/models/weather_model.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/digital_clock.dart';
import '../../../core/widgets/animated_weather_icon.dart';
import '../providers/home_provider.dart';

/// بطاقة الطقس والمناخ الذكية الفائقة بتصميم أخضر رئيسي فاخر (Green Hero Card)
/// تضم كافة بيانات الطقس والمناخ مع استغلال اللون الأخضر الزراعي المشرق والتباين الفائق
class HomeClimateCard extends StatelessWidget {
  const HomeClimateCard({super.key});

  @override
  Widget build(BuildContext context) {
    final weather = context.select<HomeProvider, WeatherModel?>(
      (p) => p.weatherData,
    );
    final isLoading = context.select<HomeProvider, bool>(
      (p) => p.isWeatherLoading,
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (weather == null && isLoading) {
      return _buildLoadingSkeleton(context, isDark);
    }

    // تدرج لوني أخضر رئيسي فاخر وغني يتكيف بتألق في المظهرين الداكن والفاتح
    final gradientColors = isDark
        ? const [
            Color(0xFF1E6038), // أخضر زمردي غني
            Color(0xFF144527), // أخضر عميق
            Color(0xFF0C2E19), // أخضر غابي ملكي
          ]
        : const [
            Color(0xFF2E8B4E), // أخضر مورق نضر
            Color(0xFF236E3C), // أخضر رئيسي
            Color(0xFF19542D), // أخضر نضر عميق
          ];

    const textColor = Colors.white;
    const subTextColor = Color(0xFFE8F2E9);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.wp(4.5).clamp(16.0, 24.0),
      ),
      child: Semantics(
        label: 'بطاقة الطقس والمناخ الحقلي. اضغط لعرض التقرير الكامل.',
        button: true,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              context.push('/weather');
            },
            borderRadius: BorderRadius.circular(28),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradientColors,
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: const Color(0xFF2ECC71).withValues(alpha: isDark ? 0.45 : 0.35),
                  width: 1.5,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(context.wp(4.5).clamp(16.0, 22.0)),
                child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ─── 1. الصف العلوي: الموقع ووقت التحديث والساعة ─────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.18),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.location_on_rounded,
                                    color: Colors.white,
                                    size: 15,
                                  ),
                                ),
                                const SizedBox(width: 7),
                                Text(
                                  weather?.cityName ?? 'موقعي الزراعي',
                                  style: TextStyle(
                                    fontSize: context.sp(13).clamp(12, 15),
                                    fontWeight: FontWeight.w700,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 4,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: subTextColor.withValues(alpha: 0.5),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  weather?.relativeUpdateTime ?? 'مباشر',
                                  style: TextStyle(
                                    fontSize: context.sp(11).clamp(10, 12),
                                    color: subTextColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),

                            // الساعة الرقمية المحسنة
                            const DigitalClock(
                              fontSize: 12,
                              color: Colors.white,
                              showIcon: true,
                            ),
                          ],
                        ),

                        SizedBox(height: context.hp(1.8)),

                        // ─── 2. القراءة المركزية: درجة الحرارة والأيقونة والوصف ──
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      weather != null
                                          ? '${weather.temperature.round()}'
                                          : '--',
                                      style: TextStyle(
                                        fontSize: context.sp(46).clamp(38, 56),
                                        fontWeight: FontWeight.w900,
                                        color: textColor,
                                        height: 1.0,
                                        letterSpacing: -1.0,
                                      ),
                                    ),
                                    Text(
                                      '°C',
                                      style: TextStyle(
                                        fontSize: context.sp(18).clamp(16, 22),
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF76C748),
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      weather?.conditionText ?? 'معلومات المناخ',
                                      style: TextStyle(
                                        fontSize: context.sp(15).clamp(13, 17),
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                                    if (weather?.apparentTemperature != null) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        width: 3,
                                        height: 3,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: subTextColor.withValues(alpha: 0.6),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'يبدو مثل ${weather!.apparentTemperature!.round()}°',
                                        style: TextStyle(
                                          fontSize: context.sp(12).clamp(11, 14),
                                          color: subTextColor.withValues(alpha: 0.85),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),

                            // الأيقونة المتحركة لحالة الطقس
                            if (weather != null)
                              AnimatedWeatherIcon(
                                code: weather.weatherCode,
                                isDay: weather.isDay,
                                size: context.wp(14).clamp(48.0, 62.0),
                              )
                            else
                              const Icon(
                                Icons.cloud_outlined,
                                size: 54,
                                color: Colors.white,
                              ),
                          ],
                        ),

                        SizedBox(height: context.hp(1.8)),

                        // ─── 3. كبسولة الإرشاد الزراعي الذكي ──────────────────
                        _buildAgronomicAdviceBadge(context, weather, isDark),

                        SizedBox(height: context.hp(1.6)),

                        // ─── 4. شريط المؤشرات المصغرة (رطوبة، رياح، أمطار) ─────
                        Row(
                          children: [
                            Expanded(
                              child: _buildMicroMetric(
                                context,
                                icon: Icons.water_drop_rounded,
                                label: 'الرطوبة',
                                value: weather?.humidity != null
                                    ? '${weather!.humidity}%'
                                    : '--',
                                isDark: isDark,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildMicroMetric(
                                context,
                                icon: Icons.air_rounded,
                                label: 'الرياح',
                                value: weather?.windSpeed != null
                                    ? '${weather!.windSpeed!.toStringAsFixed(1)} كم/س'
                                    : '--',
                                isDark: isDark,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildMicroMetric(
                                context,
                                icon: Icons.grain_rounded,
                                label: 'الأمطار',
                                value: _formatRain(weather),
                                isDark: isDark,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: context.hp(1.6)),

                        // ─── 5. أزرار التحكم بالطقس (تحديث + تقرير كامل) ───────
                        Row(
                          children: [
                            // زر تحديث الطقس (Secondary Frosted Button)
                            Expanded(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    context.read<HomeProvider>().fetchWeather();
                                  },
                                  borderRadius: BorderRadius.circular(14),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.16),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.32),
                                        width: 1.2,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.refresh_rounded,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'تحديث',
                                          style: TextStyle(
                                            fontSize: context.sp(12).clamp(11, 14),
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            // زر تقرير كامل (Primary Solid White CTA)
                            Expanded(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    context.push('/weather');
                                  },
                                  borderRadius: BorderRadius.circular(14),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.arrow_forward_rounded,
                                          size: 16,
                                          color: Color(0xFF144527),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'تقرير كامل',
                                          style: TextStyle(
                                            fontSize: context.sp(12).clamp(11, 14),
                                            fontWeight: FontWeight.w900,
                                            color: const Color(0xFF144527),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatRain(WeatherModel? weather) {
    if (weather == null) return '--';
    final rain = weather.rain ?? weather.precipitation ?? 0.0;
    return '${rain.toStringAsFixed(1)} مم';
  }

  /// كبسولة النصيحة الزراعية المخصصة حسب بيانات المناخ الحالية
  Widget _buildAgronomicAdviceBadge(
    BuildContext context,
    WeatherModel? weather,
    bool isDark,
  ) {
    String adviceText = 'الظروف الجوية ملائمة للري والتسميد والعمليات الحقلية';
    IconData adviceIcon = Icons.eco_rounded;
    Color accentColor = const Color(0xFF76C748);

    if (weather != null) {
      final rain = weather.rain ?? weather.precipitation ?? 0.0;
      final wind = weather.windSpeed ?? 0.0;
      final temp = weather.temperature;

      if (rain > 1.0) {
        adviceText = 'توقعات هطول أمطار: خفف أو أوقف الري اليوم لتفادي تشبع الجذور';
        adviceIcon = Icons.water_damage_outlined;
        accentColor = AppColors.info;
      } else if (wind > 20.0) {
        adviceText =
            'نشاط رياح (${wind.round()} كم/س): تجنب رش المبيدات والأسمدة الورقية حالياً';
        adviceIcon = Icons.warning_amber_rounded;
        accentColor = AppColors.warning;
      } else if (temp > 35.0) {
        adviceText = 'حرارة مرتفعة: يُفضل الري في الصباح الباكر أو بعد الغروب';
        adviceIcon = Icons.wb_sunny_outlined;
        accentColor = AppColors.warning;
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            adviceIcon,
            color: accentColor,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              adviceText,
              style: TextStyle(
                fontSize: context.sp(11).clamp(10, 13),
                fontWeight: FontWeight.w600,
                color: Colors.white,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// خلية مؤشر مصغر
  Widget _buildMicroMetric(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.22),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: Colors.white,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: context.sp(9).clamp(9, 11),
                    color: const Color(0xFFE8F2E9).withValues(alpha: 0.90),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                ),
                const SizedBox(height: 1),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: context.sp(12).clamp(11, 14),
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSkeleton(BuildContext context, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.wp(4.5).clamp(16.0, 24.0),
      ),
      child: Shimmer.fromColors(
        baseColor: isDark ? AppColors.shimmerBaseDark : AppColors.shimmerBaseLight,
        highlightColor: isDark
            ? AppColors.shimmerHighlightDark
            : AppColors.shimmerHighlightLight,
        child: Container(
          height: 190,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
        ),
      ),
    );
  }
}
