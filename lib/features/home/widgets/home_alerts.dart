import 'package:flutter/material.dart';
import '../../../core/widgets/app_fonts.dart';
import '../../../core/widgets/fade_in_slide.dart';

import '../../../core/constants.dart';
import '../../../core/services/alerts_service.dart';
import '../../../core/utils/responsive.dart';

class HomeAlerts extends StatefulWidget {
  const HomeAlerts({super.key});

  @override
  State<HomeAlerts> createState() => _HomeAlertsState();
}

class _HomeAlertsState extends State<HomeAlerts> {
  final AlertsService _alertsService = AlertsService();
  List<dynamic> _alerts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAlerts();
  }

  Future<void> _fetchAlerts() async {
    final alerts = await _alertsService.getActiveAlerts();
    if (mounted) {
      setState(() {
        _alerts = alerts;
        _isLoading = false;
      });
    }
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'weather':
        return Icons.cloud_outlined;
      case 'pest':
        return Icons.bug_report_outlined;
      default:
        return Icons.info_outline;
    }
  }

  Color _getColorForSeverity(String severity) {
    switch (severity) {
      case 'critical':
        return AppColors.error;
      case 'high':
        return AppColors.warning;
      case 'medium':
        return AppColors.info;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Center(
          child: RepaintBoundary(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (_alerts.isEmpty) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FadeInSlide(
      delay: const Duration(milliseconds: 300),
      duration: const Duration(milliseconds: 600),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.wp(5), vertical: context.hp(1)),
            child: Semantics(
              label: 'تنبيهات نشطة',
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: context.wp(5)),
                  SizedBox(width: context.wp(2)),
                  Text(
                    'التنبيهات العاجلة',
                    style: context.font18.bold.copyWith(color: AppColors.getTextColor(isDark)),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${_alerts.length} تنبيه',
                      style: context.font12.bold.copyWith(color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: context.hp(16).clamp(130.0, 180.0),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: context.wp(4)),
              itemCount: _alerts.length,
              itemBuilder: (context, index) {
                final alert = _alerts[index];
                final severityColor = _getColorForSeverity(alert['severity']);

                return RepaintBoundary(
                  child: Semantics(
                    label: 'تنبيه: ${alert['title']}. ${alert['message']}',
                    child: Container(
                      width: context.wp(75).clamp(280.0, 400.0),
                      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                      padding: EdgeInsets.all(context.wp(4).clamp(12.0, 20.0)),
                      decoration: BoxDecoration(
                        color: isDark 
                            ? Color.alphaBlend(severityColor.withValues(alpha: 0.08), AppColors.darkSurface)
                            : Color.alphaBlend(severityColor.withValues(alpha: 0.05), AppColors.white),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: severityColor.withValues(alpha: 0.2),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: severityColor.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                            spreadRadius: -4,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: severityColor.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _getIconForType(alert['type']),
                                  color: severityColor,
                                  size: context.sp(16).clamp(14, 20),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  alert['title'],
                                  style: TextStyle(
                                    fontSize: context.sp(14).clamp(12, 18),
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? AppColors.white : AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: Text(
                              alert['message'],
                              style: TextStyle(
                                fontSize: context.sp(12).clamp(10, 16),
                                fontWeight: FontWeight.w500,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                height: 1.4,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
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
}
