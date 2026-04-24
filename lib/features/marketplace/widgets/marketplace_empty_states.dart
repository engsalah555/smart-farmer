import 'package:flutter/material.dart';
import '../../../core/constants.dart';

class NoStoreSliver extends StatelessWidget {
  const NoStoreSliver({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.storefront_outlined,
                size: 100,
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
              const SizedBox(height: 24),
              const Text(
                'ليس لديك متجر حالياً',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'تحتاج إلى التسجيل كتاجر موثق لتبدأ ببيع منتجاتك.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 10,
                  shadowColor: AppColors.primary.withValues(alpha: 0.4),
                ),
                child: const Text(
                  'توثيق حساب التاجر',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NoProductsSliver extends StatelessWidget {
  const NoProductsSliver({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 80,
              color: AppColors.primary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            const Text(
              'لم تضف أي منتج بعد',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty state for buyer view when no stores match the search/filter
class NoStoresEmptyState extends StatelessWidget {
  const NoStoresEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.storefront_outlined,
                size: 52,
                color: AppColors.primary.withValues(alpha: 0.35),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'لا توجد متاجر مطابقة',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'جرّب تغيير طريقة البحث أو اختر تصنيفاً مختلفاً',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).hintColor,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
