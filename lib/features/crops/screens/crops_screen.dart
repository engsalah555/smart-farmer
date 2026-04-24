import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../widgets/crops_sliver_app_bar.dart';
import '../widgets/crops_sticky_header.dart';
import '../widgets/my_crops_tab.dart';
import '../widgets/crops_guide_tab.dart';
import '../widgets/irrigation_tab.dart';

class CropsScreen extends StatefulWidget {
  final Function(int)? onBack;

  const CropsScreen({super.key, this.onBack});

  @override
  State<CropsScreen> createState() => _CropsScreenState();
}

class _CropsScreenState extends State<CropsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            // 1. Modern Sliver App Bar
            const CropsSliverAppBar(),

            // 2. Persistent Sticky Header (Search + Tabs)
            CropsStickyHeader(
              searchQuery: _searchQuery,
              onSearchChanged: (value) {
                setState(() => _searchQuery = value);
              },
              tabController: _tabController,
              tabs: const ['محاصيلي', 'دليل النبات', 'التحكم بالري'],
              onTabTap: (index) {
                _tabController.animateTo(index);
              },
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            MyCropsTab(
              isDark: isDark,
              tabController: _tabController,
              searchQuery: _searchQuery,
            ),
            CropsGuideTab(isDark: isDark, searchQuery: _searchQuery),
            IrrigationControlTab(isDark: isDark),
          ],
        ),
      ),
    );
  }
}
