import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/cards.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/top_bar.dart';
import '../../data/providers/app_data.dart';

/// Notifications inbox — reached from the bell icon on the dashboard and
/// budget overview top bars.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appData = ref.watch(appDataProvider);
    final notifications = appData.notifications.toList()..sort((a, b) => b.time.compareTo(a.time));

    return Scaffold(
      appBar: SimpleTopBar(
        title: 'Notifications',
        actions: [
          if (appData.unreadNotificationCount > 0)
            TextButton(
              onPressed: () => appData.markAllNotificationsRead(),
              child: Text('Mark all read', style: AppTextStyles.bodySmallSemibold.copyWith(color: AppColors.actionPrimary)),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? const EmptyState(
              icon: Icons.notifications_none_rounded,
              title: "You're all caught up",
              message: 'New activity, budget alerts and summaries will show up here.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final n = notifications[i];
                return AppCard(
                  color: n.read ? AppColors.surface : AppColors.actionSelected,
                  onTap: () => appData.markNotificationRead(n.id),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppAvatar(icon: n.icon, size: 36, shape: BoxShape.rectangle),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(n.title, style: AppTextStyles.bodySmallBold),
                            const SizedBox(height: 2),
                            Text(n.body, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                            const SizedBox(height: 4),
                            Text(
                              AppFormatters.relativeDay(n.time),
                              style: AppTextStyles.captionMedium.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      if (!n.read)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(color: AppColors.statusNegative, shape: BoxShape.circle),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
