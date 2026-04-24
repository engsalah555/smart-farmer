import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/molecules/glassmorphic_container.dart';
import '../../../core/widgets/fade_in_slide.dart';
import '../../../core/models/order_model.dart' as order_model;
import '../providers/marketplace_provider.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<MarketplaceProvider>().loadMyOrders();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final orders = context.watch<MarketplaceProvider>().myOrders;
    final isLoading = context.watch<MarketplaceProvider>().isLoading;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // Header matching Home aesthetic
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.only(
                top: context.hp(7),
                left: context.wp(6),
                right: context.wp(6),
                bottom: context.hp(3),
              ),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      SizedBox(width: context.wp(4)),
                      Text(
                        'طلباتي',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: context.wp(6),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: context.hp(2)),
                  Text(
                    'هنا يمكنك متابعة حالة طلباتك وتفاصيلها',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: context.wp(3.5),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (isLoading && orders.isEmpty)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (orders.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_bag_outlined, size: context.wp(15), color: Colors.grey),
                    SizedBox(height: context.hp(2)),
                    const Text('لا يوجد لديك طلبات حتى الآن', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: EdgeInsets.all(context.wp(5)),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final order = orders[index];
                    return FadeInSlide(
                      duration: Duration(milliseconds: 400 + (index * 100)),
                      child: _buildOrderCard(context, order, isDark),
                    );
                  },
                  childCount: orders.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, order_model.Order order, bool isDark) {
    final status = order.status;
    final total = order.totalPrice;
    final items = order.items;
    
    return GlassmorphicContainer(
      margin: EdgeInsets.only(bottom: context.hp(2)),
      borderRadius: BorderRadius.circular(20),
      opacity: isDark ? 0.05 : 0.6,
      color: isDark ? Colors.white : Colors.white,
      padding: EdgeInsets.all(context.wp(4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'طلب #${order.id}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              _buildStatusBadge(status),
            ],
          ),
          const Divider(height: 20),
          ...items.take(2).map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Container(
                  width: context.wp(12),
                  height: context.wp(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: item.imageUrl != null 
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(item.imageUrl!, fit: BoxFit.cover),
                      )
                    : const Icon(Icons.inventory_2_outlined, color: AppColors.primary),
                ),
                SizedBox(width: context.wp(3)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.productName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text('الكمية: ${item.quantity} | السعر: ${item.price}'),
                    ],
                  ),
                ),
              ],
            ),
          )),
          if (items.length > 2)
            Text(
              '+${items.length - 2} منتجات أخرى',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          const Divider(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('الإجمالي', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  Text(
                    '$total ر.س',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  // Show details sheet
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectanglePlatform.isIOS ? const StadiumBorder() : RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('التفاصيل'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(order_model.OrderStatus status) {
    Color color;
    
    switch (status) {
      case order_model.OrderStatus.delivered:
        color = Colors.green;
        break;
      case order_model.OrderStatus.shipped:
        color = Colors.blue;
        break;
      case order_model.OrderStatus.processing:
        color = Colors.orange;
        break;
      case order_model.OrderStatus.confirmed:
        color = Colors.teal;
        break;
      case order_model.OrderStatus.cancelled:
        color = Colors.red;
        break;
      default:
        color = Colors.amber;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        status.arabicName,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// Helper for platforms
class RoundedRectanglePlatform {
  static bool get isIOS => true; // Simple mock for our premium feel
}
