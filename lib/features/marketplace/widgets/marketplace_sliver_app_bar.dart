import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smart_farm2/core/widgets/app_fonts.dart';
import '../../../core/constants.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/models/user_model.dart';
import '../../../core/widgets/atoms/pro_max_icon_button.dart';
import '../../../core/widgets/molecules/pro_max_toggle.dart';

class MarketplaceSliverAppBar extends StatelessWidget {
  final String searchQuery;
  final Function(String) onSearchChanged;
  final Function(int)? onBack;
  final bool isSearchVisible;
  final VoidCallback onToggleSearch;
  final bool isBuying;
  final Function(bool) onToggleChanged;

  const MarketplaceSliverAppBar({
    super.key,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.isSearchVisible,
    required this.onToggleSearch,
    required this.isBuying,
    required this.onToggleChanged,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final isSeller = user?.isSeller ?? false;

    return SliverAppBar(
      expandedHeight: isSeller ? 140.0 : 80.0,
      toolbarHeight: 70.0,
      floating: false,
      pinned: true,
      stretch: true,
      backgroundColor: AppColors.primary,
      elevation: 0,
      automaticallyImplyLeading: false,
      leadingWidth: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            ProMaxIconButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: () {
                if (context.canPop()) {
                  context.pop();
                } else if (onBack != null) {
                  onBack!(0);
                } else {
                  context.go('/home');
                }
              },
              size: 40,
              iconSize: 18,
            ),
            const SizedBox(width: 12),
            Text(
              'المتجر',
              style: context.font24.semiBold.copyWith(color: context.white),
            ),
            const Spacer(),
            _buildActionIcons(context, user),
          ],
        ),
      ),
      bottom: isSeller
          ? PreferredSize(
              preferredSize: const Size.fromHeight(70),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: ProMaxToggle(
                  value: !isBuying,
                  activeLabel: 'بيع',
                  inactiveLabel: 'شراء',
                  onChanged: (v) => onToggleChanged(!v),
                ),
              ),
            )
          : null,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
        background: Container(color: AppColors.primary),
      ),
    );
  }

  Widget _buildActionIcons(BuildContext context, UserModel? user) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ProMaxIconButton(
          icon: isSearchVisible
              ? Icons.search_off_rounded
              : Icons.search_rounded,
          onTap: onToggleSearch,
        ),
        const SizedBox(width: 6),
        ProMaxIconButton(
          icon: Icons.map_outlined,
          onTap: () => context.push('/store_map'),
        ),
        const SizedBox(width: 6),
        ProMaxIconButton(
          icon: Icons.shopping_cart_outlined,
          onTap: () => context.push('/cart'),
        ),
        if (user?.isSeller == true) ...[
          const SizedBox(width: 6),
          ProMaxIconButton(
            icon: Icons.storefront_outlined,
            onTap: () => context.push('/seller_dashboard'),
          ),
        ],
      ],
    );
  }
}
