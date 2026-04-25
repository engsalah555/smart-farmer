import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants.dart';
import '../../../core/widgets/atoms/pro_max_icon_button.dart';
import '../providers/iot_provider.dart';

class IotPendingPage extends StatelessWidget {
  const IotPendingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IotProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.getBackground(isDark),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, provider),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildPendingIllustration(),
                  const SizedBox(height: 48),
                  _buildStatusTitle(isDark),
                  const SizedBox(height: 16),
                  _buildStatusDescription(),
                  const SizedBox(height: 48),
                  _buildContactCard(isDark),
                  const SizedBox(height: 60),
                  _buildRefreshButton(provider),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, IotProvider provider) {
    return SliverAppBar(
      expandedHeight: 0,
      toolbarHeight: 70,
      pinned: true,
      backgroundColor: AppColors.primary,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          ProMaxIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.pop(context),
            size: 40,
            iconSize: 18,
          ),
          const SizedBox(width: 12),
          const Text(
            'حالة الطلب',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingIllustration() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
        ),
        const Icon(
          Icons.hourglass_empty_rounded,
          size: 70,
          color: Colors.orange,
        ),
        const Positioned(
          bottom: 10,
          right: 10,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusTitle(bool isDark) {
    return Text(
      'طلبك قيد المراجعة',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        
        color: AppColors.getTextColor(isDark),
      ),
    );
  }

  Widget _buildStatusDescription() {
    return const Text(
      'لقد تلقينا طلبك لتفعيل خدمة الري الذكي. فريقنا يعمل حالياً على مراجعة الطلب وسيتم التواصل معك لتركيب الجهاز وتفعيل الخدمة.',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 16,
        color: Colors.grey,
        
        height: 1.5,
      ),
    );
  }

  Widget _buildContactCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.support_agent_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'هل لديك استفسار؟',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    
                    color: AppColors.getTextColor(isDark),
                  ),
                ),
                const Text(
                  'فريق الدعم الفني جاهز لمساعدتك',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildRefreshButton(IotProvider provider) {
    return TextButton.icon(
      onPressed: () => provider.fetchStatus(),
      icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
      label: const Text(
        'تحديث الحالة',
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          
        ),
      ),
    );
  }
}
