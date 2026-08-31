import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/cards.dart';
import '../../core/widgets/top_bar.dart';
import '../../data/providers/app_data.dart';

/// 12 Settings / Carry-Forward Settings
class CarryForwardScreen extends ConsumerStatefulWidget {
  const CarryForwardScreen({super.key});

  @override
  ConsumerState<CarryForwardScreen> createState() => _CarryForwardScreenState();
}

class _CarryForwardScreenState extends ConsumerState<CarryForwardScreen> {
  bool _carryForward = true;
  bool _carryOverspend = false;

  @override
  Widget build(BuildContext context) {
    final appData = ref.watch(appDataProvider);
    final period = appData.activePeriod;
    final balance = period != null ? appData.availableBalance(period.id) : 0;

    return Scaffold(
      appBar: const SimpleTopBar(title: 'Carry-forward settings'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Decide what happens to the leftover balance when a period ends.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                SwitchListTile.adaptive(
                  title: Text('Carry forward remaining balance', style: AppTextStyles.bodySmallSemibold),
                  subtitle: Text(
                    'Next period opens with ${AppFormatters.currency(balance)} already in it',
                  ),
                  value: _carryForward,
                  activeThumbColor: AppColors.actionPrimary,
                  onChanged: (v) => setState(() => _carryForward = v),
                ),
                const Divider(height: 1),
                SwitchListTile.adaptive(
                  title: Text('Carry forward overspend as a deficit', style: AppTextStyles.bodySmallSemibold),
                  subtitle: const Text('If a period ends over budget, start the next one negative'),
                  value: _carryOverspend,
                  activeThumbColor: AppColors.actionPrimary,
                  onChanged: (v) => setState(() => _carryOverspend = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (period != null)
            AppCard(
              color: AppColors.actionSelected,
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 18, color: AppColors.actionPrimary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${period.label} currently carries forward ${AppFormatters.currency(period.openingBalance)}.',
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
