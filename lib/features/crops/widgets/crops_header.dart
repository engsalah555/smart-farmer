import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants.dart';

class CropsHeader extends StatelessWidget {
  final bool innerBoxIsScrolled;
  final bool isDark;

  const CropsHeader({
    super.key,
    required this.innerBoxIsScrolled,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 150,
      pinned: true,
      stretch: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        centerTitle: true,
        title: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: innerBoxIsScrolled ? 1.0 : 0.0,
          child: const Text(
            'دليل النباتات',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            color: isDark
                ? context.primary.withValues(alpha: context.opacityHigh)
                : context.primary,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(AppDecorations.headerRadius),
              bottomRight: Radius.circular(AppDecorations.headerRadius),
            ),
            boxShadow: [
              BoxShadow(
                color: context.primary
                    .withValues(alpha: context.opacityMedium * 1.5),
                blurRadius: 20,
                offset: const Offset(0, 10),
                spreadRadius: -5,
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: -30,
                right: -30,
                child: Icon(
                  Icons.eco_rounded,
                  size: 180,
                  color: context.white.withValues(alpha: context.opacitySubtle * 1.6),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 30,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text(
                      'دليل النباتات',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'رعاية لنمو مثالي',
                      style: TextStyle(
                        color: context.white.withValues(alpha: context.opacityStrong),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      leading: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          decoration: BoxDecoration(
            color: context.white.withValues(
              alpha: (context.opacityLow + context.opacityMedium) / 2,
            ),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 16,
            ),
            onPressed: () => context.go('/home'),
            padding: EdgeInsets.zero,
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.search_rounded,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () {
                // Focus search or navigate
              },
              padding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }
}
