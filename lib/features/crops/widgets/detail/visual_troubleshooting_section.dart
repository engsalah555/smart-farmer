import 'package:flutter/material.dart';
import '../../../../core/constants.dart';
import '../../../../core/models/crop_model.dart';
import '../shared/plant_section_header.dart';

class VisualTroubleshootingSection extends StatefulWidget {
  final Crop crop;
  const VisualTroubleshootingSection({super.key, required this.crop});

  @override
  State<VisualTroubleshootingSection> createState() => _VisualTroubleshootingSectionState();
}

class _VisualTroubleshootingSectionState extends State<VisualTroubleshootingSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final pestsText = widget.crop.pestsAndDiseases ?? widget.crop.careGuide?.pestsAndDiseases;
    if (pestsText == null || pestsText.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PlantSectionHeader(
          title: 'دليل المشاكل والآفات',
          icon: Icons.bug_report_rounded,
        ),
        const SizedBox(height: 16),
        
        // Problem Cards Area with AnimatedSize for smooth expansion
        AnimatedSize(
          duration: const Duration(milliseconds: 500),
          curve: Curves.fastOutSlowIn,
          alignment: Alignment.topCenter,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!_isExpanded)
                _buildHorizontalList()
              else
                _buildExpandedGrid(context),
              
              const SizedBox(height: 16),
              
              // View All / Show Less Button
              Center(
                child: InkWell(
                  onTap: () => setState(() => _isExpanded = !_isExpanded),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: context.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: context.primary.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.grid_view_rounded,
                          size: 18,
                          color: context.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isExpanded ? 'طي القائمة' : 'عرض كافة المشاكل',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: context.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),
        
        // Detailed Text Section
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: context.cardBackground,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: context.border.withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: context.primary, size: 18),
                  const SizedBox(width: 8),
                  const Text(
                    'نصائح الوقاية والعلاج:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                pestsText,
                style: TextStyle(
                  fontSize: 14,
                  color: context.textMuted,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalList() {
    final items = _getProblems();
    return SizedBox(
      height: 170,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: items.length.clamp(0, 4),
        padding: const EdgeInsets.symmetric(vertical: 4),
        itemBuilder: (context, index) {
          final item = items[index];
          return _ProblemCard(
            title: item.title,
            symptom: item.symptom,
            icon: item.icon,
            color: item.color,
          );
        },
      ),
    );
  }

  Widget _buildExpandedGrid(BuildContext context) {
    final items = _getProblems();
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width > 600 ? 3 : 2;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: crossAxisCount == 3 ? 0.9 : 0.85,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return _ProblemCard(
          title: item.title,
          symptom: item.symptom,
          icon: item.icon,
          color: item.color,
          isFullWidth: true,
        );
      },
    );
  }

  List<_ProblemItem> _getProblems() {
    // In a real app, this would be parsed from the crop's pests field
    // For now, we provide a robust set of common agricultural problems
    return [
      _ProblemItem(
        title: 'نقص النيتروجين',
        symptom: 'اصفرار الأوراق القديمة من الأسفل للأعلى مع ضعف عام في النمو.',
        icon: Icons.warning_amber_rounded,
        color: Colors.amber,
      ),
      _ProblemItem(
        title: 'حشرة المن',
        symptom: 'تجمع حشرات صغيرة لزجة (خضراء أو سوداء) تحت الأوراق وقمم النموات.',
        icon: Icons.pest_control_rounded,
        color: Colors.redAccent,
      ),
      _ProblemItem(
        title: 'البياض الدقيقي',
        symptom: 'ظهور بقع بيضاء مسحوقية على الأوراق تشبه الطحين.',
        icon: Icons.cloud_rounded,
        color: Colors.blueGrey,
      ),
      _ProblemItem(
        title: 'عفن الجذور',
        symptom: 'ذبول مفاجئ للنبتة رغم رطوبة التربة، مع تلون الساق بالسواد.',
        icon: Icons.opacity_rounded,
        color: Colors.brown,
      ),
      _ProblemItem(
        title: 'نقص الفسفور',
        symptom: 'تلون الأوراق القديمة باللون الأرجواني أو البنفسجي الداكن.',
        icon: Icons.science_rounded,
        color: Colors.deepPurple,
      ),
      _ProblemItem(
        title: 'العنكبوت الأحمر',
        symptom: 'نقاط صفراء دقيقة على الأوراق مع وجود خيوط عنكبوتية رقيقة جداً.',
        icon: Icons.bug_report_rounded,
        color: Colors.orange,
      ),
      _ProblemItem(
        title: 'نقص البوتاسيوم',
        symptom: 'احتراق حواف الأوراق وتجعدها مع ضعف في جودة الثمار.',
        icon: Icons.bolt_rounded,
        color: Colors.orangeAccent,
      ),
      _ProblemItem(
        title: 'الذبابة البيضاء',
        symptom: 'حشرات بيضاء صغيرة جداً تطير عند تحريك النبتة وتسبب اصفراراً.',
        icon: Icons.flutter_dash_rounded,
        color: Colors.lightBlue,
      ),
    ];
  }
}

class _ProblemItem {
  final String title;
  final String symptom;
  final IconData icon;
  final Color color;

  _ProblemItem({
    required this.title,
    required this.symptom,
    required this.icon,
    required this.color,
  });
}

class _ProblemCard extends StatelessWidget {
  final String title;
  final String symptom;
  final IconData icon;
  final Color color;
  final bool isFullWidth;

  const _ProblemCard({
    required this.title,
    required this.symptom,
    required this.icon,
    required this.color,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isFullWidth ? double.infinity : 180,
      margin: EdgeInsetsDirectional.only(end: isFullWidth ? 0 : 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: context.textColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Text(
              symptom,
              style: TextStyle(
                fontSize: 11,
                color: context.textMuted,
                height: 1.4,
              ),
              maxLines: isFullWidth ? 4 : 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'عرض الحل',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: color,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.arrow_forward_ios_rounded, color: color, size: 8),
            ],
          ),
        ],
      ),
    );
  }
}
