import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants.dart';
import '../../../core/widgets/atoms/pro_max_icon_button.dart';
import '../providers/iot_provider.dart';
import '../models/iot_device_model.dart';
import '../models/irrigation_log_model.dart';
import 'schedule_bottom_sheet.dart';

import 'iot_landing_page.dart';
import 'iot_pending_page.dart';

class IotDashboard extends StatelessWidget {
  const IotDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final isLoading = context.select<IotProvider, bool>((p) => p.isLoading);
    final device = context.select<IotProvider, IotDevice?>((p) => p.device);
    final hasDevice = context.select<IotProvider, bool>((p) => p.hasDevice);

    if (isLoading && device == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (!hasDevice && device == null) return const IotLandingPage();
    if (device != null && device.status == 'pending') return const IotPendingPage();
    if (device == null) return const IotLandingPage();

    return Scaffold(
      backgroundColor: AppColors.getBackground(isDark),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          Selector<IotProvider, String>(
            selector: (_, p) => p.device?.name ?? 'لوحة التحكم',
            builder: (context, name, _) => _buildSliverAppBar(context, name, isDark),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Selector<IotProvider, (String, DateTime?)>(
                    selector: (_, p) => (p.device?.status ?? '', p.device?.lastSyncAt),
                    builder: (context, data, _) => _buildStatusCard(data.$1, data.$2, device.deviceId, isDark),
                  ),
                  const SizedBox(height: 28),
                  
                  _buildSectionTitle('المؤشرات الحيوية', isDark),
                  const SizedBox(height: 16),
                  Selector<IotProvider, (double?, double?, double?, double?, double?)>(
                    selector: (_, p) => (
                      p.device?.temperature, 
                      p.device?.humidity, 
                      p.device?.soilMoisture,
                      p.device?.waterLevel,
                      p.device?.rainLevel
                    ),
                    builder: (context, sensors, _) => _buildSensorReadings(
                      sensors.$1, sensors.$2, sensors.$3, sensors.$4, sensors.$5, isDark
                    ),
                  ),
                  
                  const SizedBox(height: 28),
                  
                  _buildSectionTitle('التحكم الذكي', isDark),
                  const SizedBox(height: 16),
                  Selector<IotProvider, (bool, bool)>(
                    selector: (_, p) => (p.device?.isIrrigationOn ?? false, p.device?.autoIrrigation ?? false),
                    builder: (context, modes, _) => _buildMainControls(context, modes.$1, modes.$2, isDark),
                  ),
                  
                  const SizedBox(height: 28),
                  
                  _buildSectionTitle('إحصائيات الاستهلاك', isDark),
                  const SizedBox(height: 16),
                  Selector<IotProvider, double>(
                    selector: (_, p) => p.device?.waterConsumption ?? 0.0,
                    builder: (context, consumption, _) => _buildStatsSection(consumption, isDark),
                  ),
                  
                  const SizedBox(height: 28),
                  
                  _buildSectionTitle('سجل النشاط', isDark),
                  const SizedBox(height: 16),
                  Selector<IotProvider, int>(
                    selector: (_, p) => p.logs.length,
                    builder: (context, _, child) => _buildRecentLogs(context.read<IotProvider>().logs, isDark),
                  ),
                  
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFab(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w900,
        
        letterSpacing: 0.3,
        color: AppColors.getTextColor(isDark),
      ),
    );
  }

  Widget _buildFab(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          colors: isDark 
              ? [AppColors.darkAccent.withValues(alpha: 0.8), AppColors.darkAccent.withValues(alpha: 0.5)]
              : [const Color(0xFF00C6FF), const Color(0xFF0072FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? AppColors.darkAccent : const Color(0xFF0072FF)).withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(32),
          onTap: () => _showScheduleSheet(context),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 24),
              SizedBox(width: 12),
              Text(
                'جدولة الري الذكية',
                style: TextStyle(
                  
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, String deviceName, bool isDark) {
    return SliverAppBar(
      expandedHeight: 140.0,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.getBackground(isDark),
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        title: Text(
          deviceName,
          style: TextStyle(
            color: AppColors.getTextColor(isDark),
            fontWeight: FontWeight.w900,
            fontSize: 26,
            
            letterSpacing: -0.5,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark 
                      ? [AppColors.darkSurface, AppColors.darkBackground]
                      : [const Color(0xFFF8FAFC), const Color(0xFFE2E8F0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Positioned(
              right: -60,
              top: -60,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              top: 50,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ProMaxIconButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => context.canPop() ? context.pop() : context.go('/home'),
                    size: 44,
                    iconSize: 20,
                  ),
                  ProMaxIconButton(
                    icon: Icons.refresh_rounded,
                    onTap: () => context.read<IotProvider>().fetchStatus(),
                    size: 44,
                    iconSize: 22,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(String status, DateTime? lastSyncAt, String deviceId, bool isDark) {
    final isActive = status == 'active';
    return _PremiumCard(
      isDark: isDark,
      gradientColors: isActive 
          ? [const Color(0xFF00B4DB), const Color(0xFF0083B0)] 
          : [const Color(0xFFED213A), const Color(0xFF93291E)],
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white24,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.wifi_rounded, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isActive ? 'النظام متصل ويعمل بكفاءة' : 'النظام غير متصل',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'آخر مزامنة: ${lastSyncAt?.toString().substring(0, 16) ?? "غير متوفر"}',
                  style: const TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorReadings(double? temp, double? humidity, double? soil, double? water, double? rain, bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildSensorItem('الحرارة', '${temp?.toStringAsFixed(1) ?? "--"}°C', Icons.thermostat_rounded, const Color(0xFFFF8008), const Color(0xFFFFC837), isDark)),
            const SizedBox(width: 16),
            Expanded(child: _buildSensorItem('الرطوبة', '${humidity?.round() ?? "--"}%', Icons.water_drop_rounded, const Color(0xFF2193b0), const Color(0xFF6dd5ed), isDark)),
            const SizedBox(width: 16),
            Expanded(child: _buildSensorItem('التربة', '${soil?.round() ?? "--"}%', Icons.grass_rounded, const Color(0xFF11998e), const Color(0xFF38ef7d), isDark)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildSensorItem('خزان المياه', '${water?.round() ?? "--"}%', Icons.waves_rounded, const Color(0xFF4facfe), const Color(0xFF00f2fe), isDark)),
            const SizedBox(width: 16),
            Expanded(child: _buildSensorItem('مستوى المطر', '${rain?.round() ?? "--"}%', Icons.umbrella_rounded, const Color(0xFF6a11cb), const Color(0xFF2575fc), isDark)),
          ],
        ),
      ],
    );
  }

  Widget _buildSensorItem(String label, String value, IconData icon, Color color1, Color color2, bool isDark) {
    return _PremiumCard(
      isDark: isDark,
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 8),
      child: Column(
        children: [
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(colors: [color1, color2]).createShader(bounds),
            child: Icon(icon, size: 36, color: Colors.white),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.getTextColor(isDark),
              
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildMainControls(BuildContext context, bool isIrrigationOn, bool autoIrrigation, bool isDark) {
    final provider = context.read<IotProvider>();
    return Column(
      children: [
        _buildControlCard(
          icon: Icons.water_drop_rounded,
          title: 'الري اليدوي',
          subtitle: isIrrigationOn ? 'جاري الري الآن' : 'متوقف حالياً',
          value: isIrrigationOn,
          activeColor1: const Color(0xFF00C6FF),
          activeColor2: const Color(0xFF0072FF),
          isDark: isDark,
          onChanged: provider.toggleIrrigation,
        ),
        const SizedBox(height: 16),
        _buildControlCard(
          icon: Icons.auto_mode_rounded,
          title: 'الري الذكي (التلقائي)',
          subtitle: autoIrrigation ? 'مفعل حسب الجدولة' : 'الجدولة معطلة',
          value: autoIrrigation,
          activeColor1: const Color(0xFF11998e),
          activeColor2: const Color(0xFF38ef7d),
          isDark: isDark,
          onChanged: provider.toggleAutoIrrigation,
        ),
      ],
    );
  }

  Widget _buildControlCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Color activeColor1,
    required Color activeColor2,
    required bool isDark,
    required Function(bool) onChanged,
  }) {
    return _PremiumCard(
      isDark: isDark,
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: value 
                  ? LinearGradient(colors: [activeColor1, activeColor2], begin: Alignment.topLeft, end: Alignment.bottomRight)
                  : null,
              color: value ? null : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
              borderRadius: BorderRadius.circular(22),
              boxShadow: value ? [BoxShadow(color: activeColor2.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4))] : [],
            ),
            child: Icon(icon, color: value ? Colors.white : Colors.grey, size: 28),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    
                    color: AppColors.getTextColor(isDark),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13, 
                    color: value ? activeColor1 : Colors.grey, 
                     
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeTrackColor: activeColor2,
            inactiveTrackColor: isDark ? AppColors.darkBorder : AppColors.textMuted.withValues(alpha: 0.1),
            thumbColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.neutralWhite;
              }
              return isDark ? AppColors.darkTextSecondary : null;
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(double waterConsumption, bool isDark) {
    return Row(
      children: [
        Expanded(child: _buildStatCard('إجمالي الاستهلاك', '${waterConsumption}L', Icons.insights_rounded, const Color(0xFF8E2DE2), const Color(0xFF4A00E0), isDark)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard('دورات الري', '4', Icons.loop_rounded, const Color(0xFFf12711), const Color(0xFFf5af19), isDark)),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color1, Color color2, bool isDark) {
    return _PremiumCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color1.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ShaderMask(
              shaderCallback: (bounds) => LinearGradient(colors: [color1, color2]).createShader(bounds),
              child: Icon(icon, size: 28, color: Colors.white),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              
              color: AppColors.getTextColor(isDark),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentLogs(List<IrrigationLog> logs, bool isDark) {
    if (logs.isEmpty) {
      return _PremiumCard(
        isDark: isDark,
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.history_rounded, size: 56, color: Colors.grey.withValues(alpha: 0.2)),
              const SizedBox(height: 16),
              const Text('لا توجد سجلات حالياً', style: TextStyle( color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );
    }
    return Column(
      children: logs.map((log) => _buildLogItem(log, isDark)).toList(),
    );
  }

  Widget _buildLogItem(IrrigationLog log, bool isDark) {
    final isOn = log.action.contains('on');
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: (isOn ? Colors.blue : Colors.grey).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(isOn ? Icons.water_drop_rounded : Icons.opacity_rounded, color: isOn ? Colors.blue : Colors.grey, size: 24),
        ),
        title: Text(
          _getLogText(log.action),
          style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.getTextColor(isDark), fontSize: 15),
        ),
        subtitle: Text(
          log.createdAt.toString().substring(11, 16),
          style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '${log.waterUsed}L',
            style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.blue, fontSize: 14),
          ),
        ),
      ),
    );
  }

  String _getLogText(String action) {
    switch (action) {
      case 'manual_on': return 'تشغيل يدوي';
      case 'manual_off': return 'إيقاف يدوي';
      case 'auto_on': return 'تشغيل تلقائي';
      case 'auto_off': return 'إيقاف تلقائي';
      default: return action;
    }
  }

  void _showScheduleSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ScheduleBottomSheet(),
    );
  }
}

class _PremiumCard extends StatelessWidget {
  final Widget child;
  final bool isDark;
  final EdgeInsetsGeometry? padding;
  final List<Color>? gradientColors;

  const _PremiumCard({required this.child, required this.isDark, this.padding, this.gradientColors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: gradientColors == null ? (isDark ? AppColors.darkCard : AppColors.getSurface(isDark)) : null,
        gradient: gradientColors != null ? LinearGradient(colors: gradientColors!, begin: Alignment.topLeft, end: Alignment.bottomRight) : null,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : Colors.black.withValues(alpha: 0.03),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (gradientColors?.first ?? (isDark ? Colors.black : const Color(0xFFD0D0D0))).withValues(alpha: isDark ? 0.3 : 0.15),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}
