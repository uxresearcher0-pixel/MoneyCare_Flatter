import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'cards.dart';

/// The greeting header used on the dashboard and hub screens:
/// avatar + "Good morning, {name}" + workspace name + notification bell.
class GreetingTopBar extends StatelessWidget implements PreferredSizeWidget {
  const GreetingTopBar({
    super.key,
    required this.userInitial,
    required this.greeting,
    required this.subtitle,
    this.onNotificationTap,
    this.hasNotification = true,
  });

  final String userInitial;
  final String greeting;
  final String subtitle;
  final VoidCallback? onNotificationTap;
  final bool hasNotification;

  @override
  Size get preferredSize => const Size.fromHeight(63);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            AppAvatar(label: userInitial, size: 36),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(greeting, style: AppTextStyles.labelSemibold, overflow: TextOverflow.ellipsis),
                  Text(
                    subtitle,
                    style: AppTextStyles.captionMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: onNotificationTap,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.borderDefault),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(Icons.notifications_outlined, size: 18, color: AppColors.textPrimary),
                    if (hasNotification)
                      Positioned(
                        right: 9,
                        top: 9,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: AppColors.statusNegative,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Simple back-title app bar for form/detail screens.
class SimpleTopBar extends StatelessWidget implements PreferredSizeWidget {
  const SimpleTopBar({
    super.key,
    required this.title,
    this.onBack,
    this.actions,
    this.showBack = true,
  });

  final String title;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final bool showBack;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              onPressed: onBack ?? () => Navigator.of(context).maybePop(),
            )
          : null,
      title: Text(title, style: AppTextStyles.bodyLargeSemibold),
      actions: actions,
    );
  }
}
