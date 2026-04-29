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
      duration: const Duration(milliseconds: 700),
    );
    _resultFade = CurvedAnimation(parent: _resultCtrl, curve: Curves.easeOut);
    _resultSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
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
        // Use custom camera view for better stability
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
          MaterialPageRoute(
            builder: (_) => CameraView(cameras: cameras),
          ),
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
    setState(() {
      _image = null;
      _imageBytes = null;
      _result = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = context.background;
    final surface = context.surface;
    final textColor = context.textColor;

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(isDark, textColor),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                children: [
                  _buildImageArea(isDark, surface),
                  const SizedBox(height: 24),
                  if (_isLoading) _buildShimmerResults(isDark, surface),
                  if (!_isLoading && _result == null) _buildPickButtons(),
                  if (!_isLoading && _result != null)
                    FadeTransition(
                      opacity: _resultFade,
                      child: SlideTransition(
                        position: _resultSlide,
                        child: _buildResults(isDark, surface, textColor),
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

  Widget _buildAppBar(bool isDark, Color textColor) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: context.surface,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: textColor,
          size: 20,
        ),
        onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'الفحص الذكي للنباتات',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                context.primary.withValues(alpha: 0.12),
                AppColors.accent.withValues(alpha: 0.06),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageArea(bool isDark, Color surface) {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: context.primary.withValues(alpha: isDark ? 0.15 : 0.08),
            blurRadius: 24,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: _image != null
              ? context.primary.withValues(alpha: 0.4)
              : context.border,
          width: 1.5,
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
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    ),
                  ),
              ],
            )
          : _buildPlaceholder(isDark),
    );
  }

  Widget _buildPlaceholder(bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ScaleTransition(
          scale: _pulseAnim,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  context.primary.withValues(alpha: 0.18),
                  context.primary.withValues(alpha: 0.04),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.biotech_rounded,
              size: 64,
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
          'سيقوم الذكاء الاصطناعي بتشخيص\nحالة النبتة وتقديم تقرير طبي شامل',
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

  Widget _buildShimmerResults(bool isDark, Color surface) {
    return Shimmer.fromColors(
      baseColor: surface,
      highlightColor: surface.withValues(alpha: 0.5),
      child: Column(
        children: [
          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(
            3,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickButtons() {
    return Column(
      children: [
        _GradientButton(
          label: 'فتح الكاميرا والتصوير',
          icon: Icons.camera_alt_rounded,
          onTap: () => _pickImage(ImageSource.camera),
        ),
        const SizedBox(height: 14),
        _OutlineButton(
          label: 'اختيار من معرض الصور',
          icon: Icons.photo_library_rounded,
          onTap: () => _pickImage(ImageSource.gallery),
        ),
      ],
    );
  }

  Widget _buildResults(bool isDark, Color surface, Color textColor) {
    final r = _result!;
    return Column(
      children: [
        // ── بطاقة الحالة العامة ──
        _StatusCard(result: r, isDark: isDark),
        const SizedBox(height: 16),

        // ── بطاقات التشخيص التفصيلية ──
        if (!r.isHealthy) ...[
          _DiagnosisCard(
            icon: Icons.coronavirus_rounded,
            iconColor: context.error,
            title: 'نوع المرض',
            content: r.diseaseType,
            isDark: isDark,
            surface: surface,
          ),
          const SizedBox(height: 12),
          _DiagnosisCard(
            icon: Icons.warning_amber_rounded,
            iconColor: context.warning,
            title: 'أسباب الإصابة',
            content: r.diseaseCauses,
            isDark: isDark,
            surface: surface,
          ),
          const SizedBox(height: 12),
          _DiagnosisCard(
            icon: Icons.medical_services_rounded,
            iconColor: context.success,
            title: 'خطة العلاج',
            content: r.treatmentMethods,
            isDark: isDark,
            surface: surface,
          ),
          const SizedBox(height: 12),
          _DiagnosisCard(
            icon: Icons.shield_rounded,
            iconColor: context.primary,
            title: 'نصائح الوقاية',
            content: r.preventionTips.isEmpty
                ? 'لا توجد نصائح إضافية.'
                : r.preventionTips.map((e) => '• $e').join('\n'),
            isDark: isDark,
            surface: surface,
          ),
          const SizedBox(height: 24),
        ],

        // ── أزرار الإجراء ──
        _GradientButton(
          label: 'فحص نبتة أخرى',
          icon: Icons.refresh_rounded,
          onTap: _reset,
        ),
        const SizedBox(height: 14),
        _OutlineButton(
          label: 'إعادة التصوير',
          icon: Icons.camera_alt_rounded,
          onTap: () => _pickImage(ImageSource.camera),
        ),
      ],
    );
  }
}

// ─── Status Card ───────────────────────────────────────────────────────────────
class _StatusCard extends StatelessWidget {
  final PlantDiagnosisResult result;
  final bool isDark;

  const _StatusCard({required this.result, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isHealthy = result.isHealthy;
    final (gradStart, gradEnd, statusText, statusIcon) = isHealthy
        ? (
            context.success,
            context.success.withValues(alpha: 0.8),
            'النبتة سليمة وصحية 🌿',
            Icons.check_circle_rounded,
          )
        : (
            context.error,
            context.error.withValues(alpha: 0.8),
            'تم اكتشاف إصابة مرضية',
            Icons.healing_rounded,
          );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            gradStart,
            gradEnd,
            isHealthy
                ? context.success.withValues(alpha: 0.6)
                : _getSeverityColor(context, result.severity)
                    .withValues(alpha: 0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: gradStart.withValues(alpha: 0.5),
            blurRadius: 30,
            spreadRadius: 2,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.4),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(statusIcon, color: Colors.white, size: 36),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.plantName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      statusText,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.95),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!isHealthy) ...[
            const SizedBox(height: 16),
            const Divider(color: Colors.white24, height: 1),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getSeverityIcon(result.severity),
                  color: Colors.white70,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'مستوى الخطورة: ${result.severity.label}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _getSeverityColor(BuildContext context, DiagnosisSeverity severity) {
    switch (severity) {
      case DiagnosisSeverity.low:
        return context.primary;
      case DiagnosisSeverity.medium:
        return context.warning;
      case DiagnosisSeverity.high:
        return context.error;
      case DiagnosisSeverity.unknown:
        return context.textSecondary;
    }
  }

  IconData _getSeverityIcon(DiagnosisSeverity severity) {
    switch (severity) {
      case DiagnosisSeverity.low:
        return Icons.info_outline_rounded;
      case DiagnosisSeverity.medium:
        return Icons.warning_amber_rounded;
      case DiagnosisSeverity.high:
        return Icons.report_problem_rounded;
      case DiagnosisSeverity.unknown:
        return Icons.help_outline_rounded;
    }
  }
}

// ─── Diagnosis Card ─────────────────────────────────────────────────────────────
class _DiagnosisCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String content;
  final bool isDark;
  final Color surface;

  const _DiagnosisCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.content,
    required this.isDark,
    required this.surface,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [surface, iconColor.withValues(alpha: 0.03)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: iconColor.withValues(alpha: 0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? context.black.withValues(alpha: 0.3)
                : iconColor.withValues(alpha: 0.08),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      iconColor.withValues(alpha: 0.2),
                      iconColor.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: iconColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                    letterSpacing: -0.1,
                    color: iconColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              height: 1.7,
              color: context.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Gradient Button ────────────────────────────────────────────────────────────
class _GradientButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _GradientButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [context.primary, AppColors.accent],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: context.primary.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Outline Button ─────────────────────────────────────────────────────────────
class _OutlineButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _OutlineButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: context.primary, width: 1.8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: context.primary, size: 22),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: context.primary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
