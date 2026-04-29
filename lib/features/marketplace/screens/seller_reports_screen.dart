import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants.dart';
import '../providers/seller_provider.dart';
import '../../../core/models/product_model.dart';
import '../../../core/models/store_model.dart';
import '../../../core/widgets/app_fonts.dart';

/// شاشة تقارير المتجر
class SellerReportsScreen extends StatefulWidget {
  const SellerReportsScreen({super.key});

  @override
  State<SellerReportsScreen> createState() => _SellerReportsScreenState();
}

class _SellerReportsScreenState extends State<SellerReportsScreen> {
  @override
  void initState() {
    super.initState();
    // جلب طلبات المتجر إذا لم تكن متوفرة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SellerProvider>().loadStoreOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = context.select<SellerProvider, StoreModel?>((p) => p.myStore);
    final products = context.select<SellerProvider, List<ProductModel>>(
      (p) => p.myProducts,
    );
    final orders = context.select<SellerProvider, List<Map<String, dynamic>>>(
      (p) => p.storeOrders,
    );
    final myCatalogsCount = context.select<SellerProvider, int>(
      (p) => p.myCatalogs.length,
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (store == null) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('تقارير المتجر'),
            centerTitle: true,
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    size: 80,
                    color: context.primary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'لا توجد بيانات متاحة',
                    style: context.font20.bold,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'يجب عليك إكمال إعداد المتجر أولاً لكي نتمكن من عرض التقارير والإحصائيات الخاصة بك.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('العودة'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final myProducts = products;
    final lowStockProducts = myProducts.where((p) => p.quantity <= 5).toList();
    final outOfStockProducts = myProducts
        .where((p) => p.quantity == 0)
        .toList();

    // حساب المبيعات
    double totalSales = 0;
    int totalItemsSold = 0;

    for (var order in orders) {
      if (order['status'] != 'cancelled') {
        final items = order['items'] as List<dynamic>? ?? [];
        for (var item in items) {
          final double price =
              double.tryParse(item['price_at_purchase']?.toString() ?? '0') ??
              0;
          final int qty =
              int.tryParse(item['quantity']?.toString() ?? '1') ?? 1;
          totalSales += (price * qty);
          totalItemsSold += qty;
        }
      }
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تقارير المتجر'),
          centerTitle: true,
          elevation: 0,
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            final provider = context.read<SellerProvider>();
            if (!context.mounted) return;
            await provider.loadMyStore();
            await provider.loadStoreOrders();
          },
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'نظرة عامة',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // ملخص المبيعات
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [context.primary, AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: context.primary.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'إجمالي المبيعات',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        Icon(Icons.trending_up, color: Colors.white, size: 24),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${totalSales.toStringAsFixed(2)} ريال',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        _buildMiniStat(
                          'الطلبات المنجزة',
                          '${orders.where((o) => o['status'] == 'delivered').length}',
                          isDark,
                        ),
                        const SizedBox(width: 15),
                        _buildMiniStat(
                          'وحدات مباعة',
                          '$totalItemsSold',
                          isDark,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              // حالة المخزون
              const Text(
                'حالة المخزون',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: _buildReportCard(
                      context,
                      title: 'إجمالي المنتجات',
                      value: '${myProducts.length}',
                      icon: Icons.inventory_2,
                      color: Colors.blue,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildReportCard(
                      context,
                      title: 'نفذت الكمية',
                      value: '${outOfStockProducts.length}',
                      icon: Icons.warning_amber_rounded,
                      color: Colors.red,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: _buildReportCard(
                      context,
                      title: 'مخزون منخفض',
                      value:
                          '${lowStockProducts.length - outOfStockProducts.length}',
                      icon: Icons.trending_down,
                      color: Colors.orange,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildReportCard(
                      context,
                      title: 'عدد الكتالوجات',
                      value: '$myCatalogsCount',
                      icon: Icons.category,
                      color: Colors.purple,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // التنبيهات
              if (outOfStockProducts.isNotEmpty ||
                  lowStockProducts.isNotEmpty) ...[
                const Text(
                  'تنبيهات المنتجات',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                if (outOfStockProducts.isNotEmpty)
                  _buildAlertTile(
                    context,
                    'منتج نفذ من المخزون',
                    '${outOfStockProducts.length} منتجات نفذت وتحتاج لتجديد',
                    Colors.red,
                  ),
                if (lowStockProducts.isNotEmpty &&
                    (lowStockProducts.length - outOfStockProducts.length) > 0)
                  _buildAlertTile(
                    context,
                    'مخزون منخفض',
                    '${lowStockProducts.length - outOfStockProducts.length} منتجات تقترب من النفاذ',
                    Colors.orange,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniStat(String title, String value, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 13, color: Theme.of(context).hintColor),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertTile(
    BuildContext context,
    String title,
    String subtitle,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.notifications_active, color: color, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 15,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Theme.of(context).hintColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: color.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }
}
