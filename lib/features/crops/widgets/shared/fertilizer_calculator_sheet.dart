import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/models/crop_model.dart';
import '../../../../core/utils/responsive.dart';
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
    final bg = isDark ? const Color(0xFF1E2A1A) : const Color(0xFFF5F9F2);

    return Container(
      margin: EdgeInsets.only(top: context.hp(10)),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.wp(7)),
        ),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 1,
        expand: false,
        builder: (_, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: EdgeInsets.fromLTRB(
            context.wp(6),
            context.hp(2),
            context.wp(6),
            context.hp(4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: context.wp(12),
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: context.hp(2)),

              // Title
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(context.wp(2.5)),
                    decoration: BoxDecoration(
                      color: context.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(context.wp(3)),
                    ),
                    child: Icon(
                      Icons.calculate_rounded,
                      color: context.primary,
                      size: context.sp(22),
                    ),
                  ),
                  SizedBox(width: context.wp(3)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'حاسبة الأسمدة',
                          style: TextStyle(
                            fontSize: context.sp(18),
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          widget.crop.name,
                          style: TextStyle(
                            fontSize: context.sp(12),
                            color: context.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.hp(3)),

              // Area input
              Text(
                'مساحة المزرعة (هكتار)',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: context.sp(13),
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              SizedBox(height: context.hp(1)),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _areaController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d*'),
                        ),
                      ],
                      onChanged: (_) => _calculate(),
                      decoration: InputDecoration(
                        suffixText: 'هكتار',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(context.wp(3)),
                          borderSide: BorderSide(
                            color: context.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(context.wp(3)),
                          borderSide: BorderSide(color: context.primary),
                        ),
                        fillColor: isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.white,
                        filled: true,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.hp(3)),

              // Results
              if (_result != null && !_result!.isEmpty) ...[
                Text(
                  'الكميات المطلوبة',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: context.sp(15),
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: context.hp(1.5)),
                _ResultRow(
                  symbol: 'N',
                  name: 'نيتروجين',
                  value: _result!.nitrogen,
                  color: Colors.green,
                ),
                SizedBox(height: context.hp(1)),
                _ResultRow(
                  symbol: 'P',
                  name: 'فسفور',
                  value: _result!.phosphorus,
                  color: Colors.purple,
                ),
                SizedBox(height: context.hp(1)),
                _ResultRow(
                  symbol: 'K',
                  name: 'بوتاسيوم',
                  value: _result!.potassium,
                  color: Colors.orange,
                ),
                SizedBox(height: context.hp(3)),
              ],

              // Warning
              Container(
                padding: EdgeInsets.all(context.wp(4)),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(context.wp(3)),
                  border: Border.all(
                    color: Colors.amber.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.amber.shade700,
                      size: context.sp(18),
                    ),
                    SizedBox(width: context.wp(3)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'تحذير هام',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.amber.shade800,
                              fontSize: context.sp(13),
                            ),
                          ),
                          SizedBox(height: context.hp(0.5)),
                          Text(
                            'يرجى الحرص التام على أن تكون البيانات المدخلة دقيقة علمياً ومطابقة للممارسات الزراعية المعتمدة. أي خطأ في أرقام التسميد (NPK) قد يؤدي إلى ضرر حقيقي للمحصول. يجب الاعتماد على مراجع زراعية موثوقة.',
                            style: TextStyle(
                              fontSize: context.sp(11),
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
              SizedBox(height: context.hp(2)),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: context.hp(1.8)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(context.wp(4)),
                    ),
                  ),
                  child: Text(
                    'إغلاق',
                    style: TextStyle(
                      fontSize: context.sp(15),
                      fontWeight: FontWeight.bold,
                    ),
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
  final Color color;

  const _ResultRow({
    required this.symbol,
    required this.name,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.wp(4),
        vertical: context.hp(1.2),
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.1 : 0.07),
        borderRadius: BorderRadius.circular(context.wp(3)),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: context.wp(9),
            height: context.wp(9),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                symbol,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w900,
                  fontSize: context.sp(16),
                ),
              ),
            ),
          ),
          SizedBox(width: context.wp(3)),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
                fontSize: context.sp(13),
              ),
            ),
          ),
          Text(
            value != null ? '${value!.toStringAsFixed(1)} kg' : '—',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: context.sp(15),
            ),
          ),
        ],
      ),
    );
  }
}
