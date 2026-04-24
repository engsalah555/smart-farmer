import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/widgets/sliver_header_delegate.dart';

class CropsTabBar extends StatelessWidget {
  final TabController tabController;
  final bool innerBoxIsScrolled;
  final bool isDark;

  const CropsTabBar({
    super.key,
    required this.tabController,
    required this.innerBoxIsScrolled,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: SliverHeaderDelegate(
        minHeight: 70,
        maxHeight: 70,
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkBackground : AppColors.background,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(15),
            ),
            child: TabBar(
              controller: tabController,
              tabs: const [
                Tab(text: 'محاصيلي'),
                Tab(text: 'دليل النبات'),
                Tab(text: 'التحكم'),
              ],
              labelColor: Colors.white,
              unselectedLabelColor: isDark ? Colors.white60 : Colors.black54,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColors.primary,
              ),
              dividerColor: Colors.transparent,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
