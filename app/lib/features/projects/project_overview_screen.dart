import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/cards.dart';
import '../../data/models/models.dart';
import '../../data/providers/app_data.dart';
import '../dashboard/widgets/dashboard_widgets.dart';

/// 04 Projects / Project Overview — Default
class ProjectOverviewScreen extends ConsumerStatefulWidget {
  const ProjectOverviewScreen({super.key, required this.projectId});

  final String projectId;

  @override
  ConsumerState<ProjectOverviewScreen> createState() => _ProjectOverviewScreenState();
}

class _ProjectOverviewScreenState extends ConsumerState<ProjectOverviewScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(length: 4, vsync: this);

  void _shareProject(Project project) {
    Share.share('Track "${project.name}" with me on Money Care!');
  }

  Future<void> _confirmClosePeriod(AppData appData, Period period) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Close this period?'),
        content: Text(
          '${period.label} will be marked closed. You can still view its history, but new purchases and contributions should go in a new period.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Close period')),
        ],
      ),
    );
    if (confirmed == true) {
      appData.closePeriod(period.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${period.label} closed')));
      }
    }
  }

  Future<void> _confirmArchive(AppData appData, Project project) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archive this project?'),
        content: Text('"${project.name}" will move to Archive. You can restore it any time.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.statusNegative),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Archive'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      appData.archiveProject(project.id);
      if (mounted) {
        context.go('/home');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('"${project.name}" archived')));
      }
    }
  }

  void _openActionsSheet(AppData appData, Project project, Period? period) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.borderDefault,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Project Actions', style: AppTextStyles.h3),
              ),
            ),
            const Divider(height: 1),
            _ActionRow(
              icon: Icons.file_upload_outlined,
              label: 'Export Data',
              onTap: () => context.push('/more/import-export'),
            ),
            _ActionRow(
              icon: Icons.schedule_outlined,
              label: 'Close Period',
              onTap: period == null ? () {} : () => _confirmClosePeriod(appData, period),
            ),
            _ActionRow(icon: Icons.edit_outlined, label: 'Settings', onTap: () => context.push('/settings')),
            _ActionRow(icon: Icons.share_outlined, label: 'Share', onTap: () => _shareProject(project)),
            _ActionRow(
              icon: Icons.archive_outlined,
              label: 'Archive Project',
              color: AppColors.statusNegative,
              onTap: () => _confirmArchive(appData, project),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.background,
                    foregroundColor: AppColors.textSecondary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appData = ref.watch(appDataProvider);
    final project = appData.projects[widget.projectId];
    if (project == null) {
      return const Scaffold(body: Center(child: Text('Project not found')));
    }
    final period = project.activePeriodId != null ? appData.periods[project.activePeriodId] : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(project.name),
        titleTextStyle: AppTextStyles.h3,
        actions: [
          IconButton(icon: const Icon(Icons.share_outlined), onPressed: () => _shareProject(project)),
          IconButton(
            icon: const Icon(Icons.more_horiz_rounded),
            onPressed: () => _openActionsSheet(appData, project, period),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Column(
            children: [
              if (period != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.chevron_left_rounded, size: 18),
                      const SizedBox(width: 8),
                      Text(period.label, style: AppTextStyles.bodySmallSemibold),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right_rounded, size: 18),
                    ],
                  ),
                ),
              TabBar(
                controller: _tabController,
                labelColor: AppColors.actionPrimary,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: AppTextStyles.bodySmallBold,
                unselectedLabelStyle: AppTextStyles.bodySmall,
                indicatorColor: AppColors.actionPrimary,
                indicatorWeight: 2,
                tabs: const [
                  Tab(text: 'Overview'),
                  Tab(text: 'Activity'),
                  Tab(text: 'Budget'),
                  Tab(text: 'People'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: period == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('No active period', style: AppTextStyles.h3),
                    const SizedBox(height: 8),
                    Text(
                      'Create a period to start tracking this project.',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => context.push('/project/${project.id}/periods/create'),
                      child: const Text('Create period'),
                    ),
                  ],
                ),
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _OverviewTab(
                  projectId: project.id,
                  periodId: period.id,
                  onViewAllActivity: () => _tabController.animateTo(1),
                ),
                _ActivityTab(periodId: period.id),
                _BudgetTab(projectId: project.id, periodId: period.id),
                _PeopleTab(projectId: project.id),
              ],
            ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.icon, required this.label, required this.onTap, this.color});

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 20, color: color ?? AppColors.textPrimary),
      title: Text(
        label,
        style: AppTextStyles.bodyMediumSemibold.copyWith(color: color ?? AppColors.textPrimary),
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }
}

class _OverviewTab extends ConsumerWidget {
  const _OverviewTab({required this.projectId, required this.periodId, required this.onViewAllActivity});

