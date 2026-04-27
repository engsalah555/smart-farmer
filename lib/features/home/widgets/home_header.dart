import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/fade_in_slide.dart';
import '../../../core/widgets/atoms/pro_max_icon_button.dart';
import '../../../core/models/weather_model.dart';
import '../../../core/widgets/digital_clock.dart';
import '../providers/home_provider.dart';
import '../../../core/widgets/animated_weather_icon.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.select<AuthProvider, dynamic>((p) => p.currentUser);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Fine-grained selection for HomeProvider data
    final weather = context.select<HomeProvider, WeatherModel?>(
      (p) => p.weatherData,
    );
    final isLoading = context.select<HomeProvider, bool>((p) => p.isLoading);
    final isNight = weather != null ? !weather.isDay : false;

    final userName = user?.name ?? 'ضيف';

    String userRole = 'مستخدم';
    if (user != null) {
      if (user.isSeller) {
        userRole = 'بائع';
      }
    }

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + context.hp(1),
        left: context.wp(6),
        right: context.wp(6),
        bottom: context.hp(2),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [AppColors.darkSurface, AppColors.darkBackground]
              : [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        border: isDark
            ? Border(
                bottom: BorderSide(color: AppColors.darkBorder, width: 1.5),
                left: BorderSide(color: AppColors.darkBorder, width: 1.5),
                right: BorderSide(color: AppColors.darkBorder, width: 1.5),
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: (isDark ? AppColors.black : AppColors.primary).withValues(
              alpha: 0.25,
            ),
            blurRadius: 25,
            offset: const Offset(0, 12),
            spreadRadius: -8,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FadeInSlide(
            duration: const Duration(milliseconds: 600),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Semantics(
                            label: 'اسم المستخدم: $userName',
                            child: Text(
                              'مرحباً , $userName',
                              style: TextStyle(
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.white,
                                fontSize: context.sp(20).clamp(18, 26),
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (user?.isVerified ?? false) ...[
                            SizedBox(width: context.wp(1.5)),
                            Icon(
                              Icons.verified,
                              color: isDark
                                  ? AppColors.darkAccent
                                  : AppColors.white,
                              size: context.sp(18).clamp(16, 22),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: context.hp(0.5)),
                      Text(
                        userRole,
                        style: TextStyle(
                          color:
                              (isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.white)
                                  .withValues(alpha: 0.9),
                          fontSize: context.sp(14).clamp(12, 18),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: context.wp(2)),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Semantics(
                      label: 'التنبيهات',
                      button: true,
                      child: ProMaxIconButton(
                        icon: Icons.notifications_none_rounded,
                        onTap: () => context.push('/notifications'),
                        size: context.wp(11).clamp(40, 55),
                        iconSize: context.wp(5.5).clamp(20, 26),
                        borderRadius: 22,
                        color: context.primary,
                        backgroundColor: isDark
                            ? AppColors.darkCard.withValues(alpha: 0.6)
                            : AppColors.white,
                      ),
                    ),
                    SizedBox(width: context.wp(2)),
                    Semantics(
                      label: 'المحاصيل',
                      button: true,
                      child: ProMaxIconButton(
                        icon: Icons.eco_outlined,
                        onTap: () => context.go('/crops'),
                        size: context.wp(11).clamp(40, 55),
                        iconSize: context.wp(5.5).clamp(20, 26),
                        borderRadius: 22,
                        color: context.primary,
                        backgroundColor: isDark
                            ? AppColors.darkCard.withValues(alpha: 0.6)
                            : AppColors.white,
                      ),
                    ),
                    SizedBox(width: context.wp(2)),
                    Semantics(
                      label: 'المساعد الذكي',
                      button: true,
                      child: ProMaxIconButton(
                        icon: Icons.smart_toy_outlined,
                        onTap: () => context.push('/chatbot'),
                        size: context.wp(11).clamp(40, 55),
                        iconSize: context.wp(5.5).clamp(20, 26),
                        borderRadius: 22,
                        color: context.primary,
                        backgroundColor: isDark
                            ? AppColors.darkCard.withValues(alpha: 0.6)
                            : AppColors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: context.hp(1.5)),
          FadeInSlide(
            delay: const Duration(milliseconds: 200),
            duration: const Duration(milliseconds: 600),
            child: Container(
              constraints: BoxConstraints(
                maxWidth: context.wp(90).clamp(300, 600),
              ),
              child: Stack(
                children: [
                  Semantics(
                    label: 'معلومات الطقس، اضغط للتحديث',
                    button: true,
                    child: GestureDetector(
                      onTap: () {
                        context.read<HomeProvider>().fetchWeather();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(seconds: 1),
                        padding: EdgeInsets.symmetric(
                          horizontal: context.wp(6),
                          vertical: context.hp(1.5),
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isNight
                                ? [
                                    const Color(
                                      0xFF1A237E,
                                    ).withValues(alpha: 0.8),
                                    const Color(
                                      0xFF0D1B2A,
                                    ).withValues(alpha: 0.9),
                                  ]
                                : [
                                    (isDark
                                            ? AppColors.darkCard
                                            : AppColors.white)
                                        .withValues(alpha: isDark ? 0.7 : 0.35),
                                    (isDark
                                            ? AppColors.darkBackground
                                            : AppColors.white)
                                        .withValues(alpha: isDark ? 0.8 : 0.2),
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: isNight
                                ? Colors.blueAccent.withValues(alpha: 0.4)
                                : (isDark
                                      ? AppColors.darkBorder
                                      : AppColors.white.withValues(alpha: 0.4)),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isNight
                                  ? Colors.blue.withValues(alpha: 0.15)
                                  : AppColors.black.withValues(alpha: 0.05),
                              blurRadius: 20,
                              spreadRadius: 2,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: isLoading
                            ? SizedBox(
                                height: context.hp(12),
                                child: Center(
                                  child: RepaintBoundary(
                                    child: CircularProgressIndicator(
                                      color: AppColors.white,
                                    ),
                                  ),
                                ),
                              )
                            : _buildWeatherInfo(context, weather, isNight),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherInfo(
    BuildContext context,
    WeatherModel? weather,
    bool isNight,
  ) {
    final String cityName = weather?.cityName ?? 'اضغط هنا لتحديث الطقس';
    final String tempString = weather != null
        ? '${weather.temperature.round()}°C'
        : '--°C';
    final String conditionString = weather?.conditionText ?? '---';
    final String humidityString = weather != null
        ? 'رطوبة ${weather.humidity}%'
        : 'رطوبة --%';
    final IconData weatherIcon = weather != null
        ? _getWeatherIcon(weather.weatherCode)
        : Icons.cloud_queue_rounded;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        weather == null
                            ? Icons.touch_app
                            : Icons.location_on_rounded,
                        color: AppColors.white,
                        size: context.sp(16).clamp(14, 20),
                      ),
                      SizedBox(width: context.wp(1.5)),
                      Expanded(
                        child: Text(
                          cityName,
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: context.sp(14).clamp(12, 18),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: context.hp(1)),
                  Text(
                    tempString,
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: context.sp(44).clamp(36, 56),
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                      shadows: [
                        Shadow(
                          color: isNight
                              ? Colors.blue
                              : AppColors.white.withValues(alpha: 0.5),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: context.hp(0.5)),
                  Text(
                    '$conditionString • $humidityString',
                    style: TextStyle(
                      color: AppColors.white.withValues(alpha: 0.95),
                      fontSize: context.sp(13).clamp(11, 16),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                const DigitalClock(),
                SizedBox(height: context.hp(1.5)),
                Semantics(
                  label: 'تقرير الطقس الكامل',
                  button: true,
                  child: GestureDetector(
                    onTap: () => context.push('/weather'),
                    child: Container(
                      padding: EdgeInsets.all(context.wp(3)),
                      decoration: BoxDecoration(
                        color: isNight
                            ? Colors.blue.withValues(alpha: 0.2)
                            : AppColors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isNight
                              ? Colors.blueAccent.withValues(alpha: 0.4)
                              : AppColors.white.withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                        boxShadow: [
                          if (isNight)
                            BoxShadow(
                              color: Colors.blue.withValues(alpha: 0.25),
                              blurRadius: 12,
                              spreadRadius: 1,
                              offset: const Offset(0, 2),
                            ),
                        ],
                      ),
                      child: weather != null
                          ? AnimatedWeatherIcon(
                              code: weather.weatherCode,
                              isDay: weather.isDay,
                              size: context.wp(12).clamp(40, 65),
                              color: AppColors.white,
                            )
                          : Icon(
                              weatherIcon,
                              color: AppColors.white,
                              size: context.wp(12).clamp(40, 65),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        if (weather != null) ...[
          SizedBox(height: context.hp(1.5)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                weather.relativeUpdateTime,
                style: TextStyle(
                  color: AppColors.white.withValues(alpha: 0.7),
                  fontSize: context.sp(11).clamp(10, 13),
                  fontWeight: FontWeight.w400,
                ),
              ),
              Semantics(
                label: 'عرض التقرير الكامل',
                button: true,
                child: GestureDetector(
                  onTap: () => context.push('/weather'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'تقرير كامل',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: context.sp(11).clamp(10, 13),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  IconData _getWeatherIcon(int code) {
    if (code == 0) return Icons.wb_sunny_rounded;
    if (code >= 1 && code <= 3) return Icons.cloud_queue_rounded;
    if (code >= 51 && code <= 65) return Icons.grain_rounded;
    if (code >= 71 && code <= 75) return Icons.ac_unit_rounded;
    if (code >= 80 && code <= 82) return Icons.umbrella_rounded;
    if (code >= 95) return Icons.thunderstorm_rounded;
    return Icons.cloud_rounded;
  }
}
