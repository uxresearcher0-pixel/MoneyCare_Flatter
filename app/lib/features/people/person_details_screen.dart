import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/cards.dart';
import '../../core/widgets/top_bar.dart';
import '../../data/models/models.dart';
import '../../data/providers/app_data.dart';

/// 07 People / Person Details — Contribution Summary
class PersonDetailsScreen extends ConsumerWidget {
  const PersonDetailsScreen({super.key, required this.personId});

  final String personId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appData = ref.watch(appDataProvider);
    final person = appData.people[personId];
    if (person == null) {
      return const Scaffold(body: Center(child: Text('Person not found')));
    }
    final period = appData.activePeriod;
    final contributions = period != null
        ? appData.contributionsInPeriod(period.id).where((t) => t.personId == personId).toList()
        : <AppTransaction>[];
    final purchases = period != null
        ? appData.purchasesInPeriod(period.id).where((t) => t.personId == personId).toList()
        : <AppTransaction>[];
    final totalContributed = contributions.fold<num>(0, (s, t) => s + t.amount);
    final byType = <String, num>{};
    for (final t in contributions) {
      byType[t.contributionType] = (byType[t.contributionType] ?? 0) + t.amount;
    }
    final expected = person.monthlyPledge;
    final recent = [...contributions, ...purchases]..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      appBar: SimpleTopBar(title: person.name),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          AppCard(
            child: Column(
              children: [
                AppAvatar(label: person.initial, size: 64),
                const SizedBox(height: 10),
                Text(person.name, style: AppTextStyles.h3),
                const SizedBox(height: 6),
                StatusBadge.neutral(person.isOwner ? 'Owner' : 'Contributor'),
                const SizedBox(height: 8),
                StatusBadge.positive('Active Status'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Total Contributed',
                  value: AppFormatters.currency(totalContributed),
                  color: AppColors.statusPositive,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(child: _StatCard(label: 'Expected', value: AppFormatters.currency(expected))),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Status',
                  value: totalContributed >= expected ? 'Over-contributed' : 'Under-contributed',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatCard(
                  label: 'Receivable',
                  value: AppFormatters.currency((totalContributed - expected).abs()),
                  color: AppColors.statusPositive,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Breakdown', style: AppTextStyles.bodySmallSemibold),
                const SizedBox(height: 10),
                for (final entry in byType.entries)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                        Text(AppFormatters.currency(entry.value), style: AppTextStyles.labelSemibold),
                      ],
                    ),
                  ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Purchases Made (${purchases.length})',
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                    ),
                    Text(
                      AppFormatters.currency(purchases.fold<num>(0, (s, t) => s + t.amount)),
                      style: AppTextStyles.labelSemibold,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('Activity history', style: AppTextStyles.bodySmallSemibold.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          for (final t in recent.take(6))
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AppCard(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    AppAvatar(
                      icon: t.type == TransactionType.purchase
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      size: 24,
                      shape: BoxShape.rectangle,
                      background: t.type == TransactionType.purchase
                          ? AppColors.statusNegativeBg
                          : AppColors.surfaceSubtle,
                      foreground: t.type == TransactionType.purchase
                          ? AppColors.statusNegative
                          : AppColors.statusPositive,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.type == TransactionType.purchase ? 'Purchased ${t.title}' : 'Contributed ${t.contributionType}',
                            style: AppTextStyles.captionSemibold,
                          ),
                          Text(
                            AppFormatters.relativeDay(t.date),
                            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      AppFormatters.currency(
                        t.type == TransactionType.purchase ? -t.amount : t.amount,
                        showSign: true,
                      ),
                      style: AppTextStyles.captionBold.copyWith(
                        color: t.type == TransactionType.purchase
                            ? AppColors.statusNegative
                            : AppColors.statusPositive,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Add Contribution',
            radius: 8,
            onPressed: () => context.push('/contribution/add'),
          ),
          const SizedBox(height: 8),
          SecondaryButton(
            label: 'Edit Person',
            radius: 8,
            onPressed: appData.activeProject == null
                ? null
                : () => context.push('/project/${appData.activeProject!.id}/people/$personId/setup'),
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: appData.activeProject == null
                  ? null
                  : () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Remove from project?'),
                          content: Text('${person.name} will lose access to this project. This cannot be undone.'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                            TextButton(
                              style: TextButton.styleFrom(foregroundColor: AppColors.statusNegative),
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Remove'),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        appData.removePersonFromProject(appData.activeProject!.id, personId);
                        if (context.mounted) context.pop();
                      }
                    },
              child: Text(
                'Remove from Project',
                style: AppTextStyles.bodySmallSemibold.copyWith(color: AppColors.statusNegative),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, this.color});

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(value, style: AppTextStyles.bodySmallBold.copyWith(color: color)),
        ],
      ),
    );
  }
}
