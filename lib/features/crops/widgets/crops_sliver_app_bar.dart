import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants.dart';
import '../../../core/widgets/atoms/pro_max_icon_button.dart';

class CropsSliverAppBar extends StatelessWidget {
  const CropsSliverAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 80.0,
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
                } else {
                  context.go('/home');
                }
              },
              size: 40,
              iconSize: 18,
            ),
            const SizedBox(width: 12),
            const Text(
              'المحاصيل',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 26,
                fontFamily: 'Cairo',
              ),
            ),
            const Spacer(),
            ProMaxIconButton(
              icon: Icons.notifications_none_rounded,
              onTap: () {},
            ),
          ],
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
        background: Container(color: AppColors.primary),
      ),
    );
  }
}
