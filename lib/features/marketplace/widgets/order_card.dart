import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/models/order_model.dart' as order_model;
import '../../../core/widgets/molecules/glassmorphic_container.dart';
import '../../../core/widgets/app_fonts.dart';

class OrderCard extends StatelessWidget {
  final order_model.Order order;
  final bool isDark;

  const OrderCard({
    super.key,
    required this.order,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final status = order.status;
    final total = order.totalPrice;
    final items = order.items;

    return GlassmorphicContainer(
      margin: const EdgeInsets.only(bottom: 16),
      borderRadius: BorderRadius.circular(20),
      opacity: isDark ? 0.05 : 0.6,
      color: isDark ? Colors.white : Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'طلب #${order.id}',
                style: context.font16.bold.copyWith(color: context.textPrimary),
              ),
              _buildStatusBadge(status),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 1),
          const SizedBox(height: 16),
          ...items.take(2).map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: context.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: context.primary.withValues(alpha: 0.1),
                        ),
                      ),
                      child: item.imageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(item.imageUrl!, fit: BoxFit.cover),
                            )
                          : Icon(Icons.inventory_2_outlined, color: context.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productName,
                            style: context.font14.semiBold.copyWith(color: context.textPrimary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'الكمية: ${item.quantity} | السعر: ${item.price} ر.س',
                            style: context.font12.copyWith(color: context.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
          if (items.length > 2)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                '+${items.length - 2} منتجات أخرى',
                style: context.font12.copyWith(color: context.textMuted),
              ),
            ),
          const Divider(height: 1, thickness: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('الإجمالي', style: context.font10.copyWith(color: context.textMuted)),
                  Text(
                    '$total ر.س',
                    style: context.font18.bold.copyWith(color: context.primary),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  // Show details sheet
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('التفاصيل', style: context.font14.bold),
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
        color = AppColors.success;
        break;
      case order_model.OrderStatus.shipped:
        color = AppColors.info;
        break;
      case order_model.OrderStatus.processing:
        color = AppColors.warning;
        break;
      case order_model.OrderStatus.confirmed:
        color = Colors.teal;
        break;
      case order_model.OrderStatus.cancelled:
        color = AppColors.error;
        break;
      default:
        color = Colors.amber;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        status.arabicName,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
