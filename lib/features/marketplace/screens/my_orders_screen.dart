import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/fade_in_slide.dart';
import '../../../core/widgets/app_fonts.dart';
import '../providers/marketplace_provider.dart';
import '../widgets/order_card.dart';

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
      backgroundColor: context.background,
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
                color: context.primary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
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
                        style: context.font24.bold.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                  SizedBox(height: context.hp(2)),
                  Text(
                    'هنا يمكنك متابعة حالة طلباتك وتفاصيلها',
                    style: context.font14.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
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
                    Icon(Icons.shopping_bag_outlined, size: context.wp(15), color: context.textMuted),
                    SizedBox(height: context.hp(2)),
                    Text(
                      'لا يوجد لديك طلبات حتى الآن',
                      style: context.font16.copyWith(color: context.textMuted),
                    ),
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
                    final animationMultiplier = index > 10 ? 0 : index;
                    return FadeInSlide(
                      delay: Duration(milliseconds: 50 * animationMultiplier),
                      child: OrderCard(order: order, isDark: isDark),
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
}

// Helper for platforms
class RoundedRectanglePlatform {
  static bool get isIOS => true; // Simple mock for our premium feel
}
