import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/cards.dart';
import '../../core/widgets/top_bar.dart';

class _ContribType {
  const _ContribType(this.name, this.description, this.icon);
  final String name;
  final String description;
  final IconData icon;
}

const _types = [
  _ContribType('Regular', 'Recurring monthly share', Icons.repeat_rounded),
  _ContribType('Extra', 'One-off additional amount', Icons.add_circle_outline_rounded),
  _ContribType('Occasion', 'Gifts, festivals, special events', Icons.celebration_rounded),
];

/// 12 Settings / Contribution Types
class ContributionTypesScreen extends StatelessWidget {
  const ContributionTypesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SimpleTopBar(
        title: 'Contribution types',
        actions: [IconButton(icon: const Icon(Icons.add_rounded, color: AppColors.actionPrimary), onPressed: () {})],
      ),
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
                const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
              ],
            ),
          );
        },
      ),
    );
  }
}
