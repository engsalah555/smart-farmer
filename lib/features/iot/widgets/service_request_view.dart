import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants.dart';
import '../../../core/widgets/atoms/pro_max_icon_button.dart';
import '../providers/iot_provider.dart';

class ServiceRequestView extends StatelessWidget {
  const ServiceRequestView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.getBackground(isDark),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(context, 'الري الذكي', isDark),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.getSurface(isDark),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: context.primary.withValues(alpha: 0.1),
                          blurRadius: 20,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.settings_input_component_outlined,
                      size: 80,
                      color: context.primary,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    'خدمة الري الذكي',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.getTextColor(isDark),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'تحكم بمزرعتك عن بُعد، وفر المياه، وضاعف إنتاجك مع نظام الري الذكي المتطور.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[isDark ? 400 : 700],
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  _buildFeatureRow(
                    context,
                    Icons.timer_outlined,
                    'جدولة الري بدقة',
                    isDark,
                  ),
                  _buildFeatureRow(
                    context,
                    Icons.water_drop_outlined,
                    'توفير استهلاك المياه',
                    isDark,
                  ),
                  _buildFeatureRow(
                    context,
                    Icons.phone_android_outlined,
                    'تحكم كامل من هاتفك',
                    isDark,
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () async {
                        final success = await context
                            .read<IotProvider>()
                            .requestService();
                        if (success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'تم إرسال طلبك بنجاح! سنتواصل معك قريباً.',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              backgroundColor: context.primary,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                      child: const Text(
                        'طلب الخدمة الآن',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, String title, bool isDark) {
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
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 26,
              ),
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

  Widget _buildFeatureRow(
    BuildContext context,
    IconData icon,
    String text,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: context.primary, size: 24),
          const SizedBox(width: 16),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.getTextColor(isDark),
            ),
          ),
        ],
      ),
    );
  }
}
