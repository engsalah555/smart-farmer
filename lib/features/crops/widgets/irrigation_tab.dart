import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants.dart';
import '../../../core/widgets/molecules/glassmorphic_container.dart';

import '../../iot/providers/iot_provider.dart';

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
          // Main Status Card - Using Selector to only rebuild when soilMoisture or isIrrigationOn changes
          Selector<IotProvider, (double, bool)>(
            selector: (_, provider) => (
              provider.device?.soilMoisture ?? 0,
              provider.device?.isIrrigationOn ?? false
            ),
            builder: (context, data, _) {
              final soilMoisture = data.$1;
              final isWatering = data.$2;
              return RepaintBoundary(
                child: _buildMainStatusCard(soilMoisture, isWatering),
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
                      Colors.orange,
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
                      Colors.blue,
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Control Section
          Text(
            'أدوات التحكم',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: widget.isDark ? Colors.white : AppColors.textPrimary,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 16),

          Selector<IotProvider, bool>(
            selector: (_, provider) => provider.device?.autoIrrigation ?? false,
            builder: (context, auto, _) {
              return _buildControlTile(
                'الري التلقائي',
                'يعتمد على مستشعرات الرطوبة',
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
              'النظام في مرحلة التطوير التجريبي',
              style: TextStyle(
                color: widget.isDark ? Colors.white24 : Colors.grey[400],
                fontSize: 12,
                fontFamily: 'Cairo',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainStatusCard(double soilMoisture, bool isWatering) {
    return GlassmorphicContainer(
      padding: const EdgeInsets.all(24),
      width: double.infinity,
      color: AppColors.primary,
      opacity: 0.8,
      child: Column(
        children: [
          const Text(
            'مستوى رطوبة التربة',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 24),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: CircularProgressIndicator(
                  value: soilMoisture / 100,
                  strokeWidth: 12,
                  backgroundColor: Colors.white10,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isWatering ? Colors.blueAccent : Colors.white,
                  ),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                children: [
                  Text(
                    '${soilMoisture.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  Text(
                    soilMoisture > 40 ? 'ممتاز' : 'تحتاج ري',
                    style: const TextStyle(
                      fontSize: 14, 
                      color: Colors.white70,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSmallStat('آخر ري', 'منذ ساعتين'),
              Container(
                height: 20,
                width: 1,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                color: Colors.white24,
              ),
              _buildSmallStat('التالي المتوقع', 'غداً 6:00 ص'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.white60, fontFamily: 'Cairo'),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'Cairo',
          ),
        ),
      ],
    );
  }

  Widget _buildEnvCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: widget.isDark
              ? Colors.white10
              : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: [
          if (!widget.isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
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
            style: TextStyle(
              fontSize: 12,
              color: widget.isDark ? Colors.white60 : Colors.grey[600],
              fontFamily: 'Cairo',
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: widget.isDark ? Colors.white : AppColors.textPrimary,
              fontFamily: 'Cairo',
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: widget.isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: widget.isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          sub,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
        activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
        activeThumbColor: AppColors.primary,
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
                  AppColors.primary.withValues(alpha: 0.1),
                  AppColors.primary.withValues(alpha: 0.05),
                ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isWatering
              ? Colors.blue
              : AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isWatering ? 'جاري الري الآن...' : 'ري يدوي طارئ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isWatering ? Colors.white : AppColors.primary,
                  ),
                ),
                Text(
                  isWatering
                      ? 'قم بالإغلاق عند الاكتفاء'
                      : 'ابدأ عملية الري يدوياً بضغطة واحدة',
                  style: TextStyle(
                    fontSize: 11,
                    color: isWatering ? Colors.white70 : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => context.read<IotProvider>().toggleIrrigation(!isWatering),
            style: ElevatedButton.styleFrom(
              backgroundColor: isWatering ? Colors.white : AppColors.primary,
              foregroundColor: isWatering ? Colors.blue : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              isWatering ? 'إيقاف الري' : 'تشغيل الري',
              style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
            ),
          ),
        ],
      ),
    );
  }
}
