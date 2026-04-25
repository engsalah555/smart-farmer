import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants.dart';
import '../../../core/widgets/atoms/pro_max_icon_button.dart';
import '../providers/iot_provider.dart';

class IotLandingPage extends StatelessWidget {
  const IotLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IotProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.getBackground(isDark),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  _buildHeaderIcon(),
                  const SizedBox(height: 32),
                  _buildMainTitle(isDark),
                  const SizedBox(height: 16),
                  _buildSubTitle(),
                  const SizedBox(height: 48),
                  _buildFeatureList(isDark),
                  const SizedBox(height: 60),
                  _buildSubscribeButton(context, provider),
                  const SizedBox(height: 24),
                  _buildFooterInfo(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
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
            'خدمة الري الذكي',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderIcon() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.settings_input_component_rounded,
        size: 80,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildMainTitle(bool isDark) {
    return Text(
      'حول مزرعتك إلى مزرعة ذكية',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w900,
        
        color: AppColors.getTextColor(isDark),
        height: 1.2,
      ),
    );
  }

  Widget _buildSubTitle() {
    return const Text(
      'استخدم أحدث تقنيات IoT لمراقبة مزرعتك والتحكم بالري من أي مكان في العالم.',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 16,
        color: Colors.grey,
        
      ),
    );
  }

  Widget _buildFeatureList(bool isDark) {
    return Column(
      children: [
        _buildFeatureItem(
          icon: Icons.speed_rounded,
          title: 'مراقبة لحظية',
          desc: 'شاهد قراءات الحرارة والرطوبة مباشرة على هاتفك.',
          color: Colors.orange,
          isDark: isDark,
        ),
        const SizedBox(height: 20),
        _buildFeatureItem(
          icon: Icons.water_drop_rounded,
          title: 'ري ذكي',
          desc: 'وفر في استهلاك المياه مع الري المجدول والتلقائي.',
          color: Colors.blue,
          isDark: isDark,
        ),
        const SizedBox(height: 20),
        _buildFeatureItem(
          icon: Icons.security_rounded,
          title: 'تحكم آمن',
          desc: 'إدارة كاملة لمضخات المياه عن بعد بكل أمان.',
          color: Colors.green,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String desc,
    required Color color,
    required bool isDark,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  
                  color: AppColors.getTextColor(isDark),
                ),
              ),
              Text(
                desc,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubscribeButton(BuildContext context, IotProvider provider) {
    return Container(
      width: double.infinity,
      height: 65,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () => _handleRequest(context, provider),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
        ),
        child: const Text(
          'طلب تفعيل الخدمة الآن',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            
          ),
        ),
      ),
    );
  }

  Widget _buildFooterInfo() {
    return const Text(
      'عند طلب الخدمة، سيقوم فريقنا بالتواصل معك لتجهيز الحساسات وتركيب النظام في مزرعتك.',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 12,
        color: Colors.grey,
        fontStyle: FontStyle.italic,
        
      ),
    );
  }

  void _handleRequest(BuildContext context, IotProvider provider) async {
    final success = await provider.requestService();
    if (success) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إرسال طلبك بنجاح. سنقوم بمراجعته قريباً.', style: TextStyle()),
            backgroundColor: Colors.green,
          ),
        );
        provider.fetchStatus(); // Refresh to show pending state
      }
    }
  }
}
