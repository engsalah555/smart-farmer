import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants.dart';
import '../../../core/widgets/fade_in_slide.dart';
import '../../../core/models/user_crop_model.dart';
import '../providers/crops_provider.dart';
import 'user_crop_card.dart';

class MyCropsTab extends StatefulWidget {
  final bool isDark;
  final TabController tabController;
  final String searchQuery;

  const MyCropsTab({
    super.key,
    required this.isDark,
    required this.tabController,
    required this.searchQuery,
  });

  @override
  State<MyCropsTab> createState() => _MyCropsTabState();
}

class _MyCropsTabState extends State<MyCropsTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CropsProvider>().fetchMyCrops();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CropsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.myCrops.isEmpty) {
          return Center(
            child: CircularProgressIndicator(color: context.primary),
          );
        }

        List<UserCropData> filteredCrops = provider.myCrops;
        if (widget.searchQuery.isNotEmpty) {
          final query = widget.searchQuery.toLowerCase();
          filteredCrops = provider.myCrops
              .where((c) => c.plant.name.toLowerCase().contains(query))
              .toList();
        }

        if (filteredCrops.isEmpty) {
          return _buildEmptyState(isSearch: widget.searchQuery.isNotEmpty);
        }

        return Column(
          children: [
            if (!widget.searchQuery.isNotEmpty)
              _buildLimitIndicator(provider.myCrops.length, widget.isDark),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredCrops.length,
                itemBuilder: (context, index) {
                  final userCrop = filteredCrops[index];
                  return FadeInSlide(
                    duration: const Duration(milliseconds: 600),
                    delay: Duration(milliseconds: index * 100),
                    child: UserCropCard(
                      userCrop: userCrop,
                      isDark: widget.isDark,
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLimitIndicator(int count, bool isDark) {
    final percent = count / 8;
    final isFull = count >= 8;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isFull
              ? Colors.red.withValues(alpha: 0.3)
              : context.primary.withValues(alpha: 0.1),
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isFull
                        ? Icons.warning_amber_rounded
                        : Icons.info_outline_rounded,
                    color: isFull ? Colors.red : context.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isFull ? 'وصلت للحد الأقصى' : 'سعة مزرعتك',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isFull
                          ? Colors.red
                          : (isDark ? Colors.white70 : Colors.black87),
                    ),
                  ),
                ],
              ),
              Text(
                '$count / 8 محاصيل',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: isFull ? Colors.red : context.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 8,
              backgroundColor: isDark ? Colors.white10 : Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                isFull ? Colors.red : context.primary,
              ),
            ),
          ),
          if (isFull)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'يرجى حذف محصول لإضافة نوع جديد.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({bool isSearch = false}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearch
                ? Icons.search_off_rounded
                : Icons.energy_savings_leaf_rounded,
            size: 80,
            color: context.primary.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 24),
          Text(
            isSearch ? 'لم يتم العثور على نتائج' : 'لا توجد محاصيل في مزرعتك',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              isSearch
                  ? 'جرب البحث بكلمات أخرى أو ابحث في دليل النبات.'
                  : 'ابدأ بإضافة محاصيلك من دليل النبات لتبدأ في متابعة نموها والعناية بها.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], height: 1.5),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => widget.tabController.animateTo(1),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 5,
              shadowColor: context.primary.withValues(alpha: 0.4),
            ),
            child: Text(
              isSearch ? 'انتقل للدليل' : 'استكشف الدليل الآن',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
