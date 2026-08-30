import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/cards.dart';
import '../../core/widgets/top_bar.dart';

class _Account {
  const _Account(this.name, this.balance, this.icon);
  final String name;
  final num balance;
  final IconData icon;
}

const _accounts = [
  _Account('Grocery Fund', 18640, Icons.account_balance_wallet_rounded),
  _Account('House Rent', 42000, Icons.home_rounded),
  _Account('Emergency Savings', 96500, Icons.savings_rounded),
];

/// 12 Settings / Accounts & Wallets
class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SimpleTopBar(
        title: 'Accounts & wallets',
        actions: [IconButton(icon: const Icon(Icons.add_rounded, color: AppColors.actionPrimary), onPressed: () {})],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _accounts.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final a = _accounts[i];
          return AppCard(
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
          );
        },
      ),
    );
  }
}
