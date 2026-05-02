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

    final userName = (user?.name?.split(' ').first) ?? 'ضيف';

    String userRole = 'مستخدم';
    if (user != null) {
      if (user.customTitle != null && user.customTitle!.isNotEmpty) {
        userRole = user.customTitle!;
      } else if (user.isSeller) {
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
          colors: [context.primary, context.primary.withValues(alpha: 0.8)],
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
            color: (isDark ? AppColors.black : context.primary).withValues(
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
                                  ? AppColors.primaryDark
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
                          color: context.white,
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
                        iconSize: context.wp(5.5).clamp(24, 28),
                        color: context.textPrimary,
                        backgroundColor: context.cardBackground,
                      ),
                    ),
                    SizedBox(width: context.wp(2)),
                    Semantics(
                      label: 'المساعد الذكي',
                      button: true,
                      child: ProMaxIconButton(
                        icon: Icons.smart_toy_outlined,
                        onTap: () => context.push('/chatbot'),
                        iconSize: context.wp(5.5).clamp(24, 28),
                        color: context.textPrimary,
                        backgroundColor: context.cardBackground,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: context.hp(2)),
          FadeInSlide(
            delay: const Duration(milliseconds: 200),
            duration: const Duration(milliseconds: 600),
            child: Container(
              constraints: BoxConstraints(
                maxWidth: context.wp(90).clamp(300, 600),
              ),
              padding: EdgeInsets.symmetric(horizontal: context.wp(2)),
              child: isLoading
                  ? SizedBox(
                      height: context.hp(12),
                      child: const Center(
                        child: RepaintBoundary(
                          child: CircularProgressIndicator(
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    )
                  : _buildWeatherInfo(context, weather),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherInfo(BuildContext context, WeatherModel? weather) {
    final String cityName = weather?.cityName ?? 'غير متوفر';
    final String tempString = weather != null
        ? '${weather.temperature.round()}°'
        : '--°';
    final String conditionString = weather?.conditionText ?? '---';
    final String humidityString = weather != null
        ? 'رطوبة ${weather.humidity}%'
        : 'رطوبة --%';

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        color: AppColors.white.withValues(alpha: 0.9),
                        size: context.sp(16).clamp(14, 18),
                      ),
                      SizedBox(width: context.wp(1)),
                      Text(
                        cityName,
                        style: TextStyle(
                          color: AppColors.white.withValues(alpha: 0.9),
                          fontSize: context.sp(14).clamp(12, 16),
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  SizedBox(height: context.hp(1)),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        tempString,
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: context.sp(36).clamp(28, 48),
                          fontWeight: FontWeight.w700,
                          height: 1.0,
                        ),
                      ),
                      SizedBox(width: context.wp(2)),
                      Padding(
                        padding: EdgeInsets.only(bottom: context.hp(0.5)),
                        child: Text(
                          conditionString,
                          style: TextStyle(
                            color: AppColors.white.withValues(alpha: 0.9),
                            fontSize: context.sp(16).clamp(14, 20),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: context.hp(1)),
                  Row(
                    children: [
                      Icon(
                        Icons.water_drop_outlined,
                        color: AppColors.white.withValues(alpha: 0.8),
                        size: 14,
                      ),
                      SizedBox(width: 4),
                      Text(
                        humidityString,
                        style: TextStyle(
                          color: AppColors.white.withValues(alpha: 0.8),
                          fontSize: context.sp(13).clamp(11, 14),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (weather != null) ...[
                        SizedBox(width: context.wp(3)),
                        Icon(
                          Icons.access_time_rounded,
                          color: AppColors.white.withValues(alpha: 0.8),
                          size: 14,
                        ),
                        SizedBox(width: 4),
                        Text(
                          weather.relativeUpdateTime,
                          style: TextStyle(
                            color: AppColors.white.withValues(alpha: 0.8),
                            fontSize: context.sp(13).clamp(11, 14),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                DefaultTextStyle(
                  style: const TextStyle(color: AppColors.white),
                  child: const DigitalClock(),
                ),
                SizedBox(height: context.hp(2)),
                if (weather != null)
                  AnimatedWeatherIcon(
                    code: weather.weatherCode,
                    isDay: weather.isDay,
                    size: context.wp(10).clamp(36, 50),
                    color: AppColors.white,
                  )
                else
                  Icon(
                    Icons.cloud_queue_rounded,
                    color: AppColors.white,
                    size: context.wp(10).clamp(36, 50),
                  ),
              ],
            ),
          ],
        ),
        SizedBox(height: context.hp(2.5)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Semantics(
              label: 'تحديث بيانات الطقس',
              button: true,
              child: TextButton.icon(
                onPressed: () => context.read<HomeProvider>().fetchWeather(),
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: const Text('تحديث'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.white,
                  backgroundColor: AppColors.white.withValues(alpha: 0.1),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  minimumSize: const Size(88, 44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            Semantics(
              label: 'عرض تقرير الطقس الكامل',
              button: true,
              child: FilledButton.icon(
                onPressed: () => context.push('/weather'),
                icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                label: const Text('تقرير كامل'),
                style: FilledButton.styleFrom(
                  foregroundColor: context.primary,
                  backgroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  minimumSize: const Size(88, 44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
