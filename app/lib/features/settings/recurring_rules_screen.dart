import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/cards.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/top_bar.dart';

class _RecurringRule {
  const _RecurringRule(this.title, this.schedule, this.amount, this.enabled);
  final String title;
  final String schedule;
  final num amount;
  final bool enabled;
}

/// 12 Settings / Recurring Rules
class RecurringRulesScreen extends StatefulWidget {
  const RecurringRulesScreen({super.key});

  @override
  State<RecurringRulesScreen> createState() => _RecurringRulesScreenState();
}

class _RecurringRulesScreenState extends State<RecurringRulesScreen> {
  final List<_RecurringRule> _rules = [
    const _RecurringRule('Abbu — Regular contribution', 'Monthly on the 1st', 14200, true),
    const _RecurringRule('Electricity bill', 'Monthly on the 5th', 1000, true),
    const _RecurringRule('House rent contribution', 'Monthly on the 1st', 9440, false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SimpleTopBar(
        title: 'Recurring rules',
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppColors.actionPrimary),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Pick an amount and schedule from Add Purchase / Add Contribution, then "Make recurring".')),
            ),
          ),
        ],
      ),
      body: _rules.isEmpty
          ? const EmptyState(
              icon: Icons.event_repeat_rounded,
              title: 'No recurring rules',
              message: 'Automate regular bills and contributions so you never forget to log them.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _rules.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final r = _rules[i];
                return AppCard(
                  child: Row(
                    children: [
                      const AppAvatar(icon: Icons.event_repeat_rounded, size: 36, shape: BoxShape.rectangle),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(r.title, style: AppTextStyles.labelSemibold),
                            Text(
                              '${r.schedule} · ৳${r.amount}',
                              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Switch.adaptive(
                        value: r.enabled,
                        activeThumbColor: AppColors.actionPrimary,
                        onChanged: (v) => setState(
                          () => _rules[i] = _RecurringRule(r.title, r.schedule, r.amount, v),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
