import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farm2/core/widgets/app_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/atoms/pro_max_icon_button.dart';
import '../models/fertilizer_models.dart';
import '../services/fertilizer_engine.dart';
import '../widgets/calculator/area_tab.dart';
import '../widgets/calculator/crop_tab.dart';
import '../widgets/calculator/soil_tab.dart';
import '../widgets/calculator/result_sheet.dart';

class FertilizerCalculatorScreen extends StatefulWidget {
  const FertilizerCalculatorScreen({super.key});

  @override
  State<FertilizerCalculatorScreen> createState() =>
      _FertilizerCalculatorScreenState();
}

class _FertilizerCalculatorScreenState
    extends State<FertilizerCalculatorScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentStep = 0;

  final _areaCtrl = TextEditingController(text: '1');
  final _yieldCtrl = TextEditingController();
  final _nCtrl = TextEditingController(text: '0');
  final _pCtrl = TextEditingController(text: '0');
  final _kCtrl = TextEditingController(text: '0');
  final _phCtrl = TextEditingController(text: '7.0');

  String _areaUnit = 'هكتار';
  final List<String> _unitOptions = ['هكتار', 'فدان', 'دونم'];
  String _activeCategory = 'الكل';
  CropFertilizerProfile? _selectedCrop;

  final List<String> _categories = [
    'الكل',
    'محاصيل حقلية',
    'خضروات',
    'أشجار فاكهة',
    'أعلاف',
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _areaCtrl.dispose();
    _yieldCtrl.dispose();
    _nCtrl.dispose();
    _pCtrl.dispose();
    _kCtrl.dispose();
    _phCtrl.dispose();
    super.dispose();
  }

  double get _calculatedAreaHa {
    final val = double.tryParse(_areaCtrl.text) ?? 0;
    switch (_areaUnit) {
      case 'فدان':
        return val * 0.42;
      case 'دونم':
        return val * 0.1;
      default:
        return val;
    }
  }

  void _onCalculate() {
    if (_selectedCrop == null) return;

    final rec = FertilizerEngine.calculate(
      crop: _selectedCrop!,
      areaHa: _calculatedAreaHa,
      targetYieldTonHa:
          double.tryParse(_yieldCtrl.text) ?? _selectedCrop!.avgYield,
      soil: SoilTestResult(
        availableN: double.tryParse(_nCtrl.text) ?? 0,
        availableP: double.tryParse(_pCtrl.text) ?? 0,
        availableK: double.tryParse(_kCtrl.text) ?? 0,
        ph: double.tryParse(_phCtrl.text) ?? 7.0,
      ),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ResultSheet(
        result: rec,
        crop: _selectedCrop!,
        areaHa: _calculatedAreaHa,
        areaDisplay: '$_areaUnit ${_areaCtrl.text}',
        yieldDisplay: '${_yieldCtrl.text} طن/هكتار',
        ph: double.tryParse(_phCtrl.text) ?? 7.0,
      ),
    );
  }

  void _nextStep() {
    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: Column(
        children: [
          _buildTopHeader(isDark),
          _buildStepProgressIndicator(isDark),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (idx) => setState(() => _currentStep = idx),
              physics: const NeverScrollableScrollPhysics(),
              children: [
                CropTab(
                  cats: _categories,
                  selectedCat: _activeCategory,
                  selectedCrop: _selectedCrop,
                  onCatChanged: (cat) => setState(() => _activeCategory = cat),
                  onCropSelected: (crop) {
                    setState(() {
                      _selectedCrop = crop;
                      _yieldCtrl.text = crop.avgYield.toString();
                    });
                    Future.delayed(
                      const Duration(milliseconds: 400),
                      _nextStep,
                    );
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
                  onNext: _nextStep,
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
      bottomNavigationBar: _buildBottomActionBar(isDark),
    );
  }

  Widget _buildTopHeader(bool isDark) {
    return Container(
      color: context.primary,
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 8,
        16,
        24,
      ),
      child: Row(
        children: [
          ProMaxIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/');
              }
            },
            size: 40,
            iconSize: 18,
            backgroundColor: Colors.white.withValues(alpha: 0.15),
            color: Colors.white,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'حاسبة الأسمدة الذكية',
                style: context.font20.bold.copyWith(
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'خطوات دقيقة لتغذية مثالية لمحصورك',
                style: context.font12.medium.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepProgressIndicator(bool isDark) {
    return Container(
      color: context.primary,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        decoration: BoxDecoration(
          color: context.backgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        child: Row(
          children: [
            _buildStepNode(0, 'المحصول', isDark),
            _buildStepConnector(0, isDark),
            _buildStepNode(1, 'المساحة', isDark),
            _buildStepConnector(1, isDark),
            _buildStepNode(2, 'التربة', isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildStepNode(int step, String label, bool isDark) {
    final isActive = _currentStep == step;
    final isCompleted = _currentStep > step;

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? context.primary
                : (isActive
                      ? context.primary.withValues(alpha: 0.1)
                      : Colors.transparent),
            border: Border.all(
              color: isActive || isCompleted ? context.primary : context.border,
              width: 1.5,
            ),
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                : Text(
                    '${step + 1}',
                    style: context.font12.bold.copyWith(
                      color: isActive ? context.primary : context.textMuted,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: context.font12.bold.copyWith(
            color: isActive ? context.primary : context.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector(int afterStep, bool isDark) {
    final isCompleted = _currentStep > afterStep;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 2,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: isCompleted ? context.primary : context.border,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActionBar(bool isDark) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (_currentStep > 0)
              ProMaxIconButton(
                icon: Icons.chevron_left_rounded,
                onTap: _prevStep,
                size: 52,
                backgroundColor: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.grey.shade100,
                color: isDark ? Colors.white70 : Colors.grey.shade700,
              ),
            if (_currentStep > 0) const SizedBox(width: 12),
            Expanded(
              child: _currentStep == 2
                  ? _buildCalculateButton(isDark)
                  : _buildNextButton(isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextButton(bool isDark) {
    final canProceed = _currentStep == 0 ? _selectedCrop != null : true;

    return ElevatedButton(
      onPressed: canProceed ? _nextStep : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: context.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.grey.shade100,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'المتابعة',
            style: context.font16.semiBold.copyWith(color: context.white),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculateButton(bool isDark) {
    return ElevatedButton.icon(
      label: Text(
        'استخراج التوصية الذكية',
        style: context.font16.copyWith(color: context.white),
      ),
      onPressed: _onCalculate,
      style: ElevatedButton.styleFrom(
        backgroundColor: context.secondary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
