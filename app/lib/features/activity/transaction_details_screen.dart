import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/cards.dart';
import '../../core/widgets/top_bar.dart';
import '../../data/models/models.dart';
import '../../data/providers/app_data.dart';

/// 11 Activity / Transaction Details — Purchase / Contribution
class TransactionDetailsScreen extends ConsumerWidget {
  const TransactionDetailsScreen({super.key, required this.transactionId});

  final String transactionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appData = ref.watch(appDataProvider);
    final t = appData.transactions[transactionId];
    if (t == null) {
      return const Scaffold(body: Center(child: Text('Transaction not found')));
    }
    final isPurchase = t.type == TransactionType.purchase;
    final category = appData.categories[t.categoryId];
    final person = appData.people[t.personId];
    final project = appData.activeProject;
    final period = appData.activePeriod;

    return Scaffold(
      // No overflow menu here: Edit/Duplicate/Delete are already primary,
      // visible actions at the bottom of this screen — a "..." menu with no
      // extra actions behind it would just be a dead affordance.
      appBar: const SimpleTopBar(title: 'Transaction Details'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StatusBadge.neutral(isPurchase ? 'Purchase' : 'Contribution'),
                    StatusBadge.positive('Completed'),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  AppFormatters.currency(isPurchase ? -t.amount : t.amount, showSign: true),
                  style: AppTextStyles.h1.copyWith(
                    fontSize: 32,
                    color: isPurchase ? AppColors.statusNegative : AppColors.statusPositive,
                  ),
                ),
                Text(t.title, style: AppTextStyles.h3),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              children: [
                if (isPurchase) _MetaRow(label: 'Category', value: category?.name ?? '—'),
                _MetaRow(label: 'Date', value: DateFormat('MMM d, y · h:mm a').format(t.date)),
                _MetaRow(label: isPurchase ? 'Purchased by' : 'Contributor', valueWidget: person != null
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppAvatar(label: person.initial, size: 18),
                          const SizedBox(width: 6),
                          Text(person.name, style: AppTextStyles.labelSemibold),
                        ],
                      )
                    : null),
                if (!isPurchase) _MetaRow(label: 'Contribution type', value: t.contributionType),
                if (isPurchase && t.quantity != null)
                  _MetaRow(label: 'Quantity', value: '${t.quantity} ${t.unit ?? ''}'),
                _MetaRow(label: 'Project', value: project?.name ?? '—'),
                _MetaRow(label: 'Period', value: period?.label ?? '—', showDivider: false),
              ],
            ),
          ),
          if (t.note.isNotEmpty) ...[
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Notes', style: AppTextStyles.captionSemibold.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Text(t.note, style: AppTextStyles.labelMedium),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Created · ${DateFormat('MMM d, y · h:mm a').format(t.date)}',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _editTransaction(context, appData, t),
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: const Text('Edit'),
                        style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(40)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          final copy = appData.duplicateTransaction(t.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Duplicated as a new transaction today')),
                          );
                          context.pushReplacement('/transaction/${copy.id}');
                        },
                        icon: const Icon(Icons.content_copy_rounded, size: 15),
                        label: const Text('Duplicate'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(40),
                          foregroundColor: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          appData.deleteTransaction(t.id);
                          context.pop();
                        },
                        icon: const Icon(Icons.delete_outline_rounded, size: 16),
                        label: const Text('Delete'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(40),
                          foregroundColor: AppColors.statusNegative,
                          side: BorderSide(color: AppColors.statusNegative),
                        ),
                      ),
                    ),
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

void _editTransaction(BuildContext context, AppData appData, AppTransaction t) {
  final titleController = TextEditingController(text: t.title);
  final amountController = TextEditingController(text: t.amount.toString());
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Edit transaction'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: titleController,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Amount', prefixText: '৳'),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(
          onPressed: () {
            appData.updateTransaction(
              t.id,
              title: titleController.text.trim().isEmpty ? null : titleController.text.trim(),
              amount: num.tryParse(amountController.text),
            );
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, this.value, this.valueWidget, this.showDivider = true});

  final String label;
  final String? value;
  final Widget? valueWidget;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: showDivider
          ? BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.borderDefault)))
          : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.captionMedium.copyWith(color: AppColors.textSecondary)),
          valueWidget ?? Text(value ?? '—', style: AppTextStyles.labelSemibold),
        ],
      ),
    );
  }
}
