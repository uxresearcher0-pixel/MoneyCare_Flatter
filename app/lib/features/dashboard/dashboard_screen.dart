import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/cards.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/top_bar.dart';
import '../../data/providers/app_data.dart';
import 'widgets/dashboard_widgets.dart';

/// 02 Dashboard (Empty) / 06 Period Overview — Active Dashboard / Empty Active Period
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _balanceHidden = false;

  @override
  Widget build(BuildContext context) {
    final appData = ref.watch(appDataProvider);
    final workspace = appData.activeWorkspace;
    final project = appData.activeProject;
    final period = appData.activePeriod;

    if (workspace == null) {
      return Scaffold(
        appBar: GreetingTopBar(
          userInitial: appData.currentUser.initial,
          greeting: 'Good morning, ${appData.currentUser.firstName}',
          subtitle: 'No workspace yet',
        ),
        body: EmptyState(
          icon: Icons.workspaces_outlined,
          title: 'Create your first workspace',
          message: 'Workspaces group projects for your household, team, or shared circle.',
          actionLabel: 'Create workspace',
          onAction: () => context.push('/workspace/create'),
        ),
      );
    }

    if (project == null || period == null) {
      return Scaffold(
        appBar: GreetingTopBar(
          userInitial: appData.currentUser.initial,
          greeting: 'Good morning, ${appData.currentUser.firstName}',
          subtitle: workspace.name,
        ),
        body: EmptyState(
          icon: Icons.folder_open_rounded,
          title: 'No active period',
          message: 'Start a project and a tracking period to see your dashboard come alive.',
          actionLabel: 'Create project',
          onAction: () => context.push('/project/create?workspaceId=${workspace.id}'),
        ),
      );
    }

    final purchases = appData.purchasesInPeriod(period.id);
    final totalPurchases = appData.totalPurchases(period.id);
    final totalContributions = appData.totalContributions(period.id);
    final balance = appData.availableBalance(period.id);
    final remaining = period.monthlyBudget - totalPurchases;
    final usedPct = period.monthlyBudget > 0 ? totalPurchases / period.monthlyBudget : 0.0;
    final categorySpend = appData.spendingByCategory(period.id);
    final byPerson = appData.contributionsByPerson(period.id);
    final recent = appData.transactionsInPeriod(period.id).take(5).toList();

    return Scaffold(
      appBar: GreetingTopBar(
        userInitial: appData.currentUser.initial,
        greeting: 'Good morning, ${appData.currentUser.firstName}',
        subtitle: workspace.name,
        onNotificationTap: () {},
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          AppCard(
            padding: const EdgeInsets.all(12),
            onTap: () => context.push('/project/${project.id}'),
            child: Row(
              children: [
                const AppAvatar(icon: Icons.folder_rounded, size: 32, shape: BoxShape.rectangle),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(project.name, style: AppTextStyles.labelSemibold),
                      Text(
                        period.label,
                        style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.expand_more_rounded, size: 18, color: AppColors.textSecondary),
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
                  children: [
                    Expanded(
                      child: Text(
                        'Available balance',
                        style: AppTextStyles.captionMedium.copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                    InkWell(
                      onTap: () => setState(() => _balanceHidden = !_balanceHidden),
                      child: Icon(
                        _balanceHidden ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _balanceHidden ? '৳••••••' : AppFormatters.currency(balance),
                  style: AppTextStyles.h1,
                ),
                const SizedBox(height: 4),
                Text(
                  '${AppFormatters.currency((balance * 0.13).round())} more than last month',
                  style: AppTextStyles.labelMedium.copyWith(color: AppColors.statusPositive),
                ),
                const SizedBox(height: 16),
                Text(
                  '${(100 - usedPct * 100).clamp(0, 100).round()}% of monthly budget remains',
                  style: AppTextStyles.captionMedium.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                AppProgressBar(value: 1 - usedPct),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: MetricCard(
                  title: 'Opening balance',
                  value: AppFormatters.currency(period.openingBalance),
                  subtitle: 'Carried forward',
                  icon: Icons.account_balance_wallet_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MetricCard(
                  title: 'Contributions',
                  value: AppFormatters.currency(totalContributions),
                  subtitle: '${byPerson.length} contributors',
                  icon: Icons.arrow_downward_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: MetricCard(
                  title: 'Purchases',
                  value: AppFormatters.currency(totalPurchases),
                  subtitle: '${purchases.length} transactions',
                  icon: Icons.shopping_cart_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MetricCard(
                  title: 'Remaining budget',
                  value: AppFormatters.currency(remaining),
                  subtitle: '${(100 - usedPct * 100).clamp(0, 100).round()}% remaining',
                  icon: Icons.track_changes_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: QuickActionButton(
                  icon: Icons.add_rounded,
                  label: 'Add\nPurchase',
                  primary: true,
                  onTap: () => context.push('/purchase/add'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: QuickActionButton(
                  icon: Icons.arrow_downward_rounded,
                  label: 'Add\nContribution',
                  onTap: () => context.push('/contribution/add'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: QuickActionButton(
                  icon: Icons.photo_camera_rounded,
                  label: 'Scan\nReceipt',
                  onTap: () => context.push('/scan-receipt'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: QuickActionButton(
                  icon: Icons.apps_rounded,
                  label: 'More',
                  onTap: () => context.push('/more'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Monthly budget', style: AppTextStyles.bodyMediumSemibold),
                    StatusBadge.positive(usedPct <= 1 ? 'On track' : 'Over budget'),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  '${AppFormatters.currency(totalPurchases)} of ${AppFormatters.currency(period.monthlyBudget)} used',
                  style: AppTextStyles.labelMedium,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${(usedPct * 100).round()}% used',
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                    ),
                    Text(
                      '${period.endDate.difference(DateTime.now()).inDays.clamp(0, 999)} days remaining',
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                AppProgressBar(value: usedPct, height: 8),
                const SizedBox(height: 14),
                LinkButton(label: 'View budget', onPressed: () => context.push('/budget')),
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
                    Text('Spending overview', style: AppTextStyles.bodyMediumSemibold),
                    StatusBadge.neutral(AppFormatters.monthYear(period.startDate).split(' ').first),
                  ],
                ),
                const SizedBox(height: 16),
                Text(AppFormatters.currency(totalPurchases), style: AppTextStyles.h2),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.arrow_downward_rounded, size: 14, color: AppColors.statusPositive),
                    const SizedBox(width: 4),
                    Text(
                      '12% lower than last month',
                      style: AppTextStyles.captionMedium.copyWith(color: AppColors.statusPositive),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _WeekBarChart(purchases: purchases),
                const SizedBox(height: 14),
                Row(
                  children: [
                    LinkButton(
                      label: 'View report',
                      onPressed: () => context.push('/reports/spending'),
                    ),
                    const SizedBox(width: 16),
                    LinkButton(
                      label: 'View as table',
                      color: AppColors.textSecondary,
                      onPressed: () => context.push('/reports/spending'),
                    ),
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
                Text('Spending by category', style: AppTextStyles.bodyMediumSemibold),
                const SizedBox(height: 16),
                if (categorySpend.isEmpty)
                  Text('No purchases yet', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary))
                else
                  ...(categorySpend.entries.toList()
                        ..sort((a, b) => b.value.compareTo(a.value)))
                      .take(4)
                      .map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: CategoryProgressRow(
                            category: e.key,
                            amount: e.value,
                            percent: totalPurchases > 0 ? e.value / totalPurchases : 0,
                          ),
                        ),
                      ),
                LinkButton(label: 'View all', onPressed: () => context.push('/reports/spending')),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Contributions overview', style: AppTextStyles.bodyMediumSemibold),
                Text(
                  '${AppFormatters.currency(totalContributions)} received · ${byPerson.length} contributors',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                ...byPerson.entries.map(
                  (e) => ContributorRow(
                    person: e.key,
                    amount: e.value,
                    detail: '${e.key.contributionType} contribution',
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    LinkButton(
                      label: 'Add contribution',
                      onPressed: () => context.push('/contribution/add'),
                    ),
                    const SizedBox(width: 16),
                    LinkButton(
                      label: 'View all',
                      color: AppColors.textSecondary,
                      onPressed: () => context.push('/people-hub'),
                    ),
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
                Text('Recent activity', style: AppTextStyles.bodyMediumSemibold),
                const SizedBox(height: 16),
                if (recent.isEmpty)
                  Text(
                    'No activity yet',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                  )
                else
                  ...recent.map(
                    (t) => ActivityRow(
                      transaction: t,
                      subtitle: t.type.name == 'purchase'
                          ? '${appData.categories[t.categoryId]?.name ?? ''} · ${AppFormatters.relativeDay(t.date)}'
                          : '${t.contributionType} contribution · ${AppFormatters.relativeDay(t.date)}',
                      onTap: () => context.push('/transaction/${t.id}'),
                    ),
                  ),
                const SizedBox(height: 4),
                LinkButton(label: 'See all activity', onPressed: () {}),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            color: AppColors.actionSelected,
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.lightbulb_rounded, size: 16, color: AppColors.actionPrimary),
                    const SizedBox(width: 8),
                    Text(
                      'Daily Insight',
                      style: AppTextStyles.labelSemibold.copyWith(color: AppColors.actionPrimary),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Grocery spending is 12% lower than at this point last month.',
                  style: AppTextStyles.labelMedium,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    LinkButton(label: 'Review details', onPressed: () => context.push('/reports/spending')),
                    const SizedBox(width: 16),
                    LinkButton(label: 'Dismiss', color: AppColors.textSecondary, onPressed: () {}),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekBarChart extends StatelessWidget {
  const _WeekBarChart({required this.purchases});

  final List purchases;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));
    final totals = days.map((d) {
      return purchases
          .where((t) => t.date.year == d.year && t.date.month == d.month && t.date.day == d.day)
          .fold<num>(0, (sum, t) => sum + t.amount);
    }).toList();
    final maxVal = (totals.fold<num>(1, (m, v) => v > m ? v : m)).toDouble();

    return Column(
      children: [
        SizedBox(
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (i) {
              final h = 12 + (totals[i] / maxVal) * 68;
              return Container(
                width: 24,
                height: h.toDouble(),
                decoration: const BoxDecoration(
                  color: AppColors.actionPrimary,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: days
              .map(
                (d) => SizedBox(
                  width: 24,
                  child: Text(
                    AppFormatters.weekday(d),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.captionSemibold.copyWith(color: AppColors.textSecondary),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
