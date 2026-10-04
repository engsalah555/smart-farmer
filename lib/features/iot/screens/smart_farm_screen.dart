import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants.dart';
import '../../crops/widgets/irrigation_tab.dart';
import '../providers/iot_provider.dart';

/// شاشة مزرعتي الذكية - مخصصة بالكامل للتحكم بالري ومراقبة حساسات المزرعة بتصميم محدث
class SmartFarmScreen extends StatefulWidget {
  const SmartFarmScreen({super.key});

  @override
  State<SmartFarmScreen> createState() => _SmartFarmScreenState();
}

class _SmartFarmScreenState extends State<SmartFarmScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IotProvider>().fetchStatus(showLoading: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            _buildSmartFarmSliverAppBar(context, isDark),
          ];
        },
        body: RefreshIndicator(
          color: context.primary,
          backgroundColor: isDark ? AppColors.darkCard : Colors.white,
          onRefresh: () async {
            await context.read<IotProvider>().fetchStatus(showLoading: false);
          },
          child: IrrigationControlTab(isDark: isDark),
        ),
      ),
    );
  }

  Widget _buildSmartFarmSliverAppBar(BuildContext context, bool isDark) {
    return Consumer<IotProvider>(
      builder: (context, iotProvider, _) {
        final device = iotProvider.device;

        return SliverAppBar(
          expandedHeight: 76.0,
          toolbarHeight: 72.0,
          floating: false,
          pinned: true,
          elevation: 0,
          backgroundColor: isDark
              ? AppColors.darkBackground.withValues(alpha: 0.88)
              : Colors.white.withValues(alpha: 0.92),
          automaticallyImplyLeading: false,
          leadingWidth: 0,
          titleSpacing: 0,
          flexibleSpace: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18.0, sigmaY: 18.0),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkBackground.withValues(alpha: 0.88)
                      : Colors.white.withValues(alpha: 0.92),
                  border: Border(
                    bottom: BorderSide(
                      color: context.primary
                          .withValues(alpha: isDark ? 0.22 : 0.12),
                      width: 1.0,
                    ),
                  ),
                ),
              ),
            ),
          ),
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'مزرعتي الذكية',
                        style: GoogleFonts.cairo(
                          color: context.textPrimary,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        device != null
                            ? 'محطة الري الذكي • ${device.deviceId}'
                            : 'نظام المراقبة والري الحي',
                        style: GoogleFonts.cairo(
                          color: context.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),

          ),
        );
      },
    );
  }
}

