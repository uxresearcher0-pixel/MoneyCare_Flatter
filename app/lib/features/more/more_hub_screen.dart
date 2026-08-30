import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/cards.dart';
import '../../data/providers/app_data.dart';

class _MenuRow {
  const _MenuRow(this.icon, this.title, this.subtitle, {this.route});
  final IconData icon;
  final String title;
  final String subtitle;
  final String? route;
}

/// 15 More / More Hub — Default
class MoreHubScreen extends ConsumerWidget {
  const MoreHubScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appData = ref.watch(appDataProvider);
    final workspace = appData.activeWorkspace;

    final manage = [
      _MenuRow(Icons.groups_rounded, 'People & contributions', 'Members, roles and expected amounts', route: '/people-hub'),
      _MenuRow(Icons.bar_chart_rounded, 'Reports', 'Spending, contribution and budget insights', route: '/reports/spending'),
      _MenuRow(Icons.settings_rounded, 'Settings', 'Project and financial configuration', route: '/settings'),
    ];
    final data = [
      _MenuRow(Icons.sync_alt_rounded, 'Import & export', 'Excel, CSV and complete backup', route: '/more/import-export'),
      _MenuRow(Icons.archive_rounded, 'Archive', 'Completed projects and closed periods', route: '/more/archive'),
    ];
    final support = [
      _MenuRow(Icons.help_outline_rounded, 'Help & accessibility', 'Guides, feedback and accessibility options', route: '/more/help'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('More'),
        titleTextStyle: AppTextStyles.h2,
        actions: [IconButton(icon: const Icon(Icons.notifications_none_rounded), onPressed: () {})],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          AppCard(
            color: AppColors.surfaceSubtle,
            child: Row(
              children: [
                AppAvatar(label: appData.currentUser.initial, size: 46, background: AppColors.actionPrimary, foreground: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(appData.currentUser.name, style: AppTextStyles.bodySmallBold),
                      Text(
                        '${workspace?.name ?? ''} · Owner',
                        style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.swap_horiz_rounded, color: AppColors.actionPrimary),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _MenuGroup(title: 'MANAGE', rows: manage),
          const SizedBox(height: 16),
          _MenuGroup(title: 'DATA', rows: data),
          const SizedBox(height: 16),
          _MenuGroup(title: 'SUPPORT', rows: support),
          const SizedBox(height: 16),
          AppCard(
            child: InkWell(
              onTap: () => ref.read(appDataProvider).signOut(),
              child: Row(
                children: [
                  const Icon(Icons.logout_rounded, color: AppColors.statusNegative),
                  const SizedBox(width: 12),
                  Text('Sign out', style: AppTextStyles.bodySmallSemibold.copyWith(color: AppColors.statusNegative)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuGroup extends StatelessWidget {
  const _MenuGroup({required this.title, required this.rows});

  final String title;
  final List<_MenuRow> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.captionSemibold.copyWith(color: AppColors.textSecondary, letterSpacing: 0.6)),
        const SizedBox(height: 8),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++)
                InkWell(
                  onTap: rows[i].route != null ? () => context.push(rows[i].route!) : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                    decoration: BoxDecoration(
                      border: i == rows.length - 1
                          ? null
                          : const Border(bottom: BorderSide(color: AppColors.borderDefault)),
                    ),
                    child: Row(
                      children: [
                        Icon(rows[i].icon, size: 22, color: AppColors.actionPrimary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(rows[i].title, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w500)),
                              Text(
                                rows[i].subtitle,
                                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textSecondary),
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
