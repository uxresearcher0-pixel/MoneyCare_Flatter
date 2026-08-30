import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/cards.dart';
import '../../core/widgets/top_bar.dart';
import '../../data/providers/app_data.dart';

/// 12 Settings / Security & Privacy
class SecurityScreen extends ConsumerWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appData = ref.watch(appDataProvider);

    return Scaffold(
      appBar: const SimpleTopBar(title: 'Security & privacy'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                SwitchListTile.adaptive(
                  title: Text('Require Face ID / fingerprint', style: AppTextStyles.bodySmallSemibold),
                  subtitle: const Text('Lock the app when it goes to the background'),
                  value: appData.biometricLockEnabled,
                  activeThumbColor: AppColors.actionPrimary,
                  onChanged: (v) => appData.setPreference(biometricLock: v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _Row(icon: Icons.lock_reset_rounded, title: 'Change password'),
                _Row(icon: Icons.devices_other_rounded, title: 'Manage signed-in devices'),
                _Row(icon: Icons.policy_outlined, title: 'Privacy policy', showDivider: false),
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
