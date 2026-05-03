import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants.dart';
import '../../../core/models/crop_model.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/widgets/atoms/custom_image.dart';
import '../../../core/widgets/atoms/pro_max_icon_button.dart';
import '../providers/crops_provider.dart';

import '../widgets/detail/cultivation_section.dart';
import '../widgets/detail/soil_nutrition_section.dart';
import '../widgets/detail/management_rotation_section.dart';
import '../widgets/detail/pests_harvest_sections.dart';
import '../widgets/detail/uses_benefits_section.dart';
import '../widgets/detail/smart_care_advisor.dart';
import '../widgets/detail/visual_troubleshooting_section.dart';
import '../widgets/detail/companion_plants_section.dart';
import '../widgets/detail/regional_adaptation_section.dart';

class CropDetailScreen extends StatefulWidget {
  final Crop crop;
  const CropDetailScreen({super.key, required this.crop});

  @override
  State<CropDetailScreen> createState() => _CropDetailScreenState();
}

class _CropDetailScreenState extends State<CropDetailScreen> {
  bool _isAdding = false;

  bool _isAlreadyAdded(CropsProvider provider) {
    return provider.myCrops.any((c) => c.plant.id == widget.crop.id);
  }

  Future<void> _addToMyCrops() async {
    setState(() => _isAdding = true);
    final userId = context.read<AuthProvider>().currentUser?.id ?? 'guest_user';
    final provider = context.read<CropsProvider>();
    final success = await provider.addCropToFarm(userId, widget.crop.id);
    if (!mounted) return;
    setState(() => _isAdding = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'تمت إضافة ${widget.crop.name} إلى محاصيلك بنجاح'
              : 'حدث خطأ: ${provider.errorMessage}',
        ),
        backgroundColor: success ? context.primary : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = widget.crop;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: Consumer<CropsProvider>(
        builder: (context, provider, _) {
          final isAdded = _isAlreadyAdded(provider);
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _PremiumHeroAppBar(
                crop: c,
                isDark: isDark,
                isAdding: _isAdding,
                isAdded: isAdded,
                onAdd: _addToMyCrops,
                onRemove: () =>
                    _showRemoveConfirmation(context, provider, widget.crop),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // 1. Overview & About
                    if (c.description.isNotEmpty) ...[
                      _AboutCard(crop: c, isDark: isDark),
                      const SizedBox(height: 48),
                    ],

                    // 2. Agricultural Heart (Cultivation, Soil)
                    _PremiumSectionWrapper(
                      title: 'الدليل الزراعي',
                      icon: Icons.agriculture_rounded,
                      children: [
                        CultivationSection(crop: c),
                        const SizedBox(height: 40),
                        SoilNutritionSection(crop: c),
                      ],
                    ),
                    const SizedBox(height: 56),

                    // 3. Growth & Health
                    _PremiumSectionWrapper(
                      title: 'النمو والصحة',
                      icon: Icons.health_and_safety_rounded,
                      children: [
                        _GrowthTimelineSection(crop: c),
                        const SizedBox(height: 40),
                        PestsSection(crop: c),
                      ],
                    ),
                    const SizedBox(height: 56),

                    // 4. Ecology & Rotation
                    _PremiumSectionWrapper(
                      title: 'البيئة والدورة الزراعية',
                      icon: Icons.eco_rounded,
                      children: [
                        RegionalAdaptationSection(crop: c),
                        const SizedBox(height: 40),
                        CompanionPlantsSection(crop: c),
                        const SizedBox(height: 40),
                        ManagementRotationSection(crop: c),
                      ],
                    ),
                    const SizedBox(height: 56),

                    // 5. Results & Benefits
                    _PremiumSectionWrapper(
                      title: 'الحصاد والفوائد',
                      icon: Icons.auto_awesome_rounded,
                      children: [
                        HarvestSection(crop: c),
                        const SizedBox(height: 40),
                        UsesBenefitsSection(crop: c),
                      ],
                    ),
                    const SizedBox(height: 56),

                    // 6. Support & Tools
                    SmartCareAdvisor(crop: c),
                    const SizedBox(height: 48),

                    // 7. Marketplace CTA
                    _MarketplaceCtaSection(crop: c),
                    const SizedBox(height: 60),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showRemoveConfirmation(
    BuildContext context,
    CropsProvider provider,
    Crop crop,
  ) {
    final userCrop = provider.myCrops.firstWhere((c) => c.plant.id == crop.id);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إزالة من مزرعتي'),
        content: Text(
          'هل أنت متأكد من رغبتك في إزالة ${crop.name}؟ ستفقد كافة بيانات تتبع النمو الخاصة بهذه النبتة.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await provider.removeCropFromFarm(userCrop.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success ? 'تمت الإزالة بنجاح' : 'فشلت الإزالة',
                    ),
                    backgroundColor: success ? context.primary : Colors.red,
                  ),
                );
              }
            },
            child: const Text('إزالة', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// ─── Hero App Bar ──────────────────────────────────────────────────────────

class _PremiumHeroAppBar extends StatelessWidget {
  final Crop crop;
  final bool isDark;
  final bool isAdding;
  final bool isAdded;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _PremiumHeroAppBar({
    required this.crop,
    required this.isDark,
    required this.isAdding,
    required this.isAdded,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 350,
      pinned: true,
      stretch: true,
      elevation: 0,
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.white,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ProMaxIconButton(
          icon: Icons.arrow_back_ios_new_rounded,
          onTap: () => Navigator.canPop(context)
              ? Navigator.pop(context)
              : context.go('/home'),
          size: 48,
          iconSize: 20,
          backgroundColor: Colors.black.withValues(alpha: 0.3),
          color: Colors.white,
        ),
      ),
      actions: [
        if (isAdded)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ProMaxIconButton(
              icon: Icons.delete_sweep_rounded,
              onTap: onRemove,
              size: 48,
              iconSize: 22,
              backgroundColor: Colors.redAccent.withValues(alpha: 0.8),
              color: Colors.white,
            ),
          ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        collapseMode: CollapseMode.parallax,
        background: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: 'crop-${crop.id}',
              child: CustomImage(imageUrl: crop.imageUrl, fit: BoxFit.cover),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    isDark
                        ? AppColors.darkBackground.withValues(alpha: 0.6)
                        : Colors.black45,
                    Colors.transparent,
                    Colors.transparent,
                    isDark
                        ? AppColors.darkBackground.withValues(alpha: 0.8)
                        : Colors.black54,
                    isDark ? AppColors.darkBackground : Colors.black87,
                  ],
                  stops: const [0.0, 0.3, 0.6, 0.85, 1.0],
                ),
              ),
            ),
            Positioned(
              bottom: 24,
              left: 20,
              right: 20,
              child: _AppBarBottom(
                crop: crop,
                isAdding: isAdding,
                isAdded: isAdded,
                onAdd: onAdd,
                onRemove: onRemove,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppBarBottom extends StatelessWidget {
  final Crop crop;
  final bool isAdding;
  final bool isAdded;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _AppBarBottom({
    required this.crop,
    required this.isAdding,
    required this.isAdded,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                crop.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  shadows: [Shadow(color: Colors.black45, blurRadius: 10)],
                ),
              ),
              if (crop.scientificName != null)
                Text(
                  crop.scientificName!,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        _AddButton(
          isAdding: isAdding,
          isAdded: isAdded,
          onTap: onAdd,
          onRemove: onRemove,
        ),
      ],
    );
  }
}

class _AddButton extends StatelessWidget {
  final bool isAdding;
  final bool isAdded;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _AddButton({
    required this.isAdding,
    required this.isAdded,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (isAdded) {
      return PopupMenuButton<String>(
        onSelected: (val) {
          if (val == 'remove') onRemove();
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'remove',
            child: Row(
              children: [
                Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
                SizedBox(width: 8),
                Text('إزالة من مزرعتي'),
              ],
            ),
          ),
        ],
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: context.success.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white24),
          ),
          child: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'في مزرعتي',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              SizedBox(width: 4),
              Icon(Icons.arrow_drop_down, color: Colors.white70, size: 18),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: isAdding ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: context.primary.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: context.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            if (isAdding)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            else
              const Icon(Icons.add_rounded, color: Colors.white, size: 22),
            const SizedBox(width: 8),
            const Text(
              'أضف لمحاصيلي',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Growth Timeline ───────────────────────────────────────────────────────

class _GrowthTimelineSection extends StatelessWidget {
  final Crop crop;
  const _GrowthTimelineSection({required this.crop});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.timeline_rounded,
                color: context.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'الجدول الزمني للنمو',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: context.textColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: context.cardBackground,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: context.border.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _TimelineItem(
                label: 'مرحلة الإنبات',
                desc:
                    'تبدأ البذور في التفتح والظهور فوق سطح التربة. حافظ على رطوبة التربة باستمرار.',
                duration: '7-14 يوم',
                icon: Icons.grass_rounded,
                isFirst: true,
                isDark: isDark,
              ),
              _TimelineItem(
                label: 'النمو الخضري',
                desc:
                    'تطور السيقان والأوراق الكبيرة. تحتاج النبتة هنا لتغذية نيتروجينية قوية.',
                duration: '30-45 يوم',
                icon: Icons.energy_savings_leaf_rounded,
                isDark: isDark,
              ),
              _TimelineItem(
                label: 'مرحلة الإزهار',
                desc:
                    'بداية تكوين البراعم الزهرية. قلل التسميد النيتروجيني وزد البوتاسيوم.',
                duration: '15-20 يوم',
                icon: Icons.local_florist_rounded,
                isDark: isDark,
              ),
              _TimelineItem(
                label: 'النضج والحصاد',
                desc:
                    'المحصول يصل لحجمه الكامل ولونه الممتاز. جاهز للجمع الآن!',
                duration: crop.harvestTime,
                icon: Icons.shopping_basket_rounded,
                isLast: true,
                isDark: isDark,
                color: context.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final String label;
  final String desc;
  final String duration;
  final IconData icon;
  final bool isFirst;
  final bool isLast;
  final bool isDark;
  final Color? color;

  const _TimelineItem({
    required this.label,
    required this.desc,
    required this.duration,
    required this.icon,
    this.isFirst = false,
    this.isLast = false,
    required this.isDark,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = color ?? (isDark ? Colors.white30 : Colors.black12);
    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (color ?? context.primary).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: (color ?? context.primary).withValues(alpha: 0.2),
                  ),
                ),
                child: Icon(icon, size: 20, color: color ?? context.primary),
              ),
              if (!isLast)
                Expanded(child: Container(width: 2, color: themeColor)),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: context.textColor,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        duration,
                        style: TextStyle(
                          color: context.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: TextStyle(color: context.textMuted, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Marketplace CTA ───────────────────────────────────────────────────────

class _MarketplaceCtaSection extends StatelessWidget {
  final Crop crop;
  const _MarketplaceCtaSection({required this.crop});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16, right: 4),
          child: Text(
            'تجهيزات الزراعة',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: context.textColor,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: _BentoCard(
                title: 'البذور والشتلات',
                subtitle: 'أجود الأنواع',
                icon: Icons.spa_rounded,
                color: context.primary,
                onTap: () => context.go('/marketplace'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: _BentoCard(
                title: 'حاسبة الأسمدة',
                subtitle: 'تغذية كاملة',
                icon: Icons.calculate_rounded,
                color: Colors.blueAccent,
                onTap: () => context.push('/fertilizer_calculator'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _BentoCard(
          title: 'احصل على كل ما تحتاجه لزراعة ${crop.name}',
          subtitle: 'تصفح كافة منتجات ${crop.category} في متجر زرعة',
          icon: Icons.shopping_basket_rounded,
          color: Colors.orange,
          isFullWidth: true,
          onTap: () => context.go('/marketplace'),
        ),
      ],
    );
  }
}

class _BentoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isFullWidth;

  const _BentoCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                if (isFullWidth) ...[
                  const Spacer(),
                  Icon(Icons.arrow_forward_ios_rounded, color: color, size: 14),
                ],
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isFullWidth ? 16 : 14,
                color: context.textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: context.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── About Card ────────────────────────────────────────────────────────────

class _AboutCard extends StatelessWidget {
  final Crop crop;
  final bool isDark;

  const _AboutCard({required this.crop, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: context.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.eco_rounded,
                  color: context.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'نبذة عن النبتة',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  color: context.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            crop.description,
            style: TextStyle(
              fontSize: 16,
              color: context.textColor.withValues(alpha: 0.8),
              height: 1.7,
            ),
          ),
          if (crop.scientificDefinition != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: context.border.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                crop.scientificDefinition!,
                style: TextStyle(
                  fontSize: 14,
                  color: context.textMuted,
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Premium Section Wrapper ───────────────────────────────────────────────

class _PremiumSectionWrapper extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _PremiumSectionWrapper({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8, bottom: 20),
          child: Row(
            children: [
              Icon(
                icon,
                color: context.primary.withValues(alpha: 0.5),
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: context.textColor.withValues(alpha: 0.6),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Divider(color: context.border.withValues(alpha: 0.3)),
              ),
            ],
          ),
        ),
        ...children,
      ],
    );
  }
}
