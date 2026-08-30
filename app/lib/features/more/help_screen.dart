import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/cards.dart';
import '../../core/widgets/top_bar.dart';

/// 15 More / Help & Accessibility
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SimpleTopBar(title: 'Help & accessibility'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('GUIDES', style: AppTextStyles.captionSemibold.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: const [
                _Row(icon: Icons.play_circle_outline_rounded, title: 'Getting started'),
                _Row(icon: Icons.groups_outlined, title: 'Setting up shared contributions'),
                _Row(icon: Icons.pie_chart_outline_rounded, title: 'Understanding budgets & reports'),
                _Row(icon: Icons.help_outline_rounded, title: 'Frequently asked questions', showDivider: false),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('ACCESSIBILITY', style: AppTextStyles.captionSemibold.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                SwitchListTile.adaptive(
                  title: Text('Larger text', style: AppTextStyles.bodySmallSemibold),
                  value: false,
                  activeThumbColor: AppColors.actionPrimary,
                  onChanged: (_) {},
                ),
                SwitchListTile.adaptive(
                  title: Text('High contrast mode', style: AppTextStyles.bodySmallSemibold),
                  value: false,
                  activeThumbColor: AppColors.actionPrimary,
                  onChanged: (_) {},
                ),
                SwitchListTile.adaptive(
                  title: Text('Reduce motion', style: AppTextStyles.bodySmallSemibold),
                  value: false,
                  activeThumbColor: AppColors.actionPrimary,
                  onChanged: (_) {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('SUPPORT', style: AppTextStyles.captionSemibold.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: const [
                _Row(icon: Icons.chat_bubble_outline_rounded, title: 'Send feedback'),
                _Row(icon: Icons.bug_report_outlined, title: 'Report a problem'),
                _Row(icon: Icons.info_outline_rounded, title: 'About Money Care', showDivider: false),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.icon, required this.title, this.showDivider = true});

  final IconData icon;
  final String title;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: showDivider
            ? const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.borderDefault)))
            : null,
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.actionPrimary),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: AppTextStyles.bodySmallSemibold)),
            const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
