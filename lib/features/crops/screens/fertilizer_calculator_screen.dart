import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/theme/app_typography.dart';
import '../models/fertilizer_models.dart';
import '../services/fertilizer_engine.dart';
import '../widgets/calculator/crop_tab.dart';
import '../widgets/calculator/area_tab.dart';
import '../widgets/calculator/soil_tab.dart';
import '../widgets/calculator/result_sheet.dart';
import '../../../core/widgets/atoms/pro_max_icon_button.dart';

class FertilizerCalculatorScreen extends StatefulWidget {
  const FertilizerCalculatorScreen({super.key});

  @override
  State<FertilizerCalculatorScreen> createState() =>
      _FertilizerCalculatorScreenState();
}

class _FertilizerCalculatorScreenState extends State<FertilizerCalculatorScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  late final AnimationController _pulseController;
  // State Management
  CropFertilizerProfile? _selectedCrop;
  String _activeCategory = 'الكل';

  // Controllers for Area & Yield
  final _areaCtrl = TextEditingController(text: '1');
  final _yieldCtrl = TextEditingController();
  String _areaUnit = 'هكتار';
  final List<String> _unitOptions = ['م²', 'دونم', 'هكتار', 'فدان'];

  // Controllers for Soil Analysis
  final _nCtrl = TextEditingController(text: '20');
  final _pCtrl = TextEditingController(text: '10');
  final _kCtrl = TextEditingController(text: '120');
  final _phCtrl = TextEditingController(text: '7.0');

  final List<String> _categories = [
    'الكل',
    'حبوب',
    'خضروات',
    'فاكهة',
    'نخيل',
    'أعلاف',
    'شجري',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pulseController.dispose();
    _areaCtrl.dispose();
    _yieldCtrl.dispose();
    _nCtrl.dispose();
    _pCtrl.dispose();
    _kCtrl.dispose();
    _phCtrl.dispose();
    super.dispose();
  }

  double get _calculatedAreaHa {
    final areaValue = double.tryParse(_areaCtrl.text) ?? 0.0;
    switch (_areaUnit) {
      case 'م²':
        return areaValue / 10000;
      case 'دونم':
        return areaValue * 0.10;
      case 'فدان':
        return areaValue * 0.42;
      default:
        return areaValue;
    }
  }

  void _onCalculate() {
    if (_selectedCrop == null) {
      _notifyUser('اختر المحصول أولاً 🌱', Colors.orange);
      return;
    }

    final targetYield =
        double.tryParse(_yieldCtrl.text) ?? _selectedCrop!.avgYield;

    final recommendation = FertilizerEngine.calculate(
      crop: _selectedCrop!,
      areaHa: _calculatedAreaHa,
      targetYieldTonHa: targetYield,
      soil: SoilTestResult(
        availableN: double.tryParse(_nCtrl.text) ?? 20,
        availableP: double.tryParse(_pCtrl.text) ?? 10,
        availableK: double.tryParse(_kCtrl.text) ?? 120,
        ph: double.tryParse(_phCtrl.text) ?? 7.0,
      ),
    );

    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => ResultSheet(
          result: recommendation,
          crop: _selectedCrop!,
          areaHa: _calculatedAreaHa,
          areaDisplay: '${_areaCtrl.text} $_areaUnit',
          yieldDisplay: '${targetYield.toStringAsFixed(1)} طن/هكتار',
          ph: double.tryParse(_phCtrl.text) ?? 7.0,
        ),
      );
    });
  }

  void _notifyUser(String message, Color bgColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: AppTypography.bodyMedium(isDark: isDark)),
        backgroundColor: bgColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark
            ? const Color(0xFF0F1A0F)
            : const Color(0xFFF1F5F0),
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            _buildPremiumAppBar(isDark),
          ],
          body: Column(
            children: [
              _buildModernTabBar(isDark),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    CropTab(
                      cats: _categories,
                      selectedCat: _activeCategory,
                      selectedCrop: _selectedCrop,
                      onCatChanged: (cat) =>
                          setState(() => _activeCategory = cat),
                      onCropSelected: (crop) {
                        setState(() {
                          _selectedCrop = crop;
                          _yieldCtrl.text = crop.avgYield.toString();
                        });
                        Future.delayed(const Duration(milliseconds: 400), () {
                          _tabController.animateTo(1);
                        });
                      },
                      isDark: isDark,
                    ),
                    AreaTab(
                      crop: _selectedCrop,
                      areaCtrl: _areaCtrl,
                      yieldCtrl: _yieldCtrl,
                      areaUnit: _areaUnit,
                      areaUnits: _unitOptions,
                      areaHa: _calculatedAreaHa,
                      onUnitChanged: (unit) => setState(() => _areaUnit = unit),
                      onAreaChanged: () => setState(() {}),
                      onNext: () => _tabController.animateTo(2),
                      isDark: isDark,
                    ),
                    SoilTab(
                      nCtrl: _nCtrl,
                      pCtrl: _pCtrl,
                      kCtrl: _kCtrl,
                      phCtrl: _phCtrl,
                      onPhChange: () => setState(() {}),
                      onCalculate: _onCalculate,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomActionBar(isDark),
      ),
    );
  }

  Widget _buildPremiumAppBar(bool isDark) {
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
                  context.go('/crops');
                }
              },
              size: 40,
              iconSize: 18,
              backgroundColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
              color: isDark ? Colors.white : AppColors.deepGreen,
            ),
            const SizedBox(width: 12),
            const Text(
              'حاسبة الأسمدة',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 26,
                
              ),
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

  Widget _buildModernTabBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: isDark ? const Color(0xFF131B13) : Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          gradient: AppDecorations.primaryGradient,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        labelStyle: AppTypography.bodyMedium(isDark: isDark).copyWith(fontWeight: FontWeight.bold),
        unselectedLabelStyle: AppTypography.bodyMedium(isDark: isDark),
        tabs: const [
          Tab(text: 'المحصول'),
          Tab(text: 'المساحة'),
          Tab(text: 'التربة'),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(bool isDark) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        math.max(24, MediaQuery.paddingOf(context).bottom),
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131B13) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (_selectedCrop != null)
              Expanded(child: _buildSelectionSummary(isDark))
            else
              Expanded(
                child: Text(
                  '🌱 اختر محصولاً للبدء',
                  style: AppTypography.bodyMedium(isDark: isDark).copyWith(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
              ),
            const SizedBox(width: 16),
            _buildCalculateButton(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionSummary(bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            _selectedCrop!.emoji,
            style: const TextStyle(fontSize: 22),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _selectedCrop!.name,
              style: AppTypography.bodyLarge(isDark: isDark).copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Text(
              '${_areaCtrl.text} $_areaUnit',
              style: AppTypography.valueLabel(isDark: isDark).copyWith(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCalculateButton(bool isDark) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.bolt_rounded, size: 22),
      label: Text(
        'احسب النتائج',
        style: AppTypography.buttonLabel(isDark: isDark).copyWith(fontWeight: FontWeight.bold),
      ),
      onPressed: _selectedCrop != null ? _onCalculate : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 6,
        shadowColor: AppColors.secondary.withValues(alpha: 0.4),
      ),
    );
  }
}

class _AnimatedMeshBackground extends StatefulWidget {
  @override
  State<_AnimatedMeshBackground> createState() =>
      _AnimatedMeshBackgroundState();
}

class _AnimatedMeshBackgroundState extends State<_AnimatedMeshBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          color: const Color(0xFF0F1A0F),
          child: Stack(
            children: [
              _AnimatedBlob(
                controller: _controller,
                basePos: const Offset(0.7, -0.3),
                moveRadius: 0.15,
                size: constraints.maxHeight * 1.5,
                color: AppColors.primary.withValues(alpha: 0.4),
                speedMult: 1.0,
              ),
              _AnimatedBlob(
                controller: _controller,
                basePos: const Offset(-0.3, 0.6),
                moveRadius: 0.2,
                size: constraints.maxHeight * 1.3,
                color: AppColors.secondary.withValues(alpha: 0.3),
                speedMult: 0.8,
              ),
              _AnimatedBlob(
                controller: _controller,
                basePos: const Offset(0.4, 0.5),
                moveRadius: 0.1,
                size: constraints.maxHeight * 1.0,
                color: const Color(0xFFC6FF00).withValues(alpha: 0.2),
                speedMult: 1.2,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AnimatedBlob extends StatelessWidget {
  final AnimationController controller;
  final Offset basePos;
  final double moveRadius;
  final double size;
  final Color color;
  final double speedMult;

  const _AnimatedBlob({
    required this.controller,
    required this.basePos,
    required this.moveRadius,
    required this.size,
    required this.color,
    required this.speedMult,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final t = controller.value * 2 * math.pi * speedMult;
        final dx = basePos.dx + (moveRadius * 1.2 * math.sin(t));
        final dy = basePos.dy + (moveRadius * math.cos(t * 0.7));

        return Positioned(
          left: dx * MediaQuery.of(context).size.width,
          top: dy * 240,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color,
                  blurRadius: size * 0.7,
                  spreadRadius: size * 0.1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
