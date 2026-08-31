import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/cards.dart';
import '../../core/widgets/top_bar.dart';
import '../../data/providers/app_data.dart';

const _privacyPolicyText = '''
Money Care stores everything you enter — workspaces, projects, people, '''
    '''transactions and settings — on this device only, for the current app '''
    '''session. Nothing is uploaded to a Money Care server, because Money '''
    '''Care doesn't operate one: there is no backend in this build.

Account sign-in and passwords in this version are local placeholders '''
    '''used to demonstrate the flow, not a real authentication system.

If a future version adds cloud sync or backup, this policy will be '''
    '''updated before that happens, and it will be opt-in.
''';

/// 12 Settings / Security & Privacy
class SecurityScreen extends ConsumerWidget {
  const SecurityScreen({super.key});

  void _needsBackend(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature needs a connected account backend — not available in this local-only build.')),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy policy'),
        content: SingleChildScrollView(child: Text(_privacyPolicyText, style: AppTextStyles.bodyMedium)),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

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
                _Row(
                  icon: Icons.lock_reset_rounded,
                  title: 'Change password',
                  onTap: () => _needsBackend(context, 'Password management'),
                ),
                _Row(
                  icon: Icons.devices_other_rounded,
                  title: 'Manage signed-in devices',
                  onTap: () => _needsBackend(context, 'Device management'),
                ),
                _Row(
                  icon: Icons.policy_outlined,
                  title: 'Privacy policy',
                  showDivider: false,
                  onTap: () => _showPrivacyPolicy(context),
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