  final String projectId;
  final String periodId;
  final VoidCallback onViewAllActivity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appData = ref.watch(appDataProvider);
    final period = appData.periods[periodId]!;
    final purchases = appData.totalPurchases(periodId);
    final contributions = appData.totalContributions(periodId);
    final balance = appData.availableBalance(periodId);
    final usedPct = period.monthlyBudget > 0 ? purchases / period.monthlyBudget : 0.0;
    final categorySpend = appData.spendingByCategory(periodId);
    final byPerson = appData.contributionsByPerson(periodId);
    final recent = appData.transactionsInPeriod(periodId).take(3).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AppCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppFormatters.currency(balance), style: AppTextStyles.h1.copyWith(fontSize: 32)),
              Text(
                'AVAILABLE BALANCE',
                style: AppTextStyles.captionMedium.copyWith(
                  color: AppColors.textSecondary,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _MiniStat(label: 'Opening', value: AppFormatters.currency(period.openingBalance)),
                  _MiniStat(
                    label: 'Inflows',
                    value: AppFormatters.currency(contributions),
                    color: AppColors.statusPositive,
                  ),
                  _MiniStat(
                    label: 'Outflows',
                    value: AppFormatters.currency(purchases),
                    color: AppColors.statusNegative,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => context.push('/purchase/add'),
                child: const Text('Add Purchase'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: () => context.push('/contribution/add'),
                child: const Text('Add Contribution'),
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
                  Text('${AppFormatters.currency(period.monthlyBudget)} Budget', style: AppTextStyles.bodySmallBold),
                  StatusBadge.positive('${(usedPct * 100).round()}% used'),
                ],
              ),
              const SizedBox(height: 10),
              AppProgressBar(value: usedPct),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Spent: ${AppFormatters.currency(purchases)}', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                  Text('Remaining: ${AppFormatters.currency(balance)}', style: AppTextStyles.captionSemibold),
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
              Text('Spending by Category', style: AppTextStyles.bodySmallBold),
              const SizedBox(height: 12),
              for (final e in categorySpend.entries)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: CategoryProgressRow(
                    category: e.key,
                    amount: e.value,
                    percent: purchases > 0 ? e.value / purchases : 0,
                  ),
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
                  Text('Contributions', style: AppTextStyles.bodySmallBold),
                  Text(
                    'Total: ${AppFormatters.currency(contributions)}',
                    style: AppTextStyles.labelSemibold.copyWith(color: AppColors.statusPositive),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              for (final e in byPerson.entries)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      AppAvatar(label: e.key.initial, size: 28),
                      const SizedBox(width: 10),
                      Expanded(child: Text(e.key.name, style: AppTextStyles.labelMedium)),
                      Text(AppFormatters.currency(e.value), style: AppTextStyles.labelSemibold),
                    ],
                  ),
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
                  Text('Recent Transactions', style: AppTextStyles.bodySmallBold),
                  LinkButton(label: 'View All', onPressed: onViewAllActivity),
                ],
              ),
              const SizedBox(height: 12),
              for (final t in recent)
                ActivityRow(
                  transaction: t,
                  showDivider: t != recent.last,
                  subtitle: '${t.personId != null ? appData.people[t.personId]?.name ?? '' : ''} · ${AppFormatters.relativeDay(t.date)}',
                  onTap: () => context.push('/transaction/${t.id}'),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value, this.color});

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 2),
        Text(value, style: AppTextStyles.labelSemibold.copyWith(color: color)),
      ],
    );
  }
}

class _ActivityTab extends ConsumerWidget {
  const _ActivityTab({required this.periodId});

  final String periodId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appData = ref.watch(appDataProvider);
    final items = appData.transactionsInPeriod(periodId);
    if (items.isEmpty) {
      return Center(
        child: Text('No transactions yet', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, i) => ActivityRow(
        transaction: items[i],
        showDivider: i != items.length - 1,
        subtitle: AppFormatters.relativeDay(items[i].date),
        onTap: () => context.push('/transaction/${items[i].id}'),
      ),
    );
  }
}

class _BudgetTab extends ConsumerWidget {
  const _BudgetTab({required this.projectId, required this.periodId});

  final String projectId;
  final String periodId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: FilledButton(
        onPressed: () => context.push('/budget'),
        child: const Text('View full budget'),
      ),
    );
  }
}

class _PeopleTab extends ConsumerWidget {
  const _PeopleTab({required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appData = ref.watch(appDataProvider);
    final people = appData.peopleInProject(projectId);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final person in people)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AppCard(
              onTap: () => context.push('/people/${person.id}'),
              child: Row(
                children: [
                  AppAvatar(label: person.initial, size: 36),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(person.name, style: AppTextStyles.labelSemibold),
                        Text(person.role, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                ],
              ),
            ),
          ),
        Center(
          child: TextButton.icon(
            onPressed: () => context.push('/project/$projectId/people/add'),
            icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
            label: const Text('Add person'),
          ),
        ),
      ],
    );
  }
}
