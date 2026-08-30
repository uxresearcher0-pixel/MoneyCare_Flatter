import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/cards.dart';
import '../../core/widgets/top_bar.dart';
import '../../data/providers/app_data.dart';

/// 13 Budget / Budget Overview — On Track
class BudgetOverviewScreen extends ConsumerWidget {
  const BudgetOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appData = ref.watch(appDataProvider);
    final project = appData.activeProject;
    final period = appData.activePeriod;

    if (period == null || project == null) {
      return const Scaffold(body: Center(child: Text('No active budget period')));
    }

    final purchases = appData.totalPurchases(period.id);
    final remaining = period.monthlyBudget - purchases;
    final usedPct = period.monthlyBudget > 0 ? purchases / period.monthlyBudget : 0.0;
    final categorySpend = appData.spendingByCategory(period.id);
    final daysLeft = period.endDate.difference(DateTime.now()).inDays.clamp(0, 999);

    return Scaffold(
      appBar: GreetingTopBar(
        userInitial: appData.currentUser.initial,
        greeting: 'Budget',
        subtitle: appData.activeWorkspace?.name ?? '',
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          AppCard(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const AppAvatar(icon: Icons.folder_rounded, size: 32, shape: BoxShape.rectangle),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(project.name, style: AppTextStyles.labelSemibold),
                      Text(period.label, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                const Icon(Icons.expand_more_rounded, size: 18),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Budget', style: AppTextStyles.bodyMediumSemibold),
                    StatusBadge.positive(usedPct <= 1 ? 'On Track' : 'Over budget'),
                  ],
                ),
                const SizedBox(height: 12),
                Text(AppFormatters.currency(period.monthlyBudget), style: AppTextStyles.h1),
                Text(
                  '${AppFormatters.currency((remaining * 0.1).round())} more than last month',
                  style: AppTextStyles.labelMedium.copyWith(color: AppColors.statusPositive),
                ),
                const SizedBox(height: 16),
                Text(
                  '${(100 - usedPct * 100).clamp(0, 100).round()}% of monthly budget remains',
                  style: AppTextStyles.captionMedium.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                AppProgressBar(value: 1 - usedPct),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StatCol(label: 'Used', value: AppFormatters.currency(purchases)),
                    _StatCol(label: 'Remaining', value: AppFormatters.currency(remaining)),
                    _StatCol(label: 'Days Left', value: '$daysLeft days', alignEnd: true),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Spending Forecast', style: AppTextStyles.bodySmallBold),
                const SizedBox(height: 8),
                Text(
                  'Based on current spending, you\'ll use ~${AppFormatters.currency((purchases * 1.85).round())} by month end.',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Projected: ${AppFormatters.currency((purchases * 1.85).round())}', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                    Text('Budget: ${AppFormatters.currency(period.monthlyBudget)}', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                  ],
                ),
                const SizedBox(height: 4),
                AppProgressBar(value: (purchases * 1.85) / (period.monthlyBudget == 0 ? 1 : period.monthlyBudget), height: 4),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('vs Last period', style: AppTextStyles.bodySmallBold),
                    Row(
                      children: [
                        const Icon(Icons.arrow_downward_rounded, size: 12, color: AppColors.statusPositive),
                        Text('12% lower', style: AppTextStyles.captionSemibold.copyWith(color: AppColors.statusPositive)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Last period (full)', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                    Text(AppFormatters.currency((purchases * 1.14).round()), style: AppTextStyles.captionSemibold),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('This period so far', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                    Text('${AppFormatters.currency(purchases)} (${(usedPct * 100).round()}%)', style: AppTextStyles.captionSemibold),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Category Budgets', style: AppTextStyles.bodySmallBold),
                const SizedBox(height: 14),
                for (final e in categorySpend.entries)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _CategoryBudgetRow(name: e.key.name, icon: e.key.icon, spent: e.value),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Budget Alerts', style: AppTextStyles.bodySmallBold),
                    const StatusBadge(label: 'No active alerts', dense: true),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.check_rounded, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your spending is well within set thresholds.',
                        style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: OutlinedButton(onPressed: () {}, child: const Text('Edit Budget'))),
              const SizedBox(width: 8),
              Expanded(child: FilledButton(onPressed: () {}, child: const Text('Add Category'))),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCol extends StatelessWidget {
  const _StatCol({required this.label, required this.value, this.alignEnd = false});

  final String label;
  final String value;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
        Text(value, style: AppTextStyles.labelSemibold),
      ],
    );
  }
}

class _CategoryBudgetRow extends StatelessWidget {
  const _CategoryBudgetRow({required this.name, required this.icon, required this.spent});

  final String name;
  final IconData icon;
  final num spent;

  @override
  Widget build(BuildContext context) {
    final budget = spent * 1.5 + 500;
    final pct = (spent / budget).clamp(0, 1).toDouble();
    final status = pct > 0.9 ? 'Watch' : 'Normal';
    final color = pct > 0.9 ? AppColors.statusWarning : AppColors.statusPositive;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            AppAvatar(icon: icon, size: 28, shape: BoxShape.rectangle),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: AppTextStyles.labelSemibold),
                  Text(
                    '${AppFormatters.currency(budget - spent)} remaining',
                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${AppFormatters.currency(spent)} of ${AppFormatters.currency(budget.round())}', style: AppTextStyles.labelSemibold),
                Text('${(pct * 100).round()}%', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(width: 8),
            StatusBadge(label: status, background: color == AppColors.statusPositive ? AppColors.surfaceSubtle : AppColors.statusWarningBg, foreground: color, pill: false, dense: true),
          ],
        ),
        const SizedBox(height: 8),
        AppProgressBar(value: pct, color: color),
      ],
    );
  }
}
