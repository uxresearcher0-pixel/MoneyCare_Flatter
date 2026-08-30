import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/cards.dart';
import '../../core/widgets/top_bar.dart';

class _TxType {
  const _TxType(this.name, this.description, this.icon, this.enabled);
  final String name;
  final String description;
  final IconData icon;
  final bool enabled;
}

const _types = [
  _TxType('Purchase', 'Money spent from a project fund', Icons.shopping_cart_rounded, true),
  _TxType('Contribution', 'Money paid in by a contributor', Icons.arrow_downward_rounded, true),
  _TxType('Transfer', 'Move funds between accounts or wallets', Icons.swap_horiz_rounded, true),
  _TxType('Refund', 'Money returned for a prior purchase', Icons.replay_rounded, false),
];

/// 12 Settings / Transaction Types
class TransactionTypesScreen extends StatefulWidget {
  const TransactionTypesScreen({super.key});

  @override
  State<TransactionTypesScreen> createState() => _TransactionTypesScreenState();
}

class _TransactionTypesScreenState extends State<TransactionTypesScreen> {
  final Map<String, bool> _enabled = {for (final t in _types) t.name: t.enabled};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SimpleTopBar(title: 'Transaction types'),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _types.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final t = _types[i];
          return AppCard(
            child: Row(
              children: [
                AppAvatar(icon: t.icon, size: 36, shape: BoxShape.rectangle),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.name, style: AppTextStyles.labelSemibold),
                      Text(t.description, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: _enabled[t.name] ?? true,
                  activeThumbColor: AppColors.actionPrimary,
                  onChanged: (v) => setState(() => _enabled[t.name] = v),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
