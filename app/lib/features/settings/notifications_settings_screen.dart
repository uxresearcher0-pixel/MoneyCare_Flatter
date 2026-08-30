import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/cards.dart';
import '../../core/widgets/top_bar.dart';
import '../../data/providers/app_data.dart';

/// 12 Settings / Notifications
class NotificationsSettingsScreen extends ConsumerWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appData = ref.watch(appDataProvider);

    return Scaffold(
      appBar: const SimpleTopBar(title: 'Notifications'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                SwitchListTile.adaptive(
                  title: Text('Push notifications', style: AppTextStyles.bodySmallSemibold),
                  subtitle: const Text('New activity, contributions and reminders'),
                  value: appData.pushNotificationsEnabled,
                  activeThumbColor: AppColors.actionPrimary,
                  onChanged: (v) => appData.setPreference(push: v),
                ),
                const Divider(height: 1),
                SwitchListTile.adaptive(
                  title: Text('Email summaries', style: AppTextStyles.bodySmallSemibold),
                  subtitle: const Text('Weekly spending digest by email'),
                  value: appData.emailNotificationsEnabled,
                  activeThumbColor: AppColors.actionPrimary,
                  onChanged: (v) => appData.setPreference(email: v),
                ),
                const Divider(height: 1),
                SwitchListTile.adaptive(
                  title: Text('Budget alerts', style: AppTextStyles.bodySmallSemibold),
                  subtitle: const Text('Notify when a category crosses its threshold'),
                  value: appData.budgetAlertsEnabled,
                  activeThumbColor: AppColors.actionPrimary,
                  onChanged: (v) => appData.setPreference(budgetAlerts: v),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
