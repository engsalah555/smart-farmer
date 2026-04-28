import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants.dart';
import '../../../core/models/crop_model.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/atoms/custom_image.dart';
import '../../../core/widgets/atoms/pro_max_icon_button.dart';
import '../providers/crops_provider.dart';

// --- Section Widgets ---
import '../widgets/detail/growth_conditions_section.dart';
import '../widgets/detail/cultivation_section.dart';
import '../widgets/detail/soil_nutrition_section.dart';
import '../widgets/detail/management_rotation_section.dart';
import '../widgets/detail/pests_harvest_sections.dart';
import '../widgets/detail/uses_benefits_section.dart';

class CropDetailScreen extends StatefulWidget {
  final Crop crop;
  const CropDetailScreen({super.key, required this.crop});

  @override
  State<CropDetailScreen> createState() => _CropDetailScreenState();
}

class _CropDetailScreenState extends State<CropDetailScreen> {
  bool _isAdding = false;

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
    if (success && Navigator.canPop(context)) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = widget.crop;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: CustomScrollView(
        slivers: [
          _HeroAppBar(
            crop: c,
            isDark: isDark,
            isAdding: _isAdding,
            onAdd: _addToMyCrops,
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: context.wp(5),
              vertical: context.hp(2),
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Overview
                if (c.description.isNotEmpty)
                  _AboutCard(crop: c, isDark: isDark),
                SizedBox(height: context.hp(3)),

                // 1. Growth Conditions
                GrowthConditionsSection(crop: c),
                SizedBox(height: context.hp(3)),

                // 2. Cultivation
                CultivationSection(crop: c),
                SizedBox(height: context.hp(3)),

                // 3. Soil & Nutrition + NPK + Fertilizer CTA
                SoilNutritionSection(crop: c),
                SizedBox(height: context.hp(3)),

                // 4. Compatibility & Rotation
                ManagementRotationSection(crop: c),
                SizedBox(height: context.hp(3)),

                // 5. Pests
                PestsSection(crop: c),
                SizedBox(height: context.hp(3)),

                // 6. Harvest
                HarvestSection(crop: c),
                SizedBox(height: context.hp(3)),

                // 7. Uses & Benefits
                UsesBenefitsSection(crop: c),
                SizedBox(height: context.hp(12)),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Hero App Bar ──────────────────────────────────────────────────────────

class _HeroAppBar extends StatelessWidget {
  final Crop crop;
  final bool isDark;
  final bool isAdding;
  final VoidCallback onAdd;

  const _HeroAppBar({
    required this.crop,
    required this.isDark,
    required this.isAdding,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: context.hp(55),
      pinned: true,
      stretch: true,
      elevation: 0,
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.white,
      leading: Padding(
        padding: EdgeInsets.all(context.wp(2)),
        child: ProMaxIconButton(
          icon: Icons.arrow_back_ios_new_rounded,
          onTap: () => Navigator.canPop(context)
              ? Navigator.pop(context)
              : context.go('/home'),
          size: context.wp(10),
          iconSize: context.wp(4),
          backgroundColor: Colors.black.withValues(alpha: 0.3),
          color: Colors.white,
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
        collapseMode: CollapseMode.parallax,
        background: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: 'crop-${crop.id}',
              child: CustomImage(imageUrl: crop.imageUrl, fit: BoxFit.cover),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black45,
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black54,
                    Colors.black87,
                  ],
                  stops: [0.0, 0.3, 0.6, 0.85, 1.0],
                ),
              ),
            ),
            Positioned(
              bottom: context.hp(3),
              left: context.wp(5),
              right: context.wp(5),
              child: _AppBarBottom(
                crop: crop,
                isAdding: isAdding,
                onAdd: onAdd,
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
  final VoidCallback onAdd;

  const _AppBarBottom({
    required this.crop,
    required this.isAdding,
    required this.onAdd,
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
                style: TextStyle(
                  color: Colors.white,
                  fontSize: context.sp(24),
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (crop.scientificName != null)
                Text(
                  crop.scientificName!,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: context.sp(13),
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
        ),
        SizedBox(width: context.wp(3)),
      ],
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
      padding: EdgeInsets.all(context.wp(5)),
      decoration: BoxDecoration(
        color: isDark
            ? context.primary.withValues(alpha: 0.08)
            : context.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(context.wp(5)),
        border: Border.all(color: context.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.eco_rounded,
                color: context.primary,
                size: context.sp(18),
              ),
              SizedBox(width: context.wp(2)),
              Text(
                'نبذة عن النبتة',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: context.sp(16),
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: context.hp(1.2)),
          Text(
            crop.description,
            style: TextStyle(
              fontSize: context.sp(13),
              color: isDark ? Colors.white70 : Colors.black87,
              height: 1.6,
            ),
          ),
          if (crop.scientificDefinition != null) ...[
            SizedBox(height: context.hp(1)),
            Text(
              crop.scientificDefinition!,
              style: TextStyle(
                fontSize: context.sp(12),
                color: isDark ? Colors.white54 : Colors.black54,
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
