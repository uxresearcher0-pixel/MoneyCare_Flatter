import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/cards.dart';
import '../../core/widgets/top_bar.dart';

class _SettingsRow {
  const _SettingsRow(this.icon, this.label, {this.trailingText, this.route});
  final IconData icon;
  final String label;
  final String? trailingText;
  final String? route;
}

/// 12 Settings / Settings Hub — Main
class SettingsHubScreen extends StatelessWidget {
  const SettingsHubScreen({super.key});

  static const _projectConfig = [
    _SettingsRow(Icons.folder_rounded, 'Project Details'),
    _SettingsRow(Icons.calendar_today_rounded, 'Periods'),
    _SettingsRow(Icons.rule_rounded, 'Budget Rules'),
    _SettingsRow(Icons.arrow_forward_rounded, 'Carry-Forward Settings'),
    _SettingsRow(Icons.group_rounded, 'People & Roles'),
  ];

  static const _financialConfig = [
    _SettingsRow(Icons.grid_view_rounded, 'Categories', route: '/settings/categories'),
    _SettingsRow(Icons.straighten_rounded, 'Units', route: '/settings/units'),
    _SettingsRow(Icons.workspace_premium_rounded, 'Contribution Types', route: '/settings/contribution-types'),
    _SettingsRow(Icons.receipt_long_rounded, 'Transaction Types'),
    _SettingsRow(Icons.account_balance_wallet_rounded, 'Accounts & Wallets', route: '/settings/accounts'),
    _SettingsRow(Icons.credit_card_rounded, 'Payment Methods'),
    _SettingsRow(Icons.sell_rounded, 'Tags'),
    _SettingsRow(Icons.dashboard_customize_rounded, 'Project Fields', route: '/config/project-fields'),
    _SettingsRow(Icons.dashboard_customize_rounded, 'Workspace Custom Fields', route: '/config/project-fields'),
    _SettingsRow(Icons.sync_rounded, 'Recurring Rules'),
    _SettingsRow(Icons.monetization_on_rounded, 'Currency', trailingText: '৳ BDT'),
  ];

  static const _appPreferences = [
    _SettingsRow(Icons.language_rounded, 'Language', trailingText: 'English'),
    _SettingsRow(Icons.light_mode_rounded, 'Appearance', trailingText: 'Light'),
    _SettingsRow(Icons.notifications_none_rounded, 'Notifications'),
    _SettingsRow(Icons.shield_outlined, 'Security & Privacy'),
    _SettingsRow(Icons.accessibility_new_rounded, 'Accessibility'),
    _SettingsRow(Icons.cloud_sync_outlined, 'Sync'),
    _SettingsRow(Icons.cloud_upload_outlined, 'Backup & Restore'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SimpleTopBar(title: 'Settings', showBack: false),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search settings...',
              prefixIcon: const Icon(Icons.search_rounded, size: 18),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.borderDefault),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _SettingsGroup(title: 'Project Configuration', rows: _projectConfig),
          const SizedBox(height: 16),
          _SettingsGroup(title: 'Financial Configuration', rows: _financialConfig),
          const SizedBox(height: 16),
          _SettingsGroup(title: 'Application Preferences', rows: _appPreferences),
        ],
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.title, required this.rows});

  final String title;
  final List<_SettingsRow> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: AppTextStyles.captionSemibold.copyWith(color: AppColors.textSecondary, letterSpacing: 0.6),
        ),
        const SizedBox(height: 8),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++)
                InkWell(
                  onTap: rows[i].route != null ? () => context.push(rows[i].route!) : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                    decoration: BoxDecoration(
                      border: i == rows.length - 1
                          ? null
                          : const Border(bottom: BorderSide(color: AppColors.borderDefault)),
                    ),
                    child: Row(
                      children: [
                        Icon(rows[i].icon, size: 20, color: AppColors.textPrimary),
                        const SizedBox(width: 12),
                        Expanded(child: Text(rows[i].label, style: AppTextStyles.bodySmallSemibold)),
                        if (rows[i].trailingText != null) ...[
                          Text(
                            rows[i].trailingText!,
                            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(width: 6),
                        ],
                        const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
