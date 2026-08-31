import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/cards.dart';
import '../../core/widgets/top_bar.dart';
import '../../data/providers/app_data.dart';

class _SettingsRow {
  const _SettingsRow(this.icon, this.label, {this.trailingText, this.route, this.onTap});
  final IconData icon;
  final String label;
  final String? trailingText;
  final String? route;
  final VoidCallback? onTap;
}

const _themeModeLabel = {
  ThemeMode.light: 'Light',
  ThemeMode.dark: 'Dark',
  ThemeMode.system: 'System',
};

/// 12 Settings / Settings Hub — Main
class SettingsHubScreen extends ConsumerStatefulWidget {
  const SettingsHubScreen({super.key});

  @override
  ConsumerState<SettingsHubScreen> createState() => _SettingsHubScreenState();
}

class _SettingsHubScreenState extends ConsumerState<SettingsHubScreen> {
  final _search = TextEditingController();

  void _pickCurrency(AppData appData) {
    const options = [('BDT', '৳', 'Bangladeshi Taka'), ('USD', '\$', 'US Dollar'), ('INR', '₹', 'Indian Rupee'), ('EUR', '€', 'Euro')];
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: options
              .map(
                (o) => ListTile(
                  leading: Text(o.$2, style: AppTextStyles.h3),
                  title: Text('${o.$1} — ${o.$3}'),
                  onTap: () {
                    appData.setCurrency(o.$1, o.$2);
                    Navigator.pop(context);
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appData = ref.watch(appDataProvider);
    final projectId = appData.activeProjectId;

    final projectConfig = [
      _SettingsRow(Icons.folder_rounded, 'Project Details', route: '/settings/project-details'),
      _SettingsRow(
        Icons.calendar_today_rounded,
        'Periods',
        onTap: projectId != null ? () => context.push('/project/$projectId/periods') : null,
      ),
      const _SettingsRow(Icons.rule_rounded, 'Budget Rules', route: '/settings/budget-rules'),
      const _SettingsRow(Icons.arrow_forward_rounded, 'Carry-Forward Settings', route: '/settings/carry-forward'),
      _SettingsRow(
        Icons.group_rounded,
        'People & Roles',
        onTap: projectId != null ? () => context.push('/project/$projectId/people') : null,
      ),
    ];

    final financialConfig = [
      const _SettingsRow(Icons.grid_view_rounded, 'Categories', route: '/settings/categories'),
      const _SettingsRow(Icons.straighten_rounded, 'Units', route: '/settings/units'),
      const _SettingsRow(Icons.workspace_premium_rounded, 'Contribution Types', route: '/settings/contribution-types'),
      const _SettingsRow(Icons.receipt_long_rounded, 'Transaction Types', route: '/settings/transaction-types'),
      const _SettingsRow(Icons.account_balance_wallet_rounded, 'Accounts & Wallets', route: '/settings/accounts'),
      const _SettingsRow(Icons.credit_card_rounded, 'Payment Methods', route: '/settings/payment-methods'),
      const _SettingsRow(Icons.sell_rounded, 'Tags', route: '/settings/tags'),
      const _SettingsRow(Icons.dashboard_customize_rounded, 'Project Fields', route: '/config/project-fields'),
      const _SettingsRow(
        Icons.workspaces_rounded,
        'Workspace Custom Fields',
        route: '/settings/workspace-custom-fields',
      ),
      const _SettingsRow(Icons.event_repeat_rounded, 'Recurring Rules', route: '/settings/recurring-rules'),
      _SettingsRow(
        Icons.monetization_on_rounded,
        'Currency',
        trailingText: '${appData.currencySymbol} ${appData.currencyCode}',
        onTap: () => _pickCurrency(appData),
      ),
    ];

    final appPreferences = [
      _SettingsRow(Icons.language_rounded, 'Language', trailingText: appData.language, route: '/settings/language'),
      _SettingsRow(
        Icons.light_mode_rounded,
        'Appearance',
        trailingText: _themeModeLabel[appData.themeMode],
        route: '/settings/appearance',
      ),
      const _SettingsRow(Icons.notifications_none_rounded, 'Notifications', route: '/settings/notifications'),
      const _SettingsRow(Icons.shield_outlined, 'Security & Privacy', route: '/settings/security'),
      const _SettingsRow(Icons.accessibility_new_rounded, 'Accessibility', route: '/more/help'),
      const _SettingsRow(Icons.cloud_sync_outlined, 'Sync', route: '/settings/sync'),
      const _SettingsRow(Icons.cloud_upload_outlined, 'Backup & Restore', route: '/more/import-export'),
    ];

    final query = _search.text.trim().toLowerCase();
    bool matches(_SettingsRow r) => query.isEmpty || r.label.toLowerCase().contains(query);
    final filteredProject = projectConfig.where(matches).toList();
    final filteredFinancial = financialConfig.where(matches).toList();
    final filteredPrefs = appPreferences.where(matches).toList();
    final noResults = query.isNotEmpty && filteredProject.isEmpty && filteredFinancial.isEmpty && filteredPrefs.isEmpty;

    return Scaffold(
      appBar: const SimpleTopBar(title: 'Settings', showBack: false),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          TextField(
            controller: _search,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search settings...',
              prefixIcon: const Icon(Icons.search_rounded, size: 18),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.borderDefault),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (noResults)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No settings match "${_search.text.trim()}"',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                ),
              ),
            )
          else ...[
            if (filteredProject.isNotEmpty) ...[
              _SettingsGroup(title: 'Project Configuration', rows: filteredProject),
              const SizedBox(height: 16),
            ],
            if (filteredFinancial.isNotEmpty) ...[
              _SettingsGroup(title: 'Financial Configuration', rows: filteredFinancial),
              const SizedBox(height: 16),
            ],
            if (filteredPrefs.isNotEmpty)
              _SettingsGroup(title: 'Application Preferences', rows: filteredPrefs),
          ],
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
                  onTap: rows[i].onTap ?? (rows[i].route != null ? () => context.push(rows[i].route!) : null),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                    decoration: BoxDecoration(
                      border: i == rows.length - 1
                          ? null
                          : Border(bottom: BorderSide(color: AppColors.borderDefault)),
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
                        Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textSecondary),
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
