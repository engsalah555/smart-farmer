import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/fade_in_slide.dart';

class ModuleDashboard extends StatelessWidget {
  const ModuleDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.wp(6)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInSlide(
            duration: const Duration(milliseconds: 600),
            child: Text(
              'الأقسام الرئيسية',
              style: TextStyle(
                fontSize: context.sp(18).clamp(16, 22),
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(height: context.hp(2)),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: context.wp(4),
            crossAxisSpacing: context.wp(4),
            childAspectRatio: 1.1,
            children: [
              _buildModuleCard(
                context,
                title: 'المزرعة الذكية',
                subtitle: 'الحساسات والتحكم',
                icon: Icons.sensors_rounded,
                color: const Color(0xFF4CAF50),
                route: '/iot',
                index: 0,
              ),
              _buildModuleCard(
                context,
                title: 'دليل النباتات',
                subtitle: 'معلومات زراعية',
                icon: Icons.menu_book_rounded,
                color: const Color(0xFF8BC34A),
                route: '/crops',
                index: 1,
              ),
              _buildModuleCard(
                context,
                title: 'المنتدى الزراعي',
                subtitle: 'تواصل وتبادل خبرات',
                icon: Icons.groups_rounded,
                color: const Color(0xFF2196F3),
                route: '/forum',
                index: 2,
              ),
              _buildModuleCard(
                context,
                title: 'الذكاء الاصطناعي',
                subtitle: 'تشخيص وتحليل',
                icon: Icons.auto_awesome_rounded,
                color: const Color(0xFF9C27B0),
                route: '/chatbot',
                index: 3,
              ),
              _buildModuleCard(
                context,
                title: 'المتجر',
                subtitle: 'مستلزمات ومحاصيل',
                icon: Icons.shopping_bag_rounded,
                color: const Color(0xFFFF9800),
                route: '/marketplace',
                index: 4,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModuleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String route,
    required int index,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FadeInSlide(
      delay: Duration(milliseconds: 100 * index),
      duration: const Duration(milliseconds: 600),
      child: GestureDetector(
        onTap: () => context.push(route),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.1),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(
              color: isDark 
                  ? color.withValues(alpha: 0.2) 
                  : color.withValues(alpha: 0.05),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                Positioned(
                  right: -20,
                  top: -20,
                  child: Icon(
                    icon,
                    size: 80,
                    color: color.withValues(alpha: 0.05),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          icon,
                          color: color,
                          size: 24,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: context.sp(14).clamp(12, 18),
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: context.sp(11).clamp(10, 14),
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w400,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
