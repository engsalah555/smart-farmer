import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:smart_farm2/core/widgets/app_fonts.dart';
import '../../../core/constants.dart';
import '../../iot/providers/iot_provider.dart';
import '../../iot/models/irrigation_log_model.dart';
import '../../iot/models/irrigation_schedule_model.dart';

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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main Status Card - Precision Instrumentation Style
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
                child: _buildPrecisionStatusCard(
                  soilMoisture,
                  isWatering,
                  lastLog,
                  schedules,
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Environment Stats Row
          Row(
            children: [
              Expanded(
                child: Selector<IotProvider, double?>(
                  selector: (_, provider) => provider.device?.temperature,
                  builder: (context, temp, _) {
                    return _buildEnvCard(
                      'حرارة الجو',
                      '${temp?.toStringAsFixed(1) ?? '--'}°C',
                      Icons.thermostat_rounded,
                      context.warning,
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Selector<IotProvider, double?>(
                  selector: (_, provider) => provider.device?.humidity,
                  builder: (context, humidity, _) {
                    return _buildEnvCard(
                      'رطوبة الجو',
                      '${humidity?.toStringAsFixed(0) ?? '--'}%',
                      Icons.water_drop_rounded,
                      context.info,
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Control Section
          Text(
            'إعدادات الري',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          Selector<IotProvider, bool>(
            selector: (_, provider) => provider.device?.autoIrrigation ?? false,
            builder: (context, auto, _) {
              return _buildControlTile(
                'الجدولة الذكية',
                'تفعيل الري التلقائي بناءً على حساس الرطوبة',
                auto,
                (val) => context.read<IotProvider>().toggleAutoIrrigation(val),
                Icons.auto_awesome_rounded,
              );
            },
          ),
          const SizedBox(height: 12),

          Selector<IotProvider, bool>(
            selector: (_, provider) => provider.device?.isIrrigationOn ?? false,
            builder: (context, isWatering, _) {
              return _buildActionCard(isWatering);
            },
          ),

          const SizedBox(height: 40),
          // Coming Soon Footer
          Center(
            child: Text(
              'نظام التحكم في مرحلة التشغيل التجريبي v1.0',
              style: TextStyle(
                color: context.isDark ? Colors.white10 : Colors.grey[400],
                fontSize: 10,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrecisionStatusCard(
    double soilMoisture,
    bool isWatering,
    IrrigationLog? lastLog,
    List<IrrigationSchedule> schedules,
  ) {
    final primaryColor = context.primary;

    // Calculate next irrigation from schedules
    String nextIrrigation = '--';
    if (schedules.isNotEmpty) {
      final schedule = schedules.first;
      nextIrrigation = schedule.startTime;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: isWatering ? primaryColor : context.border,
          width: isWatering ? 2 : 1,
        ),
        boxShadow: [
          if (isWatering)
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.2),
              blurRadius: 20,
              spreadRadius: 2,
            ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'رطوبة التربة الحالية',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: context.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        soilMoisture.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          color: context.textPrimary,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '%',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: (soilMoisture > 40 ? context.success : context.warning)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  soilMoisture > 40 ? 'نطاق مثالي' : 'تحت الحد الأدنى',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: soilMoisture > 40
                        ? context.success
                        : context.warning,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Technical Gauge
          Stack(
            children: [
              Container(
                height: 8,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: context.isDark
                      ? Colors.white10
                      : Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 1000),
                height: 8,
                width:
                    (MediaQuery.of(context).size.width - 88) *
                    (soilMoisture / 100),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor.withValues(alpha: 0.7), primaryColor],
                  ),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildInstrumentStat(
                  'آخر ري نشط',
                  lastLog != null
                      ? DateFormat('HH:mm').format(lastLog.createdAt)
                      : '--:--',
                  Icons.history_rounded,
                ),
              ),
              Container(height: 32, width: 1, color: context.border),
              Expanded(
                child: _buildInstrumentStat(
                  'الجدولة التالية',
                  nextIrrigation,
                  Icons.event_repeat_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInstrumentStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 12, color: context.textMuted),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: context.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: context.textPrimary,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  Widget _buildEnvCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: context.textSecondary),
          ),
          FittedBox(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: context.textPrimary,
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
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.border),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        secondary: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: context.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: context.primary, size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 14,
            color: context.textPrimary,
          ),
        ),
        subtitle: Text(
          sub,
          style: TextStyle(fontSize: 11, color: context.textSecondary),
        ),
        activeTrackColor: context.primary.withValues(alpha: 0.3),
        activeThumbColor: context.primary,
      ),
    );
  }

  Widget _buildActionCard(bool isWatering) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isWatering
              ? [Colors.blue.shade400, Colors.blue.shade700]
              : [
                  context.primary.withValues(alpha: 0.1),
                  context.primary.withValues(alpha: 0.05),
                ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isWatering
              ? Colors.blue
              : context.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isWatering ? 'الري اليدوي نشط' : 'تشغيل يدوي مباشر',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: isWatering ? Colors.white : context.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isWatering
                      ? 'سيتوقف الري عند الضغط أو بلوغ الحد الآمن'
                      : 'تجاوز الجدولة والبدء بالري الآن',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isWatering
                        ? Colors.white.withValues(alpha: 0.8)
                        : (widget.isDark ? Colors.white38 : Colors.black45),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () =>
                context.read<IotProvider>().toggleIrrigation(!isWatering),
            style: ElevatedButton.styleFrom(
              backgroundColor: isWatering ? Colors.white : context.primary,
              foregroundColor: isWatering ? Colors.blue : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              isWatering ? 'إيقاف الري' : 'تشغيل الري',
              style: context.body.bold.copyWith(
                color: isWatering ? Colors.blue : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
