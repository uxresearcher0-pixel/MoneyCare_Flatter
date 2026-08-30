import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/cards.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/top_bar.dart';
import '../../data/providers/app_data.dart';

/// 05 Periods / Period List — Populated
class PeriodListScreen extends ConsumerWidget {
  const PeriodListScreen({super.key, required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appData = ref.watch(appDataProvider);
    final project = appData.projects[projectId];
    final periods = project?.periodIds.map((id) => appData.periods[id]!).toList() ?? [];
    periods.sort((a, b) => b.startDate.compareTo(a.startDate));

    return Scaffold(
      appBar: SimpleTopBar(
        title: '${project?.name ?? 'Project'} periods',
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppColors.actionPrimary),
            onPressed: () => context.push('/project/$projectId/periods/create'),
          ),
        ],
      ),
      body: periods.isEmpty
          ? EmptyState(
              icon: Icons.calendar_month_rounded,
              title: 'No periods yet',
              message: 'Start a tracking period to begin logging purchases and contributions.',
              actionLabel: 'Create period',
              onAction: () => context.push('/project/$projectId/periods/create'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: periods.length,
              itemBuilder: (context, i) {
                final period = periods[i];
                final isActive = project?.activePeriodId == period.id;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AppCard(
                    onTap: () {
                      appData.setActivePeriod(projectId, period.id);
                      context.go('/home');
                    },
                    child: Row(
                      children: [
                        const AppAvatar(icon: Icons.calendar_month_rounded, size: 40, shape: BoxShape.rectangle),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(period.label, style: AppTextStyles.labelSemibold),
                              Text(
                                '${AppFormatters.monthDay(period.startDate)} - ${AppFormatters.monthDay(period.endDate)}',
                                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        if (isActive) StatusBadge.positive('Active'),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
