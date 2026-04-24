import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// مؤشر تحميل احترافي (Shimmer) لشاشة المتجر
/// يوفر تجربة بصرية سلسة أثناء جلب البيانات بدلاً من الدائرة الدوارة التقليدية
class MarketplaceShimmerLoader extends StatelessWidget {
  final bool isGrid;
  
  const MarketplaceShimmerLoader({
    super.key,
    this.isGrid = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey.shade800 : const Color(0xFFE2E8E1); // Sage-tinted base
    final highlightColor = isDark ? Colors.grey.shade700 : const Color(0xFFF3F7F2); // Lighter sage highlight

    return SliverPadding(
      padding: const EdgeInsets.all(16.0),
      sliver: isGrid ? _buildGridShimmer(baseColor, highlightColor, isDark) : _buildListShimmer(baseColor, highlightColor, isDark),
    );
  }

  Widget _buildGridShimmer(Color baseColor, Color highlightColor, bool isDark) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.black26 : Colors.white70,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(width: double.infinity, height: 14, color: Colors.white),
                          const SizedBox(height: 8),
                          Container(width: 80, height: 12, color: Colors.white),
                          const Spacer(),
                          Container(width: 60, height: 16, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        childCount: 6, // Show 6 shimmer items initially
      ),
    );
  }

  Widget _buildListShimmer(Color baseColor, Color highlightColor, bool isDark) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Shimmer.fromColors(
              baseColor: baseColor,
              highlightColor: highlightColor,
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  color: isDark ? Colors.black26 : Colors.white70,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 120,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.horizontal(right: Radius.circular(16)),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(width: double.infinity, height: 16, color: Colors.white),
                            const SizedBox(height: 12),
                            Container(width: 120, height: 14, color: Colors.white),
                            const SizedBox(height: 16),
                            Container(width: 80, height: 18, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        childCount: 4,
      ),
    );
  }
}
