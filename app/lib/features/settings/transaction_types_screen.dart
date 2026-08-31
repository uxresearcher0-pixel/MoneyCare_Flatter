import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/cards.dart';
import '../../core/widgets/top_bar.dart';
import '../../data/providers/app_data.dart';

/// 12 Settings / Transaction Types
class TransactionTypesScreen extends ConsumerWidget {
  const TransactionTypesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appData = ref.watch(appDataProvider);
    final types = appData.txKindConfigs.values.toList();

    return Scaffold(
      appBar: const SimpleTopBar(title: 'Transaction types'),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: types.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final t = types[i];
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
                  value: t.enabled,
                  activeThumbColor: AppColors.actionPrimary,
                  onChanged: (v) => appData.setTxKindEnabled(t.id, v),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
