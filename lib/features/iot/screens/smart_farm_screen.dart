import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants.dart';
import '../../../core/widgets/atoms/pro_max_icon_button.dart';
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
        final isConnected =
            device != null && device.status.toLowerCase() != 'offline';
        final canPop = context.canPop();

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
                if (canPop) ...[
                  ProMaxIconButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context.pop();
                    },
                    size: 38,
                    iconSize: 16,
                    color: context.textPrimary,
                    backgroundColor: isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.black.withValues(alpha: 0.04),
                  ),
                  const SizedBox(width: 12),
                ] else ...[
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: context.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: context.primary.withValues(alpha: 0.25),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.eco_rounded,
                      color: context.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
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
                // Connection Status Chip with glowing indicator
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: (isConnected ? context.primary : context.error)
                        .withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: (isConnected ? context.primary : context.error)
                          .withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isConnected
                              ? const Color(0xFF2ECC71)
                              : const Color(0xFFDC4545),
                          boxShadow: [
                            BoxShadow(
                              color: (isConnected
                                      ? const Color(0xFF2ECC71)
                                      : const Color(0xFFDC4545))
                                  .withValues(alpha: 0.6),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isConnected ? 'متصل' : 'غير متصل',
                        style: GoogleFonts.cairo(
                          color: isConnected
                              ? (isDark
                                  ? const Color(0xFF2ECC71)
                                  : context.primary)
                              : const Color(0xFFDC4545),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Quick Refresh Button
                ProMaxIconButton(
                  icon: Icons.refresh_rounded,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context.read<IotProvider>().fetchStatus(showLoading: true);
                  },
                  size: 38,
                  iconSize: 18,
                  color: context.textPrimary,
                  backgroundColor: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.black.withValues(alpha: 0.04),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

