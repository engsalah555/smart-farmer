import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/models/weather_model.dart';
import '../../../core/constants.dart';
import '../../../core/widgets/digital_clock.dart';
import '../../../core/widgets/animated_weather_icon.dart';
import '../providers/home_provider.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// شاشة تفاصيل الطقس الكاملة
/// تعرض: البيانات الحالية • التوقعات الساعية • التوقعات 7 أيام
/// ─────────────────────────────────────────────────────────────────────────────
class WeatherDetailScreen extends StatefulWidget {
  const WeatherDetailScreen({super.key});

  @override
  State<WeatherDetailScreen> createState() => _WeatherDetailScreenState();
}

class _WeatherDetailScreenState extends State<WeatherDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, provider, _) {
        final weather = provider.weatherData;
        final isLoading = provider.isLoading;

        return Scaffold(
          body: isLoading
              ? const Center(
                  child: CircularProgressIndicator())
              : weather == null
                  ? _buildEmpty(context, provider)
                  : _buildContent(context, weather, provider),
        );
      },
    );
  }

  // ─── حالة فارغة ─────────────────────────────────────────────────────────────
  Widget _buildEmpty(BuildContext context, HomeProvider provider) {
    return SafeArea(
      child: Column(
        children: [
          _AppBarRow(title: 'تفاصيل الطقس'),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off_rounded,
                      color: Colors.white54, size: 64),
                  const SizedBox(height: 16),
                  const Text('لا توجد بيانات طقس',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                          fontFamily: 'Cairo')),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => provider.fetchWeather(),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('تحديث',
                        style: TextStyle(fontFamily: 'Cairo')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
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

  // ─── المحتوى الرئيسي ─────────────────────────────────────────────────────────
  Widget _buildContent(
      BuildContext context, WeatherModel weather, HomeProvider provider) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: weather.isDay
              ? [AppColors.accent, AppColors.primary, AppColors.primaryDeep]
              : [AppColors.primaryDark, AppColors.darkSurface, AppColors.darkBackground],
        ),
      ),
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: innerBoxIsScrolled 
                  ? (weather.isDay ? AppColors.primary : AppColors.darkSurface).withValues(alpha: 0.95)
                  : Colors.transparent,
              elevation: innerBoxIsScrolled ? 8 : 0,
              pinned: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text(
                weather.cityName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Cairo',
                ),
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, color: Colors.white70, size: 22),
                  onPressed: () => provider.fetchWeather(),
                ),
                const Center(child: DigitalClock()),
                const SizedBox(width: 16),
              ],
            ),
            SliverToBoxAdapter(
              child: _WeatherHeroSection(weather: weather),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.white,
                  indicatorWeight: 3,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white38,
                  labelStyle: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  tabs: const [
                    Tab(text: 'بالساعة'),
                    Tab(text: '7 أيام'),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _HourlyTab(hourlyData: weather.hourlyData),
            _DailyTab(
              dailyForecasts: weather.dailyForecasts,
              currentWeather: weather,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// قسم البطولة العلوية (Hero)
// ─────────────────────────────────────────────────────────────────────────────
class _WeatherHeroSection extends StatelessWidget {
  const _WeatherHeroSection({
    required this.weather,
  });

  final WeatherModel weather;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.transparent,
      child: Column(
        children: [
          // ── درجة الحرارة الرئيسية ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // النص
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${weather.temperature.round()}°C',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 72,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Cairo',
                        height: 1,
                        shadows: [
                          Shadow(
                            color: weather.isDay ? Colors.white.withValues(alpha: 0.5) : Colors.blue,
                            blurRadius: 20,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      weather.conditionText,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (weather.apparentTemperature != null)
                      Text(
                        'الإحساس: ${weather.apparentTemperature!.round()}°C',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 14,
                          fontFamily: 'Cairo',
                        ),
                      ),
                  ],
                ),

                RepaintBoundary(
                  child: AnimatedWeatherIcon(
                      code: weather.weatherCode, isDay: weather.isDay, size: 80),
                ),
              ],
            ),
          ),

          // ── بطاقات البيانات السريعة ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            child: Row(
              children: [
                _QuickStat(
                    icon: Icons.water_drop_rounded,
                    label: 'الرطوبة',
                    value: '${weather.humidity}%'),
                _QuickStat(
                    icon: Icons.air_rounded,
                    label: 'الرياح',
                    value: weather.windSpeed != null
                        ? '${weather.windSpeed!.round()} km/h'
                        : '--'),
                _QuickStat(
                    icon: Icons.cloud_rounded,
                    label: 'الغيوم',
                    value: weather.cloudCover != null
                        ? '${weather.cloudCover}%'
                        : '--'),
                _QuickStat(
                    icon: Icons.umbrella_rounded,
                    label: 'الأمطار',
                    value: weather.rain != null
                        ? '${weather.rain!.toStringAsFixed(1)} مم'
                        : '0 مم'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// تبويب الساعي
// ─────────────────────────────────────────────────────────────────────────────
class _HourlyTab extends StatefulWidget {
  const _HourlyTab({required this.hourlyData});
  final List<HourlyData> hourlyData;

  @override
  State<_HourlyTab> createState() => _HourlyTabState();
}

class _HourlyTabState extends State<_HourlyTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (widget.hourlyData.isEmpty) {
      return const Center(
        child: Text('لا توجد بيانات ساعية',
            style: TextStyle(color: Colors.white54, fontFamily: 'Cairo')),
      );
    }

    return ListView.builder(
      key: const PageStorageKey<String>('hourly_tab'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: widget.hourlyData.length,
      itemExtent: 64, // تحسين الأداء (أفضل من ListView.separated)
      itemBuilder: (context, i) => _HourlyCard(data: widget.hourlyData[i]),
    );
  }
}

class _HourlyCard extends StatelessWidget {
  const _HourlyCard({required this.data});
  final HourlyData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white12, width: 1)),
      ),
      child: Row(
        children: [
          // الوقت
          SizedBox(
            width: 54,
            child: Text(
              data.hourLabel,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(width: 10),

          RepaintBoundary(
            child: AnimatedWeatherIcon(code: data.weatherCode, isDay: true, size: 28),
          ),

          const SizedBox(width: 12),

          // درجة الحرارة
          Text(
            '${data.temperature.round()}°',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: 'Cairo',
            ),
          ),

          const SizedBox(width: 8),

          // الإحساس
          if (data.apparentTemperature != null)
            Text(
              'إحساس ${data.apparentTemperature!.round()}°',
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 12,
                fontFamily: 'Cairo',
              ),
            ),

          const Spacer(),

          // الرطوبة
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.water_drop_rounded,
                  color: Colors.blue, size: 14),
              const SizedBox(width: 3),
              Text(
                '${data.humidity}%',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),

          const SizedBox(width: 10),

          // احتمالية المطر
          if (data.precipitationProbability != null)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.umbrella_rounded,
                    color: Colors.lightBlueAccent, size: 14),
                const SizedBox(width: 3),
                Text(
                  '${data.precipitationProbability}%',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// تبويب 7 أيام
// ─────────────────────────────────────────────────────────────────────────────
class _DailyTab extends StatefulWidget {
  const _DailyTab(
      {required this.dailyForecasts, required this.currentWeather});
  final List<DailyForecast> dailyForecasts;
  final WeatherModel currentWeather;

  @override
  State<_DailyTab> createState() => _DailyTabState();
}

class _DailyTabState extends State<_DailyTab> with AutomaticKeepAliveClientMixin {
  int _selectedIndex = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (widget.dailyForecasts.isEmpty) {
      return const Center(
        child: Text('لا توجد توقعات يومية',
            style: TextStyle(color: Colors.white54, fontFamily: 'Cairo')),
      );
    }

    return CustomScrollView(
      key: const PageStorageKey<String>('daily_tab'),
      slivers: [
        // ─── قائمة الأيام ──────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: SizedBox(
            height: 105,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              scrollDirection: Axis.horizontal,
              itemCount: widget.dailyForecasts.length,
              itemBuilder: (context, i) {
                final day = widget.dailyForecasts[i];
                final isSelected = i == _selectedIndex;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIndex = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: isSelected
                          ? null
                          : Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          day.dayName,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : Colors.white70,
                            fontSize: 12,
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        RepaintBoundary(
                          child: AnimatedWeatherIcon(
                              code: day.weatherCode, isDay: true, size: 22),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${day.tempMax.round()}°',
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white54,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // ─── تفاصيل اليوم المختار ──────────────────────────────────────────
        SliverToBoxAdapter(
          child: _DayDetailCard(
              day: widget.dailyForecasts[_selectedIndex],
              isToday: _selectedIndex == 0),
        ),
      ],
    );
  }
}

class _DayDetailCard extends StatelessWidget {
  const _DayDetailCard({required this.day, required this.isToday});
  final DailyForecast day;
  final bool isToday;

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Text(
                  isToday ? 'تفاصيل اليوم' : '${day.dayName} — ${day.dateLabel}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Cairo',
                  ),
                ),
                const Spacer(),
                Text(
                  day.conditionText,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 13,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),

          // ── بطاقات المعلومات ────────────────────────────────────────────
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.6,
            children: [
              _InfoCard(
                icon: Icons.thermostat_rounded,
                iconColor: Colors.orange,
                label: 'الحرارة القصوى',
                value: '${day.tempMax.round()}°C',
              ),
              _InfoCard(
                icon: Icons.umbrella_rounded,
                iconColor: Colors.lightBlue,
                label: 'احتمالية الأمطار',
                value: day.precipitationProbability != null
                    ? '${day.precipitationProbability}%'
                    : '--',
              ),
              _InfoCard(
                icon: Icons.grain_rounded,
                iconColor: Colors.blue,
                label: 'كمية الأمطار',
                value: day.precipitationSum != null
                    ? '${day.precipitationSum!.toStringAsFixed(1)} مم'
                    : '0 مم',
              ),
              _InfoCard(
                icon: Icons.air_rounded,
                iconColor: Colors.teal,
                label: 'الرياح القصوى',
                value: day.windSpeedMax != null
                    ? '${day.windSpeedMax!.round()} km/h'
                    : '--',
              ),
              _InfoCard(
                icon: Icons.wb_sunny_rounded,
                iconColor: Colors.amber,
                label: 'سطوع الشمس',
                value: day.sunshineDurationHours != null
                    ? '${day.sunshineDurationHours!.toStringAsFixed(1)} ساعة'
                    : '--',
              ),
              _InfoCard(
                icon: Icons.light_mode_rounded,
                iconColor: Colors.yellow,
                label: 'طول النهار',
                value: day.daylightDurationHours != null
                    ? '${day.daylightDurationHours!.toStringAsFixed(1)} ساعة'
                    : '--',
              ),
              _InfoCard(
                icon: Icons.wb_twilight_rounded,
                iconColor: Colors.deepOrangeAccent,
                label: 'الشروق',
                value: day.sunriseLabel,
              ),
              _InfoCard(
                icon: Icons.nights_stay_rounded,
                iconColor: Colors.indigo,
                label: 'الغروب',
                value: day.sunsetLabel,
              ),
              _InfoCard(
                icon: Icons.opacity_rounded,
                iconColor: Colors.lightGreen,
                label: 'ساعات المطر',
                value: day.precipitationHours != null
                    ? '${day.precipitationHours!.toStringAsFixed(1)} ساعة'
                    : '0 ساعة',
              ),
              _InfoCard(
                icon: Icons.flare_rounded,
                iconColor: Colors.pink,
                label: 'مؤشر UV',
                value: day.uvIndexMax != null
                    ? day.uvIndexMax!.toStringAsFixed(1)
                    : '--',
              ),
              _InfoCard(
                icon: Icons.water_rounded,
                iconColor: Colors.cyanAccent,
                label: 'إجمالي المطر',
                value: day.rainSum != null
                    ? '${day.rainSum!.toStringAsFixed(1)} مم'
                    : '0 مم',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// مكونات مساعدة
// ─────────────────────────────────────────────────────────────────────────────

class _AppBarRow extends StatelessWidget {
  const _AppBarRow({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFamily: 'Cairo',
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

/// إحصاء سريع
class _QuickStat extends StatelessWidget {
  const _QuickStat({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white70, size: 18),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                fontFamily: 'Cairo',
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 10,
                fontFamily: 'Cairo',
              ),
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}

/// بطاقة معلومات
class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Cairo',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                    fontFamily: 'Cairo',
                  ),
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────────────────────
/// مندوب SliverAppBar للتبويبات
/// ─────────────────────────────────────────────────────────────────────────────
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.transparent,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}



