import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farm2/core/widgets/app_fonts.dart';
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
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: context.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.storefront_rounded,
                  size: 64,
                  color: context.primary,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'ليس لديك متجر حالياً',
                style: context.font24.bold.copyWith(color: context.textPrimary),
              ),
              const SizedBox(height: 12),
              Text(
                'تحتاج إلى التسجيل كتاجر موثق لتبدأ ببيع منتجاتك والوصول إلى آلاف المشترين.',
                textAlign: TextAlign.center,
                style: context.font14.copyWith(
                  color: context.textSecondary,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => context.push('/merchant_verification'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 18,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text('توثيق حساب التاجر', style: context.font16.bold),
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
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: context.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.inventory_2_rounded,
                size: 52,
                color: context.primary.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'لم تضف أي منتج بعد',
              style: context.font16.medium.copyWith(
                color: context.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: context.primary.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 52,
                color: context.primary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'لا توجد متاجر مطابقة',
              style: context.font20.bold.copyWith(color: context.textPrimary),
            ),
            const SizedBox(height: 12),
            Text(
              'جرّب تغيير طريقة البحث أو اختر تصنيفاً مختلفاً للوصول لنتائج أفضل.',
              textAlign: TextAlign.center,
              style: context.font14.copyWith(
                color: context.textSecondary,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
