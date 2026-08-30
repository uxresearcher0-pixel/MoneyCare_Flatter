import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/cards.dart';
import '../../core/widgets/top_bar.dart';

/// 12 Settings / Budget Rules
class BudgetRulesScreen extends StatefulWidget {
  const BudgetRulesScreen({super.key});

  @override
  State<BudgetRulesScreen> createState() => _BudgetRulesScreenState();
}

class _BudgetRulesScreenState extends State<BudgetRulesScreen> {
  bool _lockOverspend = false;
  bool _warnAt80 = true;
  bool _warnAt100 = true;
  double _defaultBudget = 35000;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SimpleTopBar(title: 'Budget rules'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Control how Money Care warns you (and your contributors) as spending approaches the budget.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                SwitchListTile.adaptive(
                  title: Text('Warn at 80% used', style: AppTextStyles.bodySmallSemibold),
                  subtitle: const Text('Show a "Watch" badge on the category'),
                  value: _warnAt80,
                  activeThumbColor: AppColors.actionPrimary,
                  onChanged: (v) => setState(() => _warnAt80 = v),
                ),
                const Divider(height: 1),
                SwitchListTile.adaptive(
                  title: Text('Warn at 100% used', style: AppTextStyles.bodySmallSemibold),
                  subtitle: const Text('Push a notification when a category is fully spent'),
                  value: _warnAt100,
                  activeThumbColor: AppColors.actionPrimary,
                  onChanged: (v) => setState(() => _warnAt100 = v),
                ),
                const Divider(height: 1),
                SwitchListTile.adaptive(
                  title: Text('Lock purchases over budget', style: AppTextStyles.bodySmallSemibold),
                  subtitle: const Text('Require confirmation before logging an over-budget purchase'),
                  value: _lockOverspend,
                  activeThumbColor: AppColors.actionPrimary,
                  onChanged: (v) => setState(() => _lockOverspend = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Default monthly budget for new periods', style: AppTextStyles.bodySmallSemibold),
                const SizedBox(height: 8),
                Text('৳${_defaultBudget.round()}', style: AppTextStyles.h3),
                Slider(
                  value: _defaultBudget,
                  min: 5000,
                  max: 100000,
                  divisions: 19,
                  activeColor: AppColors.actionPrimary,
                  label: '৳${_defaultBudget.round()}',
                  onChanged: (v) => setState(() => _defaultBudget = v),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
