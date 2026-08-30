import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/cards.dart';
import '../../core/widgets/top_bar.dart';
import '../../data/models/models.dart';
import '../../data/providers/app_data.dart';
import '../dashboard/widgets/dashboard_widgets.dart';

/// 14 Reports / Spending Overview
class SpendingOverviewScreen extends ConsumerStatefulWidget {
  const SpendingOverviewScreen({super.key});

  @override
  ConsumerState<SpendingOverviewScreen> createState() => _SpendingOverviewScreenState();
}

class _SpendingOverviewScreenState extends ConsumerState<SpendingOverviewScreen> {
  String _tab = 'Spending';
  static const _tabs = ['Spending', 'Categories', 'Contributions', 'People', 'Budget', 'Period Comparison'];

  @override
  Widget build(BuildContext context) {
    final appData = ref.watch(appDataProvider);
    final period = appData.activePeriod;
    if (period == null) {
      return const Scaffold(body: Center(child: Text('No active period')));
    }
    final purchases = appData.purchasesInPeriod(period.id);
    final total = appData.totalPurchases(period.id);
    final categorySpend = appData.spendingByCategory(period.id);
    final byPerson = <Person, num>{};
    for (final t in purchases) {
      final p = appData.people[t.personId];
      if (p == null) continue;
      byPerson[p] = (byPerson[p] ?? 0) + t.amount;
    }
    final topItems = [...purchases]..sort((a, b) => b.amount.compareTo(a.amount));

    return Scaffold(
      appBar: SimpleTopBar(
        title: 'Spending overview',
        actions: [
          IconButton(icon: const Icon(Icons.ios_share_rounded), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _tabs
                  .map(
                    (t) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(t),
                        selected: _tab == t,
                        onSelected: (_) => setState(() => _tab = t),
                        showCheckmark: false,
                        selectedColor: AppColors.actionPrimary,
                        labelStyle: AppTextStyles.captionSemibold.copyWith(
                          color: _tab == t ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total spending', style: AppTextStyles.captionMedium.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Text(AppFormatters.currency(total), style: AppTextStyles.h1),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.arrow_downward_rounded, size: 14, color: AppColors.statusPositive),
                    Text('12% lower than last period', style: AppTextStyles.captionMedium.copyWith(color: AppColors.statusPositive)),
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
                Text('Daily spending', style: AppTextStyles.bodySmallBold),
                const SizedBox(height: 16),
                _DailyBarChart(purchases: purchases),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Category breakdown', style: AppTextStyles.bodySmallBold),
                const SizedBox(height: 14),
                for (final e in (categorySpend.entries.toList()..sort((a, b) => b.value.compareTo(a.value))))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: CategoryProgressRow(
                      category: e.key,
                      amount: e.value,
                      percent: total > 0 ? e.value / total : 0,
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
                Text('Spending by person', style: AppTextStyles.bodySmallBold),
                const SizedBox(height: 14),
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
                    Text('Top purchases', style: AppTextStyles.bodySmallBold),
                    LinkButton(label: 'View as table', onPressed: () {}),
                  ],
                ),
                const SizedBox(height: 12),
                for (final t in topItems.take(5))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        AppAvatar(icon: appData.categories[t.categoryId]?.icon ?? Icons.shopping_bag_rounded, size: 28, shape: BoxShape.rectangle),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(t.title, style: AppTextStyles.labelMedium),
                              Text(
                                AppFormatters.relativeDay(t.date),
                                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        Text(AppFormatters.currency(t.amount), style: AppTextStyles.labelSemibold),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            color: AppColors.actionSelected,
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lightbulb_rounded, size: 18, color: AppColors.actionPrimary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Your grocery spending this period is trending 12% below last period — nice work staying on budget.',
                    style: AppTextStyles.labelMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyBarChart extends StatelessWidget {
  const _DailyBarChart({required this.purchases});

  final List<AppTransaction> purchases;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));
    final totals = days
        .map((d) => purchases
            .where((t) => t.date.year == d.year && t.date.month == d.month && t.date.day == d.day)
            .fold<num>(0, (s, t) => s + t.amount))
        .toList();
    final maxVal = totals.fold<num>(1, (m, v) => v > m ? v : m).toDouble();

    return Column(
      children: [
        SizedBox(
          height: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (i) {
              final h = 12 + (totals[i] / maxVal) * 84;
              return Container(
                width: 26,
                height: h.toDouble(),
                decoration: BoxDecoration(
                  color: AppColors.actionPrimary,
                  borderRadius: BorderRadius.circular(4),
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
                  width: 26,
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
