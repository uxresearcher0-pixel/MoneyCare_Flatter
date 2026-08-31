import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/cards.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/top_bar.dart';
import '../../data/providers/app_data.dart';

/// 12 Settings / Recurring Rules
class RecurringRulesScreen extends ConsumerWidget {
  const RecurringRulesScreen({super.key});

  void _addRule(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final scheduleController = TextEditingController();
    final amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New recurring rule'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, autofocus: true, decoration: const InputDecoration(hintText: 'e.g. Electricity bill')),
            const SizedBox(height: 8),
            TextField(controller: scheduleController, decoration: const InputDecoration(hintText: 'e.g. Monthly on the 5th')),
            const SizedBox(height: 8),
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(hintText: 'Amount', prefixText: '৳'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (titleController.text.trim().isNotEmpty) {
                ref.read(appDataProvider).addRecurringRule(
                      titleController.text.trim(),
                      scheduleController.text.trim().isEmpty ? 'Monthly' : scheduleController.text.trim(),
                      num.tryParse(amountController.text) ?? 0,
                    );
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appData = ref.watch(appDataProvider);
    final rules = appData.recurringRules.values.toList();

    return Scaffold(
      appBar: SimpleTopBar(
        title: 'Recurring rules',
        actions: [
          IconButton(
            icon: Icon(Icons.add_rounded, color: AppColors.actionPrimary),
            onPressed: () => _addRule(context, ref),
          ),
        ],
      ),
      body: rules.isEmpty
          ? const EmptyState(
              icon: Icons.event_repeat_rounded,
              title: 'No recurring rules',
              message: 'Automate regular bills and contributions so you never forget to log them.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: rules.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final r = rules[i];
                return Dismissible(
                  key: ValueKey(r.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(color: AppColors.statusNegativeBg, borderRadius: BorderRadius.circular(8)),
                    child: Icon(Icons.delete_outline_rounded, color: AppColors.statusNegative),
                  ),
                  onDismissed: (_) => appData.deleteRecurringRule(r.id),
                  child: AppCard(
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
                          onChanged: (v) => appData.setRecurringRuleEnabled(r.id, v),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
