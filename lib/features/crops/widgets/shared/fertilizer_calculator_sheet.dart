import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/models/crop_model.dart';
import '../../../../core/constants.dart';
import '../../utils/crop_calculator.dart';

/// Fertilizer calculator bottom sheet.
/// User enters farm area → gets actual N/P/K kg quantities.
class FertilizerCalculatorSheet extends StatefulWidget {
  final Crop crop;

  const FertilizerCalculatorSheet({super.key, required this.crop});

  static Future<void> show(BuildContext context, Crop crop) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FertilizerCalculatorSheet(crop: crop),
    );
  }

  @override
  State<FertilizerCalculatorSheet> createState() =>
      _FertilizerCalculatorSheetState();
}

class _FertilizerCalculatorSheetState extends State<FertilizerCalculatorSheet> {
  final _areaController = TextEditingController(text: '1.0');
  NpkResult? _result;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    final area = double.tryParse(_areaController.text);
    if (area != null && area > 0) {
      setState(() => _result = widget.crop.calculateNpkForArea(area));
    }
  }

  @override
  void dispose() {
    _areaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : Colors.white;

    return Container(
      margin: const EdgeInsets.only(top: 80),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 1,
        minChildSize: 0.5,
        maxChildSize: 1,
        expand: false,
        builder: (_, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: context.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.calculate_rounded,
                      color: context.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'حاسبة الأسمدة',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          widget.crop.name,
                          style: TextStyle(
                            fontSize: 13,
                            color: context.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              Text(
                'مساحة المزرعة (هكتار)',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _areaController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                onChanged: (_) => _calculate(),
                decoration: InputDecoration(
                  suffixText: 'هكتار',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.primary, width: 2),
                  ),
                  fillColor: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.grey.withValues(alpha: 0.05),
                  filled: true,
                ),
              ),
              const SizedBox(height: 32),

              if (_result != null && !_result!.isEmpty) ...[
                Text(
                  'الكميات المطلوبة (كجم)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                _ResultRow(
                  symbol: 'N',
                  name: 'نيتروجين',
                  value: _result!.nitrogen,
                ),
                const SizedBox(height: 12),
                _ResultRow(
                  symbol: 'P',
                  name: 'فسفور',
                  value: _result!.phosphorus,
                ),
                const SizedBox(height: 12),
                _ResultRow(
                  symbol: 'K',
                  name: 'بوتاسيوم',
                  value: _result!.potassium,
                ),
                const SizedBox(height: 32),
              ],

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: isDark ? Colors.white70 : Colors.black54,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'تنبيه',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'هذه الحاسبة توفر تقديرات تقريبية بناءً على المعايير العامة. ننصح دائماً بإجراء تحليل للتربة واستشارة خبير زراعي للحصول على أفضل النتائج لمحصولك.',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.white70 : Colors.black87,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'إغلاق',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String symbol;
  final String name;
  final double? value;

  const _ResultRow({
    required this.symbol,
    required this.name,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: context.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                symbol,
                style: TextStyle(
                  color: context.primary,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            value != null ? '${value!.toStringAsFixed(1)} كجم' : '—',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
