import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/cards.dart';
import '../../core/widgets/top_bar.dart';
import '../../data/providers/app_data.dart';

/// 12 Settings / Accounts & Wallets
class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  void _addAccount(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final balanceController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, autofocus: true, decoration: const InputDecoration(hintText: 'e.g. Travel Fund')),
            const SizedBox(height: 8),
            TextField(
              controller: balanceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(hintText: 'Opening balance (optional)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                ref.read(appDataProvider).addAccount(
                      nameController.text.trim(),
                      balance: num.tryParse(balanceController.text) ?? 0,
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
    final accounts = appData.accounts.values.toList();

    return Scaffold(
      appBar: SimpleTopBar(
        title: 'Accounts & wallets',
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppColors.actionPrimary),
            onPressed: () => _addAccount(context, ref),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: accounts.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final a = accounts[i];
          return Dismissible(
            key: ValueKey(a.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(color: AppColors.statusNegativeBg, borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.delete_outline_rounded, color: AppColors.statusNegative),
            ),
            onDismissed: (_) => appData.deleteAccount(a.id),
            child: AppCard(
              child: Row(
                children: [
                  AppAvatar(icon: a.icon, size: 40, shape: BoxShape.rectangle),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(a.name, style: AppTextStyles.labelSemibold),
                        Text('Wallet', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  Text(AppFormatters.currency(a.balance), style: AppTextStyles.bodySmallBold),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
