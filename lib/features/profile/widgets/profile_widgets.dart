import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String? phone;
  final String? imageUrl;
  final bool isVerified;

  const ProfileHeader({
    super.key,
    required this.name,
    this.phone,
    this.imageUrl,
    this.isVerified = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  width: 4,
                ),
              ),
            ),
            CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              backgroundImage: imageUrl != null && imageUrl!.isNotEmpty
                  ? NetworkImage(imageUrl!)
                  : null,
              child: (imageUrl == null || imageUrl!.isEmpty)
                  ? const Icon(Icons.person, size: 50, color: AppColors.primary)
                  : null,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              name,
              style: AppTypography.h2(isDark: isDark),
            ),
            if (isVerified) ...[
              const SizedBox(width: 8),
              const Icon(
                Icons.verified,
                color: AppColors.primary,
                size: 20,
              ),
            ],
          ],
        ),
        if (phone != null && phone!.isNotEmpty)
          Text(
            phone!,
            style: AppTypography.bodyMedium(isDark: isDark),
          ),
      ],
    );
  }
}

class SettingsGroup extends StatelessWidget {
  final List<Widget> children;
  final String? title;

  const SettingsGroup({
    super.key,
    required this.children,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.only(right: 8, bottom: 12),
            child: Text(
              title!,
              style: AppTypography.bodySmall(isDark: isDark).copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.cardLight,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.border(isDark),
              width: 1,
            ),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Column(
              children: children,
            ),
          ),
        ),
      ],
    );
  }
}

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool hasArrow;
  final bool isSwitch;
  final bool switchValue;
  final bool isDestructive;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onToggle;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.hasArrow = false,
    this.isSwitch = false,
    this.switchValue = false,
    this.isDestructive = false,
    this.onTap,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDestructive
              ? AppColors.error.withValues(alpha: 0.1)
              : AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isDestructive ? AppColors.error : AppColors.primary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: AppTypography.bodyLarge(isDark: isDark).copyWith(
          color: isDestructive ? AppColors.error : null,
          fontSize: 15,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: AppTypography.bodySmall(isDark: isDark),
            )
          : null,
      trailing: isSwitch
          ? Switch.adaptive(
              value: switchValue,
              onChanged: onToggle,
              activeThumbColor: AppColors.primary,
            )
          : (hasArrow
              ? Icon(
                  Icons.arrow_back_ios_new,
                  size: 14,
                  color: isDark
                      ? AppColors.darkTextSecondary.withValues(alpha: 0.3)
                      : AppColors.textMuted.withValues(alpha: 0.3),
                )
              : null),
    );
  }
}
