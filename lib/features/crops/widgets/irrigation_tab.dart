import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants.dart';
import '../../iot/providers/iot_provider.dart';
import '../../iot/models/irrigation_log_model.dart';
import '../../iot/models/irrigation_schedule_model.dart';
import '../../iot/widgets/schedule_bottom_sheet.dart';

/// ─── شاشة ري المزرعة الذكية المستوحاة من أرقى تصاميم Dribbble & Harvest Link ───
class IrrigationControlTab extends StatefulWidget {
  final bool isDark;

  const IrrigationControlTab({super.key, required this.isDark});

  @override
  State<IrrigationControlTab> createState() => _IrrigationControlTabState();
}

class _IrrigationControlTabState extends State<IrrigationControlTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IotProvider>().fetchStatus(showLoading: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── 1. Hero Telemetry Card: Radial Arc + Moisture Sparkline ─────
          Selector<
            IotProvider,
            (double, bool, IrrigationLog?, List<IrrigationSchedule>)
          >(
            selector: (_, provider) => (
              provider.device?.soilMoisture ?? 0,
              provider.device?.isIrrigationOn ?? false,
              provider.logs.isNotEmpty ? provider.logs.first : null,
              provider.device?.schedules ?? [],
            ),
            builder: (context, data, _) {
              final soilMoisture = data.$1;
              final isWatering = data.$2;
              final lastLog = data.$3;
              final schedules = data.$4;

              return RepaintBoundary(
                child: _buildDribbbleHeroTelemetryCard(
                  soilMoisture,
                  isWatering,
                  lastLog,
                  schedules,
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          // ─── 2. 2x2 Telemetry Sensor Matrix (Dribbble Quad Layout) ───────
          _buildTelemetrySectionHeader('الحساسات والقياسات البيئية'),
          const SizedBox(height: 12),

          // Row 1: Temperature & Humidity
          Row(
            children: [
              Expanded(
                child: Selector<IotProvider, double?>(
                  selector: (_, provider) => provider.device?.temperature,
                  builder: (context, temp, _) {
                    return _buildSensorTile(
                      label: 'حرارة الجو',
                      value: '${temp?.toStringAsFixed(1) ?? '--'}°C',
                      icon: Icons.thermostat_rounded,
                      accentColor: context.warning,
                      statusTag: temp != null
                          ? (temp < 18
                                ? 'بارد'
                                : temp <= 32
                                ? 'معتدل ومثالي'
                                : 'مرتفع')
                          : '--',
                      subtext: 'محيط الحقل',
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Selector<IotProvider, double?>(
                  selector: (_, provider) => provider.device?.humidity,
                  builder: (context, humidity, _) {
                    return _buildSensorTile(
                      label: 'رطوبة الجو',
                      value: '${humidity?.toStringAsFixed(0) ?? '--'}%',
                      icon: Icons.air_rounded,
                      accentColor: context.primary,
                      statusTag: humidity != null
                          ? (humidity < 40
                                ? 'جاف نسبياً'
                                : humidity <= 70
                                ? 'رطوبة مثالية'
                                : 'رطوبة عالية')
                          : '--',
                      subtext: 'الغلاف الجوي',
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Row 2: Water Reservoir & Rain Detection
          Selector<IotProvider, (String?, bool?, double?)>(
            selector: (_, provider) => (
              provider.device?.waterLevel,
              provider.device?.rainDetected,
              provider.device?.rainLevel,
            ),
            builder: (context, data, _) {
              final water = data.$1;
              final rain = data.$2;
              final rainLevel = data.$3;

              String safeWaterStr = water?.replaceAll('%', '').trim() ?? '0';
              if (safeWaterStr == '--') safeWaterStr = '0';
              final waterDouble = double.tryParse(safeWaterStr) ?? 0.0;
              final isLowWater = waterDouble <= 20.0;
              final isRaining = rain == true;
              final rainVal = rainLevel?.round() ?? 0;

              return Row(
                children: [
                  Expanded(
                    child: _buildWaterTankTile(
                      waterDouble: waterDouble,
                      isLowWater: isLowWater,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildRainSensorTile(
                      isRaining: isRaining,
                      rainVal: rainVal,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // ─── 3. Actuator Control Center (Dribbble Equipment Controls) ───
          _buildTelemetrySectionHeader('لوحة التحكم بالمعدات'),
          const SizedBox(height: 12),

          // Hero Pump Actuator Card
          Selector<IotProvider, bool>(
            selector: (_, provider) => provider.device?.isIrrigationOn ?? false,
            builder: (context, isWatering, _) {
              return _buildHeroPumpCard(isWatering);
            },
          ),
          const SizedBox(height: 12),

          // Smart Auto Irrigation Switch Tile
          Selector<IotProvider, bool>(
            selector: (_, provider) => provider.device?.autoIrrigation ?? false,
            builder: (context, auto, _) {
              return _buildControlTile(
                'الري التلقائي الذكي (AI Mode)',
                'تفعيل الضخ الآلي عندما تنخفض رطوبة التربة عن 40%',
                auto,
                (val) => context.read<IotProvider>().toggleAutoIrrigation(val),
                Icons.auto_awesome_rounded,
              );
            },
          ),

          const SizedBox(height: 36),

          // ─── Footer ────────────────────────────────────────────────
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified_user_rounded,
                  size: 13,
                  color: widget.isDark ? Colors.white24 : Colors.grey[500],
                ),
                const SizedBox(width: 6),
                Text(
                  'محطة التحكم الذكية v2.0 • اتصال IoT مشفّر ومباشر',
                  style: GoogleFonts.cairo(
                    color: widget.isDark ? Colors.white24 : Colors.grey[500],
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 90),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // ─── 1. Hero Telemetry Card (Radial Gauge + Sparkline) ───────────────────────
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildDribbbleHeroTelemetryCard(
    double soilMoisture,
    bool isWatering,
    IrrigationLog? lastLog,
    List<IrrigationSchedule> schedules,
  ) {
    final isOptimal = soilMoisture >= 40.0;

    String nextIrrigation = '--';
    if (schedules.isNotEmpty) {
      nextIrrigation = schedules.first.startTime;
    }

    // تدرج لوني أخضر رئيسي فاخر وغني يطابق تماماً بطاقة المناخ في الشاشة الرئيسية (HomeClimateCard)
    final gradientColors = widget.isDark
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
    const accentUnitColor = Color(0xFF76C748);

    // Normalized sample points for the 24h moisture sparkline
    final currentNorm = (soilMoisture / 100.0).clamp(0.15, 0.95);
    final sparklinePoints = [
      (currentNorm * 0.88).clamp(0.1, 0.9),
      (currentNorm * 0.94).clamp(0.1, 0.9),
      (currentNorm * 0.91).clamp(0.1, 0.9),
      (currentNorm * 0.98).clamp(0.1, 0.9),
      (currentNorm * 1.05).clamp(0.1, 0.95),
      (currentNorm * 1.02).clamp(0.1, 0.95),
      currentNorm,
    ];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(
            0xFF2ECC71,
          ).withValues(alpha: widget.isDark ? 0.45 : 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(
              0xFF0C2E19,
            ).withValues(alpha: widget.isDark ? 0.45 : 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          if (isWatering)
            BoxShadow(
              color: const Color(0xFF2ECC71).withValues(alpha: 0.35),
              blurRadius: 24,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Location/Sensor Tag & Status Pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.sensors_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'حساس رطوبة التربة',
                        style: GoogleFonts.cairo(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                        ),
                      ),
                      Text(
                        'Capacitive Soil Sensor • قطاع A1',
                        style: GoogleFonts.cairo(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: subTextColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4.5,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isWatering
                            ? accentUnitColor
                            : (isOptimal
                                  ? accentUnitColor
                                  : const Color(0xFFF59E0B)),
                        boxShadow: [
                          BoxShadow(
                            color:
                                (isWatering || isOptimal
                                        ? accentUnitColor
                                        : const Color(0xFFF59E0B))
                                    .withValues(alpha: 0.8),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isWatering
                          ? 'ري نشط الآن'
                          : (isOptimal ? 'نطاق مثالي' : 'تحت الحد الأدنى'),
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Main Gauge & Telemetry Stats
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _CircularMoistureGauge(
                value: soilMoisture,
                isWatering: isWatering,
                isDark: widget.isDark,
                primaryColor: accentUnitColor,
                isInGreenCard: true,
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          soilMoisture.toStringAsFixed(1),
                          style: GoogleFonts.outfit(
                            fontSize: 38,
                            fontWeight: FontWeight.w900,
                            color: textColor,
                            letterSpacing: -1,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '%',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: accentUnitColor,
                            height: 1.0,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      isWatering
                          ? 'المضخة تدفق المياه إلى الجذور حالياً'
                          : (isOptimal
                                ? 'الرطوبة ملائمة تماماً لاحتياج المحصول'
                                : 'الرطوبة منخفضة، يُنصح ببدء الري الفوري'),
                      style: GoogleFonts.cairo(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: subTextColor,
                        height: 1.35,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildMicroMetricTag(
                          'الحد الأدنى: 40%',
                          subTextColor,
                          backgroundColor: Colors.black.withValues(alpha: 0.20),
                          borderColor: Colors.white.withValues(alpha: 0.22),
                        ),
                        const SizedBox(width: 6),
                        _buildMicroMetricTag(
                          'الهدف: 65%',
                          accentUnitColor,
                          backgroundColor: Colors.white.withValues(alpha: 0.16),
                          borderColor: accentUnitColor.withValues(alpha: 0.45),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 24h Soil Moisture Sparkline Waveform (Matching Home Agronomic Advice capsule)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.18),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.show_chart_rounded,
                          size: 14,
                          color: accentUnitColor,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'مخطط استقرار الرطوبة (24 ساعة)',
                          style: GoogleFonts.cairo(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'معدل الاستقرار 98%',
                      style: GoogleFonts.cairo(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: accentUnitColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 38,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: _MoistureSparklinePainter(
                      values: sparklinePoints,
                      lineColor: accentUnitColor,
                      isDark: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Sub-Stats Bar (Frosted glass matching Home card secondary modules)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.22),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildInstrumentStat(
                    'آخر ري نشط',
                    lastLog != null
                        ? DateFormat('HH:mm').format(lastLog.createdAt)
                        : '--:--',
                    Icons.history_rounded,
                    isInGreenCard: true,
                  ),
                ),
                Container(
                  height: 24,
                  width: 1,
                  color: Colors.white.withValues(alpha: 0.22),
                ),
                Expanded(
                  child: _buildInstrumentStat(
                    'الجدولة التالية',
                    nextIrrigation,
                    Icons.event_repeat_rounded,
                    isInGreenCard: true,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const ScheduleBottomSheet(),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // ─── 2. Sensor Tiles (2x2 Quad Matrix) ───────────────────────────────────────
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildSensorTile({
    required String label,
    required String value,
    required IconData icon,
    required Color accentColor,
    required String statusTag,
    required String subtext,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: context.border),
        boxShadow: AppDecorations.softShadow(widget.isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(7.5),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: Icon(icon, size: 19, color: accentColor),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 2.5,
                ),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.20),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  statusTag,
                  style: GoogleFonts.cairo(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: accentColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: context.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            child: Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: context.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaterTankTile({
    required double waterDouble,
    required bool isLowWater,
  }) {
    final waterColor = isLowWater ? context.error : context.primary;
    final waterPercent = (waterDouble / 100.0).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: context.border),
        boxShadow: AppDecorations.softShadow(widget.isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(7.5),
                decoration: BoxDecoration(
                  color: waterColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: waterColor.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.water_drop_rounded,
                  size: 19,
                  color: waterColor,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 2.5,
                ),
                decoration: BoxDecoration(
                  color: waterColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: waterColor.withValues(alpha: 0.20),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  isLowWater ? 'منخفض' : 'آمن',
                  style: GoogleFonts.cairo(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: waterColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'خزان المياه',
            style: GoogleFonts.cairo(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: context.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${waterDouble.toInt()}%',
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: context.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 6,
            width: double.infinity,
            decoration: BoxDecoration(
              color: widget.isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(3),
            ),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: waterPercent),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return FractionallySizedBox(
                  alignment: Alignment.centerRight,
                  widthFactor: value,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [waterColor.withValues(alpha: 0.8), waterColor],
                      ),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRainSensorTile({required bool isRaining, required int rainVal}) {
    final rainColor = isRaining ? context.primary : context.textMuted;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: context.border),
        boxShadow: AppDecorations.softShadow(widget.isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(7.5),
                decoration: BoxDecoration(
                  color: rainColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: rainColor.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: Icon(
                  isRaining ? Icons.umbrella_rounded : Icons.wb_sunny_rounded,
                  size: 19,
                  color: rainColor,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 2.5,
                ),
                decoration: BoxDecoration(
                  color: rainColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: rainColor.withValues(alpha: 0.20),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  isRaining ? 'ممطر' : 'صافي',
                  style: GoogleFonts.cairo(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: rainColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'حساس الأمطار',
            style: GoogleFonts.cairo(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: context.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            isRaining ? 'هطول نشط' : 'طقس جاف',
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'فرصة الهطول: $rainVal%',
            style: GoogleFonts.cairo(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: isRaining ? context.primary : context.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // ─── 3. Actuator Control Cards (Hero Pump & Smart Mode) ──────────────────────
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildHeroPumpCard(bool isWatering) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isWatering
              ? [const Color(0xFF2ECC71), const Color(0xFF27AE60)]
              : [context.surface, context.surface.withValues(alpha: 0.95)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isWatering
              ? const Color(0xFF2ECC71)
              : context.primary.withValues(alpha: 0.30),
          width: 1.5,
        ),
        boxShadow: [
          if (isWatering)
            BoxShadow(
              color: const Color(0xFF2ECC71).withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 6),
            )
          else
            ...AppDecorations.softShadow(widget.isDark),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (isWatering) ...[
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsetsDirectional.only(end: 8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.8),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ],
                    Text(
                      isWatering ? 'مضخة الري نشطة الآن' : 'تشغيل يدوي فوري',
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.w900,
                        fontSize: 15.5,
                        color: isWatering ? Colors.white : context.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  isWatering
                      ? 'جاري ضخ وتدفق المياه للحقل • سيتوقف عند الضغط'
                      : 'تجاوز الجدولة والبدء بالري الفوري الآن بضغطة زر',
                  style: GoogleFonts.cairo(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: isWatering
                        ? Colors.white.withValues(alpha: 0.92)
                        : context.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _TactileScaleButton(
            onTap: () {
              context.read<IotProvider>().toggleIrrigation(!isWatering);
            },
            backgroundColor: isWatering ? Colors.white : context.primary,
            foregroundColor: isWatering
                ? const Color(0xFF27AE60)
                : Colors.white,
            borderRadius: BorderRadius.circular(14),
            icon: isWatering ? Icons.stop_rounded : Icons.play_arrow_rounded,
            child: Text(
              isWatering ? 'إيقاف الري' : 'بدء الري',
              style: GoogleFonts.cairo(
                color: isWatering ? const Color(0xFF27AE60) : Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlTile(
    String title,
    String sub,
    bool value,
    Function(bool) onChanged,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: context.border),
        boxShadow: AppDecorations.softShadow(widget.isDark),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: (val) {
          HapticFeedback.selectionClick();
          onChanged(val);
        },
        secondary: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: context.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: context.primary.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Icon(icon, color: context.primary, size: 22),
        ),
        title: Text(
          title,
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.w800,
            fontSize: 13.5,
            color: context.textPrimary,
          ),
        ),
        subtitle: Text(
          sub,
          style: GoogleFonts.cairo(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: context.textSecondary,
            height: 1.3,
          ),
        ),
        activeTrackColor: context.primary.withValues(alpha: 0.35),
        activeThumbColor: context.primary,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // ─── Helpers & Micro Atoms ───────────────────────────────────────────────────
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildTelemetrySectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 15.5,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.3,
            color: context.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildMicroMetricTag(
    String text,
    Color color, {
    Color? backgroundColor,
    Color? borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color:
            backgroundColor ??
            (widget.isDark
                ? Colors.white.withValues(alpha: 0.04)
                : Colors.black.withValues(alpha: 0.03)),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: borderColor ?? color.withValues(alpha: 0.25),
          width: 0.8,
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.cairo(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _buildInstrumentStat(
    String label,
    String value,
    IconData icon, {
    bool isInGreenCard = false,
    VoidCallback? onTap,
  }) {
    final textColor = isInGreenCard ? Colors.white : context.textPrimary;
    final subColor = isInGreenCard
        ? const Color(0xFFE8F2E9)
        : (onTap != null ? context.primary : context.textMuted);
    final iconColor = isInGreenCard
        ? const Color(0xFF76C748)
        : (onTap != null ? context.primary : context.textMuted);

    final content = Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 13, color: iconColor),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: subColor,
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 4),
              Icon(Icons.edit_calendar_rounded, size: 11, color: iconColor),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: textColor,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: content,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ─── Custom Radial Arc Moisture Gauge ─────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────────

class _CircularMoistureGauge extends StatelessWidget {
  final double value;
  final bool isWatering;
  final bool isDark;
  final Color primaryColor;
  final bool isInGreenCard;

  const _CircularMoistureGauge({
    required this.value,
    required this.isWatering,
    required this.isDark,
    required this.primaryColor,
    this.isInGreenCard = false,
  });

  @override
  Widget build(BuildContext context) {
    final double clampedVal = (value / 100.0).clamp(0.0, 1.0);
    final isOptimal = value >= 40.0;
    final gaugeColor = isInGreenCard
        ? (isWatering
              ? const Color(0xFF76C748)
              : (isOptimal ? const Color(0xFF76C748) : const Color(0xFFF59E0B)))
        : (isWatering
              ? primaryColor
              : (isOptimal
                    ? const Color(0xFF2ECC71)
                    : const Color(0xFFF59E0B)));

    final trackColor = isInGreenCard
        ? Colors.white.withValues(alpha: 0.18)
        : (isDark
              ? Colors.white.withValues(alpha: 0.07)
              : Colors.black.withValues(alpha: 0.05));

    final numColor = isInGreenCard
        ? Colors.white
        : (isDark ? Colors.white : const Color(0xFF1A1D1A));
    final unitColor = isInGreenCard ? const Color(0xFF76C748) : gaugeColor;
    final labelColor = isInGreenCard
        ? const Color(0xFFE8F2E9)
        : (isDark ? Colors.white54 : Colors.black45);
    final iconColor = isInGreenCard ? const Color(0xFF76C748) : gaugeColor;

    return SizedBox(
      width: 106,
      height: 106,
      child: Stack(
        alignment: Alignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: clampedVal),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, animatedVal, _) {
              return CustomPaint(
                size: const Size(106, 106),
                painter: _RadialArcPainter(
                  progress: animatedVal,
                  gaugeColor: gaugeColor,
                  trackColor: trackColor,
                  isWatering: isWatering,
                ),
              );
            },
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.water_drop_rounded, size: 16, color: iconColor),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    value.toStringAsFixed(1),
                    style: GoogleFonts.outfit(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      color: numColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    '%',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: unitColor,
                    ),
                  ),
                ],
              ),
              Text(
                'الرطوبة',
                style: GoogleFonts.cairo(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: labelColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RadialArcPainter extends CustomPainter {
  final double progress;
  final Color gaugeColor;
  final Color trackColor;
  final bool isWatering;

  _RadialArcPainter({
    required this.progress,
    required this.gaugeColor,
    required this.trackColor,
    required this.isWatering,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 14) / 2;
    const startAngle = 135.0 * (math.pi / 180.0);
    const sweepAngle = 270.0 * (math.pi / 180.0);

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.5
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      trackPaint,
    );

    if (progress > 0) {
      final activeSweep = sweepAngle * progress;

      if (isWatering) {
        final glowPaint = Paint()
          ..color = gaugeColor.withValues(alpha: 0.40)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 13.0
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          activeSweep,
          false,
          glowPaint,
        );
      }

      final progressPaint = Paint()
        ..color = gaugeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8.5
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        activeSweep,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RadialArcPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.gaugeColor != gaugeColor ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.isWatering != isWatering;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ─── 24h Soil Moisture Sparkline Waveform Painter ────────────────────────────
// ─────────────────────────────────────────────────────────────────────────────

class _MoistureSparklinePainter extends CustomPainter {
  final List<double> values;
  final Color lineColor;
  final bool isDark;

  _MoistureSparklinePainter({
    required this.values,
    required this.lineColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    final width = size.width;
    final height = size.height;
    final dx = width / (values.length - 1);
    final points = <Offset>[];

    for (int i = 0; i < values.length; i++) {
      final x = i * dx;
      final y =
          height -
          (values[i].clamp(0.0, 1.0) * (height * 0.70) + height * 0.15);
      points.add(Offset(x, y));
    }

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final midX = (p0.dx + p1.dx) / 2;
      path.cubicTo(midX, p0.dy, midX, p1.dy, p1.dx, p1.dy);
    }

    final fillPath = Path.from(path)
      ..lineTo(points.last.dx, height)
      ..lineTo(points.first.dx, height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          lineColor.withValues(alpha: 0.35),
          lineColor.withValues(alpha: 0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, width, height));

    canvas.drawPath(fillPath, fillPaint);

    final strokePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, strokePaint);

    final lastPoint = points.last;
    final dotGlowPaint = Paint()
      ..color = lineColor.withValues(alpha: 0.50)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(lastPoint, 6.0, dotGlowPaint);

    final dotCorePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(lastPoint, 2.5, dotCorePaint);
  }

  @override
  bool shouldRepaint(covariant _MoistureSparklinePainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.isDark != isDark;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ─── Tactile Scale Button ────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────────

class _TactileScaleButton extends StatefulWidget {
  final VoidCallback onTap;
  final Widget child;
  final Color backgroundColor;
  final Color foregroundColor;
  final BorderRadius borderRadius;
  final IconData? icon;

  const _TactileScaleButton({
    required this.onTap,
    required this.child,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderRadius,
    this.icon,
  });

  @override
  State<_TactileScaleButton> createState() => _TactileScaleButtonState();
}

class _TactileScaleButtonState extends State<_TactileScaleButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        HapticFeedback.lightImpact();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: widget.borderRadius,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 16, color: widget.foregroundColor),
                const SizedBox(width: 6),
              ],
              DefaultTextStyle(
                style: GoogleFonts.cairo(
                  color: widget.foregroundColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
                child: widget.child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
