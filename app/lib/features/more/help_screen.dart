import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/cards.dart';
import '../../core/widgets/top_bar.dart';
import '../../data/providers/app_data.dart';

const _guides = {
  'Getting started':
      'Create a workspace, then a project inside it (e.g. "Monthly Grocery"). '
          'Open the project to start a period — most people use one calendar '
          'month per period. Log purchases and contributions against the '
          'active period from the + button.',
  'Setting up shared contributions':
      'Add each contributor from Project → People. Give them a monthly '
          'pledge amount and a contribution type (Regular, Extra, or '
          'Occasion). When they pay in, log it with Add Contribution — the '
          'dashboard tracks who has paid and who is still owed for the period.',
  'Understanding budgets & reports':
      'Set a monthly budget on the period to see "% used" on the dashboard. '
          'Reports → Spending breaks purchases down by category so you can '
          'see where the money actually went, not just how much is left.',
};

const _faq = [
  ('Is my data backed up anywhere?', 'Not in this build — everything lives on this device for the current session only. See Privacy policy under Security & privacy for details.'),
  ('Can I have more than one project?', 'Yes — a workspace can hold multiple projects (e.g. "Monthly Grocery" and "House Rent"), each with its own budget, people and periods.'),
  ('What happens when I close a period?', 'Closing a period locks it from new entries and carries its remaining balance forward as the opening balance of the next period.'),
];

/// 15 More / Help & Accessibility
class HelpScreen extends ConsumerWidget {
  const HelpScreen({super.key});

  void _showTextDialog(BuildContext context, String title, String body) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(child: Text(body, style: AppTextStyles.bodyMedium)),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  void _showFaq(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Frequently asked questions'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (q, a) in _faq) ...[
                Text(q, style: AppTextStyles.bodySmallBold),
                const SizedBox(height: 4),
                Text(a, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 14),
              ],
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  void _composeAndShare(BuildContext context, String title, String hint) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(controller: controller, autofocus: true, maxLines: 4, decoration: InputDecoration(hintText: hint)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (controller.text.trim().isNotEmpty) {
                Share.share('Money Care — $title\n\n${controller.text.trim()}');
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appData = ref.watch(appDataProvider);

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
              children: [
                for (final entry in _guides.entries)
                  _Row(
                    icon: Icons.play_circle_outline_rounded,
                    title: entry.key,
                    onTap: () => _showTextDialog(context, entry.key, entry.value),
                    showDivider: entry.key != _guides.keys.last,
                  ),
                _Row(icon: Icons.help_outline_rounded, title: 'Frequently asked questions', onTap: () => _showFaq(context), showDivider: false),
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
                  value: appData.largerTextEnabled,
                  activeThumbColor: AppColors.actionPrimary,
                  onChanged: (v) => appData.setAccessibility(largerText: v),
                ),
                SwitchListTile.adaptive(
                  title: Text('High contrast mode', style: AppTextStyles.bodySmallSemibold),
                  value: appData.highContrastEnabled,
                  activeThumbColor: AppColors.actionPrimary,
                  onChanged: (v) => appData.setAccessibility(highContrast: v),
                ),
                SwitchListTile.adaptive(
                  title: Text('Reduce motion', style: AppTextStyles.bodySmallSemibold),
                  value: appData.reduceMotionEnabled,
                  activeThumbColor: AppColors.actionPrimary,
                  onChanged: (v) => appData.setAccessibility(reduceMotion: v),
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
              children: [
                _Row(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: 'Send feedback',
                  onTap: () => _composeAndShare(context, 'Send feedback', "What's on your mind?"),
                ),
                _Row(
                  icon: Icons.bug_report_outlined,
                  title: 'Report a problem',
                  onTap: () => _composeAndShare(context, 'Report a problem', 'What went wrong?'),
                ),
                _Row(
                  icon: Icons.info_outline_rounded,
                  title: 'About Money Care',
                  showDivider: false,
                  onTap: () => showAboutDialog(
                    context: context,
                    applicationName: 'Money Care',
                    applicationVersion: '1.0.0',
                    applicationLegalese: 'Simple money management for everyday life.',
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

class _Row extends StatelessWidget {
  const _Row({required this.icon, required this.title, required this.onTap, this.showDivider = true});

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: showDivider
            ? BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.borderDefault)))
            : null,
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.actionPrimary),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: AppTextStyles.bodySmallSemibold)),
            Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
