import 'package:flutter/material.dart';
import '../../../core/models/store_model.dart';
import '../providers/marketplace_provider.dart';
import 'unified_store_card.dart';
import 'marketplace_empty_states.dart';

class BuyerStoreGrid extends StatelessWidget {
  final MarketplaceProvider provider;
  final String searchQuery;
  final String selectedFilter;
  final int selectedCategoryIndex;
  final List<Map<String, dynamic>> categories;

  const BuyerStoreGrid({
    super.key,
    required this.provider,
    required this.searchQuery,
    required this.selectedFilter,
    required this.selectedCategoryIndex,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // Responsive grid: 2 cols on phones, 2 on tablets, 3 on desktops
    final int crossAxisCount = width < 600 ? 2 : (width < 900 ? 2 : 3);

    final categoryData = categories[selectedCategoryIndex];
    final category = (categoryData['label'] ?? '').toString().trim();
    var stores = category == 'الكل'
        ? List<StoreModel>.from(provider.stores)
        : provider.stores
              .where(
                (s) =>
                    s.category.trim() == category ||
                    s.category.trim() == 'شامل',
              )
              .toList();

    // تطبيق البحث
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      stores = stores
          .where(
            (s) =>
                s.name.toLowerCase().contains(query) ||
                s.description.toLowerCase().contains(query) ||
                s.location.toLowerCase().contains(query),
          )
          .toList();
    }

    // تطبيق الفلترة/الترتيب
    switch (selectedFilter) {
      case 'top_rated':
        // الأعلى تقييماً: التقييم أولاً ثم عدد المراجعات
        stores.sort((a, b) {
          int cmp = b.rating.compareTo(a.rating);
          if (cmp != 0) return cmp;
          return b.reviewsCount.compareTo(a.reviewsCount);
        });
        break;
      case 'nearest':
        // حالياً لا نوفر إحداثيات المستخدم، لذا سنقوم بترتيب مستقر حسب الاسم أو الـ ID
        // هذا مجرد حل مؤقت لضمان أن الفلتر "يعمل" ولا يكون عشوائياً
        stores.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'newest':
        // وصل حديثاً: الترتيب حسب الـ ID تنازلياً
        stores.sort((a, b) => b.id.compareTo(a.id));
        break;
      case 'offers':
        // عروض حصرية: حالياً نرتب المتاجر التي لديها أكثر عدد مراجعات أو تقييم عالٍ
        // Note: في المستقبل، تصفية المتاجر التي لديها منتجات عليها خصومات فعالة
        stores.sort((a, b) => b.reviewsCount.compareTo(a.reviewsCount));
        break;
      case 'trending':
      default:
        // الأكثر رواجاً: نستخدم مزيجاً بين التقييم وعدد المراجعات
        stores.sort((a, b) {
          final scoreA = a.rating * (a.reviewsCount + 1);
          final scoreB = b.rating * (b.reviewsCount + 1);
          return scoreB.compareTo(scoreA);
        });
        break;
    }

    if (stores.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: NoStoresEmptyState(),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        16,
        8,
        16,
        // Extra bottom padding to not overlap FAB
        96,
      ),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisExtent:
              260, // Adjusted for 2-column layout to maintain aspect ratio
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) =>
              UnifiedStoreCard(store: stores[index], index: index),
          childCount: stores.length,
        ),
      ),
    );
  }
}
