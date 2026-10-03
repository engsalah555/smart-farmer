import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants.dart';
import '../../../core/widgets/atoms/pro_max_icon_button.dart';
import '../../crops/widgets/irrigation_tab.dart';
import '../models/iot_device_model.dart';
import '../providers/iot_provider.dart';

/// شاشة مزرعتي الذكية - مخصصة بالكامل للتحكم بالري ومراقبة حساسات المزرعة
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
          onRefresh: () async {
            await context.read<IotProvider>().fetchStatus(showLoading: false);
          },
          child: IrrigationControlTab(isDark: isDark),
        ),
      ),
    );
  }

  Widget _buildSmartFarmSliverAppBar(BuildContext context, bool isDark) {
    final device = context.select<IotProvider, IotDevice?>((p) => p.device);
    final isConnected = device != null && device.status.toLowerCase() != 'offline';

    return SliverAppBar(
      expandedHeight: 80.0,
      toolbarHeight: 70.0,
      floating: false,
      pinned: true,
      stretch: true,
      backgroundColor: context.primary,
      elevation: 0,
      automaticallyImplyLeading: false,
      leadingWidth: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            ProMaxIconButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/home');
                }
              },
              size: 40,
              iconSize: 18,
            ),
            const SizedBox(width: 12),
            const Text(
              'مزرعتي الذكية',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 24,
              ),
            ),
            const Spacer(),
            // Connection Status Chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
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
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isConnected ? const Color(0xFF2ECC71) : const Color(0xFFE74C3C),
                      boxShadow: [
                        BoxShadow(
                          color: (isConnected ? const Color(0xFF2ECC71) : const Color(0xFFE74C3C))
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
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
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
                context.read<IotProvider>().fetchStatus(showLoading: true);
              },
              size: 40,
              iconSize: 20,
            ),
          ],
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
        background: Container(color: context.primary),
      ),
    );
  }
}
