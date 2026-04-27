import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/widgets/atoms/custom_image.dart';
import '../../../core/widgets/molecules/glassmorphic_container.dart';
import '../../../core/models/user_crop_model.dart';
import '../screens/crop_detail_screen.dart';

class UserCropCard extends StatelessWidget {
  final UserCropData userCrop;
  final bool isDark;

  const UserCropCard({super.key, required this.userCrop, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CropDetailScreen(crop: userCrop.plant),
          ),
        ),
        child: GlassmorphicContainer(
          borderRadius: BorderRadius.circular(24),
          color: AppColors.getSurface(isDark),
          opacity: isDark ? 0.6 : 0.85,
          blur: 15.0,
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : context.primary.withValues(alpha: 0.1),
            width: 1.5,
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Image Section
              Hero(
                tag: 'user-crop-${userCrop.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: CustomImage(
                    imageUrl: userCrop.plant.imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Info Section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userCrop.plant.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 12,
                          color: isDark ? Colors.white38 : Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'زرعت في: ${userCrop.datePlanted.year}/${userCrop.datePlanted.month}/${userCrop.datePlanted.day}',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.white60 : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildStatusBadge(context, userCrop.growthStage),
                        const Spacer(),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: context.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: context.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: context.primary.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: context.primary,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }
}
