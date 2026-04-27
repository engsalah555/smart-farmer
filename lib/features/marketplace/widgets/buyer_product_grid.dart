import 'package:flutter/material.dart';
import '../providers/marketplace_provider.dart';
import 'unified_product_card.dart';

class BuyerProductGrid extends StatelessWidget {
  final MarketplaceProvider provider;
  final String searchQuery;

  const BuyerProductGrid({
    super.key,
    required this.provider,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // Responsive grid: 2 cols on phones, 3 on tablets, 4 on desktops
    final int crossAxisCount = width < 600 ? 2 : (width < 900 ? 3 : 4);

    var products = provider.products;

    // Local filtering if needed, though provider should handle it
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      products = products
          .where(
            (p) =>
                p.title.toLowerCase().contains(query) ||
                p.description.toLowerCase().contains(query),
          )
          .toList();
    }

    if (products.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisExtent: 280,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => UnifiedProductCard(
            product: products[index],
            layout: ProductCardLayout.grid,
            mode: ProductCardMode.buyer,
          ),
          childCount: products.length,
        ),
      ),
    );
  }
}
