import 'package:flutter/material.dart';

import '../../../core/models/user_model.dart';

/// Widget لعرض صلاحيات المستخدم في السوق
class MarketplacePermissionBanner extends StatelessWidget {
  final User user;

  const MarketplacePermissionBanner({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // لا تعرض شيء للمزارعين
    // For now, using isSeller is sufficient for not showing the banner to verified sellers
    // For now, using isSeller is sufficient for not showing the banner to verified sellers
    // Actually, let's keep the banner logic for unverified sellers only
    if (user.isSeller && !user.isVerified) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.orange.shade700),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'حسابك قيد المراجعة',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'سيتم تفعيل البيع بعد التحقق من حسابك',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

/// Widget لزر "إضافة منتج" مع التحقق من الصلاحيات
class AddProductButton extends StatelessWidget {
  final User user;
  final VoidCallback onPressed;

  const AddProductButton({
    super.key,
    required this.user,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // إخفاء الزر للمزارعين
    if (!user.canAddProducts) {
      return const SizedBox.shrink();
    }

    return FloatingActionButton.extended(
      heroTag: 'permission_add_product_fab',
      onPressed: onPressed,
      icon: const Icon(Icons.add),
      label: const Text('إضافة منتج'),
    );
  }
}

/// Dialog لعرض رسالة عدم وجود صلاحية
void showNoPermissionDialog(BuildContext context, User user) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('غير مسموح', textAlign: TextAlign.right),
      content: Text(
        user.isSeller
            ? 'حسابك قيد المراجعة.\nسيتم تفعيل البيع بعد التحقق.'
            : 'هذه الميزة متاحة للبائعين فقط.\nيمكنك الشراء من السوق.',
        textAlign: TextAlign.right,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('حسناً'),
        ),
      ],
    ),
  );
}
