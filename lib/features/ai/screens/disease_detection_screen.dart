import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/constants.dart';
import '../../../core/services/locator.dart';
import '../services/plant_diagnosis_service.dart';
import '../widgets/camera_view.dart';

class DiseaseDetectionScreen extends StatefulWidget {
  const DiseaseDetectionScreen({super.key});

  @override
  State<DiseaseDetectionScreen> createState() => _DiseaseDetectionScreenState();
}

class _DiseaseDetectionScreenState extends State<DiseaseDetectionScreen>
    with TickerProviderStateMixin {
  final _service = locator<PlantDiagnosisService>();
  final _picker = ImagePicker();

  XFile? _image;
  Uint8List? _imageBytes;
  bool _isLoading = false;
  PlantDiagnosisResult? _result;

  late final AnimationController _pulseCtrl;
  late final AnimationController _resultCtrl;
  late final Animation<double> _pulseAnim;
  late final Animation<double> _resultFade;
  late final Animation<Offset> _resultSlide;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _resultCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _resultFade = CurvedAnimation(parent: _resultCtrl, curve: Curves.easeOut);
    _resultSlide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _resultCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _resultCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      XFile? file;
      if (source == ImageSource.camera) {
        final cameras = await availableCameras();
        if (cameras.isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('لم يتم العثور على كاميرا')),
            );
          }
          return;
        }
        if (!mounted) return;
        file = await Navigator.push<XFile>(
          context,
          MaterialPageRoute(builder: (_) => CameraView(cameras: cameras)),
        );
      } else {
        file = await _picker.pickImage(
          source: source,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 80,
        );
      }

      if (file == null) return;
      final bytes = await file.readAsBytes();
      _pulseCtrl.stop();
      setState(() {
        _image = file;
        _imageBytes = bytes;
        _result = null;
      });
      _resultCtrl.reset();
      await _analyze();
    } catch (e) {
      debugPrint('Pick image error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء التقاط الصورة: $e')),
        );
      }
    }
  }

  Future<void> _analyze() async {
    if (_imageBytes == null) return;
    setState(() => _isLoading = true);
    final result = await _service.diagnose(_imageBytes!);
    if (mounted) {
      setState(() {
        _isLoading = false;
        _result = result;
      });
      _resultCtrl.forward();
    }
  }

  void _reset() {
    _resultCtrl.reset();
    _pulseCtrl.repeat(reverse: true);
    setState(() {
      _image = null;
      _imageBytes = null;
      _result = null;
    });
  }

  bool get _isError => _result?.diseaseType == 'خطأ في التشخيص';

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final surface = context.surface;

    return Scaffold(
      backgroundColor: context.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                children: [
                  _buildImageArea(isDark, surface),
                  const SizedBox(height: 24),
                  if (_isLoading) _buildShimmerResults(),
                  if (!_isLoading && _result == null) _buildPickButtons(),
                  if (!_isLoading && _result != null && _isError)
                    FadeTransition(
                      opacity: _resultFade,
                      child: SlideTransition(
                        position: _resultSlide,
                        child: _buildErrorCard(surface),
                      ),
                    ),
                  if (!_isLoading && _result != null && !_isError)
                    FadeTransition(
                      opacity: _resultFade,
                      child: SlideTransition(
                        position: _resultSlide,
                        child: _buildResults(surface),
                      ),
                    ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── App Bar — flat surface, no decorative gradient ──
  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 100,
      floating: false,
      pinned: true,
      backgroundColor: context.surface,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: context.textColor,
          size: 20,
        ),
        tooltip: 'رجوع',
        onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'الفحص الذكي للنباتات',
          style: TextStyle(
            color: context.textColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
    );
  }

  // ── Image area — responsive height ──
  Widget _buildImageArea(bool isDark, Color surface) {
    final h = (MediaQuery.of(context).size.height * 0.3).clamp(200.0, 320.0);

    return Container(
      height: h,
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _image != null
              ? context.primary.withValues(alpha: 0.4)
              : context.border,
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: _image != null
          ? Stack(
              fit: StackFit.expand,
              children: [
                Image.file(File(_image!.path), fit: BoxFit.cover),
                if (_isLoading)
                  Container(
                    color: context.black.withValues(alpha: 0.45),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: context.white,
                        strokeWidth: 3,
                      ),
                    ),
                  ),
              ],
            )
          : _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ScaleTransition(
          scale: _pulseAnim,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: context.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.biotech_rounded,
              size: 56,
              color: context.primary,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'التقط صورة نبتتك',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: context.textColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'سيقوم الذكاء الاصطناعي بتشخيص\nحالة النبتة وتقديم تقرير شامل',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: context.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // ── Shimmer — uses token system ──
  Widget _buildShimmerResults() {
    return Shimmer.fromColors(
      baseColor: context.shimmerBase,
      highlightColor: context.shimmerHighlight,
      child: Column(
        children: [
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: context.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(
            2,
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                height: 80,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: context.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Error card ──
  Widget _buildErrorCard(Color surface) {
    final r = _result!;
    return Semantics(
      label: 'خطأ في التشخيص: ${r.diseaseCauses}',
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: context.error.withValues(alpha: 0.25)),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: context.error,
                  size: 40,
                ),
                const SizedBox(height: 16),
                Text(
                  'تعذر إتمام التشخيص',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: context.textColor,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  r.diseaseCauses,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _ActionButton(
            label: 'إعادة المحاولة',
            icon: Icons.refresh_rounded,
            filled: true,
            onTap: _analyze,
          ),
          const SizedBox(height: 12),
          _ActionButton(
            label: 'فحص نبتة أخرى',
            icon: Icons.camera_alt_rounded,
            filled: false,
            onTap: _reset,
          ),
        ],
      ),
    );
  }

  Widget _buildPickButtons() {
    return Column(
      children: [
        _ActionButton(
          label: 'فتح الكاميرا والتصوير',
          icon: Icons.camera_alt_rounded,
          filled: true,
          onTap: () => _pickImage(ImageSource.camera),
        ),
        const SizedBox(height: 12),
        _ActionButton(
          label: 'اختيار من معرض الصور',
          icon: Icons.photo_library_rounded,
          filled: false,
          onTap: () => _pickImage(ImageSource.gallery),
        ),
      ],
    );
  }

  // ── Results — varied layout, no identical cards ──
  Widget _buildResults(Color surface) {
    final r = _result!;
    return Semantics(
      label: 'نتيجة التشخيص',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _StatusCard(result: r),

          if (!r.isHealthy) ...[
            const SizedBox(height: 20),

            // Disease + causes — single section
            _buildSection(
              icon: Icons.coronavirus_rounded,
              iconColor: context.error,
              title: r.diseaseType,
              surface: surface,
              child: Text(
                r.diseaseCauses,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.7,
                  color: context.textSecondary,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Treatment plan
            _buildSection(
              icon: Icons.medical_services_rounded,
              iconColor: context.success,
              title: 'خطة العلاج',
              surface: surface,
              child: Text(
                r.treatmentMethods,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.7,
                  color: context.textSecondary,
                ),
              ),
            ),

            // Prevention tips — inline list, no card
            if (r.preventionTips.isNotEmpty) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      size: 18,
                      color: context.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'نصائح الوقاية',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: context.textColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              ...r.preventionTips.map(
                (tip) => Padding(
                  padding: const EdgeInsets.only(bottom: 6, right: 4, left: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '•  ',
                        style: TextStyle(color: context.primary, fontSize: 14),
                      ),
                      Expanded(
                        child: Text(
                          tip,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.5,
                            color: context.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),
          ],

          _ActionButton(
            label: 'فحص نبتة أخرى',
            icon: Icons.refresh_rounded,
            filled: true,
            onTap: _reset,
          ),
          const SizedBox(height: 12),
          _ActionButton(
            label: 'إعادة التصوير',
            icon: Icons.camera_alt_rounded,
            filled: false,
            onTap: () => _pickImage(ImageSource.camera),
          ),
        ],
      ),
    );
  }

  // ── Reusable section — replaces identical _DiagnosisCard ──
  Widget _buildSection({
    required IconData icon,
    required Color iconColor,
    required String title,
    required Color surface,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: context.textColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

// ─── Status Card — solid color, no glassmorphism ────────────────────────────────
class _StatusCard extends StatelessWidget {
  final PlantDiagnosisResult result;

  const _StatusCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final isHealthy = result.isHealthy;
    final color = isHealthy ? context.success : context.error;

    return Semantics(
      label:
          'حالة النبات: ${isHealthy ? "سليمة" : "مصابة، ${result.severity.label}"}',
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  isHealthy
                      ? Icons.check_circle_rounded
                      : Icons.healing_rounded,
                  color: context.white,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(
                        isHealthy
                            ? 'النبتة سليمة وصحية'
                            : 'تم اكتشاف إصابة مرضية',
                        style: TextStyle(
                          color: context.white.withValues(alpha: 0.9),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (!isHealthy) ...[
              const SizedBox(height: 12),
              Divider(color: context.white.withValues(alpha: 0.2), height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getSeverityIcon(result.severity),
                    color: context.white.withValues(alpha: 0.8),
                    size: 16,
                    semanticLabel: 'مستوى الخطورة',
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'مستوى الخطورة: ${result.severity.label}',
                    style: TextStyle(
                      color: context.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getSeverityIcon(DiagnosisSeverity severity) {
    switch (severity) {
      case DiagnosisSeverity.low:
        return Icons.info_outline_rounded;
      case DiagnosisSeverity.medium:
        return Icons.warning_amber_rounded;
      case DiagnosisSeverity.high:
        return Icons.report_problem_rounded;
      case DiagnosisSeverity.critical:
        return Icons.dangerous_rounded;
      case DiagnosisSeverity.unknown:
        return Icons.help_outline_rounded;
    }
  }
}

// ─── Action Button — Material+InkWell, semantic, no gradient ────────────────────
class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool filled;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(14);

    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: filled ? context.primary : Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: filled
                ? null
                : BoxDecoration(
                    borderRadius: radius,
                    border: Border.all(color: context.primary, width: 1.5),
                  ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: filled ? context.white : context.primary,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    color: filled ? context.white : context.primary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
