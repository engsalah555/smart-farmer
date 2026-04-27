import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/constants.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/user_crop_model.dart';
import '../../../core/widgets/atoms/pro_max_icon_button.dart';
import '../../../core/widgets/molecules/glassmorphic_container.dart';

class PlantHealthScreen extends StatefulWidget {
  final UserCropData userCrop;

  const PlantHealthScreen({super.key, required this.userCrop});

  @override
  State<PlantHealthScreen> createState() => _PlantHealthScreenState();
}

class _PlantHealthScreenState extends State<PlantHealthScreen> {
  // Health logs
  final List<Map<String, dynamic>> _healthLogs = [];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.getBackground(isDark),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            stretch: true,
            elevation: 0,
            backgroundColor: context.primary,
            leading: Padding(
              padding: const EdgeInsets.all(10.0),
              child: ProMaxIconButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () {
                  if (context.canPop()) {
                    context.pop();
                  }
                },
                size: 36,
                iconSize: 16,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                color: Colors.white,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              title: Text(
                'السجل الصحي: ${widget.userCrop.plant.name}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              background: Container(color: context.primary),
            ),
          ),
          if (_healthLogs.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: const Padding(
                padding: EdgeInsets.all(20.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'مستوى صحة النبات (آخر 7 فترات)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                height: 180,
                padding: const EdgeInsets.only(right: 20, left: 20, bottom: 20),
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    minX: 0,
                    maxX: 6,
                    minY: 0,
                    maxY: 10,
                    lineBarsData: [
                      LineChartBarData(
                        spots: const [
                          FlSpot(0, 5),
                          FlSpot(1, 4),
                          FlSpot(2, 6),
                          FlSpot(3, 8),
                          FlSpot(4, 9),
                          FlSpot(5, 7),
                          FlSpot(6, 9),
                        ],
                        isCurved: true,
                        color: context.primary,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: context.primary.withValues(alpha: 0.2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Divider(
                color: Colors.grey.withValues(alpha: 0.2),
                thickness: 1,
              ),
            ),
          ],
          if (_healthLogs.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.monitor_heart_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'لا توجد سجلات فحص سابقة',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final log = _healthLogs[index];
                  final DateTime date = log['date'] as DateTime;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GlassmorphicContainer(
                      borderRadius: BorderRadius.circular(20),
                      color: AppColors.getSurface(isDark),
                      opacity: isDark ? 0.6 : 0.85,
                      blur: 15.0,
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : context.primary.withValues(alpha: 0.1),
                        width: 1.5,
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: log['isHealthy']
                              ? Colors.green.withValues(alpha: 0.2)
                              : Colors.red.withValues(alpha: 0.2),
                          child: Icon(
                            log['isHealthy']
                                ? Icons.check
                                : Icons.warning_amber,
                            color: log['isHealthy'] ? Colors.green : Colors.red,
                          ),
                        ),
                        title: Text(
                          log['status'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              log['notes'],
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${date.year}/${date.month}/${date.day}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? Colors.white54
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }, childCount: _healthLogs.length),
              ),
            ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ), // Bottom padding
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push('/disease_detection');
          if (!context.mounted) return;
          setState(() {
            _healthLogs.insert(0, {
              'date': DateTime.now(),
              'status': 'تم الفحص (جديد)',
              'notes': 'تم استخدام الذكاء الاصطناعي لفحص النبات.',
              'isHealthy': true,
            });
          });
        },
        backgroundColor: context.primary,
        icon: const Icon(Icons.camera_alt, color: Colors.white),
        label: const Text(
          'فحص جديد',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 4,
      ),
    );
  }
}
