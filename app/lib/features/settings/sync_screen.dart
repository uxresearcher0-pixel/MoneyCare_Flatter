import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart' show Share;

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/cards.dart';
import '../../core/widgets/top_bar.dart';
import '../../data/providers/app_data.dart';

/// 12 Settings / Household & Sync — real-time collaboration boundary.
/// Everyone who joins this household (via the invite code below) sees the
/// same workspaces, projects, people and transactions live, and nothing is
/// lost when the app is closed.
class SyncScreen extends ConsumerStatefulWidget {
  const SyncScreen({super.key});

  @override
  ConsumerState<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends ConsumerState<SyncScreen> {
  bool _joining = false;

  Future<void> _joinHousehold(AppData appData) async {
    final controller = TextEditingController();
    final code = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Join a household'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter the 6-character invite code shared with you.'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              textCapitalization: TextCapitalization.characters,
              maxLength: 6,
              decoration: const InputDecoration(hintText: 'e.g. 7K2QXM'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Join'),
          ),
        ],
      ),
    );
    if (code == null || code.isEmpty || !mounted) return;

    setState(() => _joining = true);
    try {
      await appData.joinHouseholdByCode(code);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("You're in! Loading the household's data…")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: AppColors.statusNegative,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _joining = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appData = ref.watch(appDataProvider);

    if (!appData.isFirebaseBacked) {
      return Scaffold(
        appBar: const SimpleTopBar(title: 'Household & Sync'),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.cloud_off_rounded, color: AppColors.textSecondary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text('Running in local demo mode', style: AppTextStyles.bodySmallBold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This build (web preview) keeps data on this device only. Install the Android '
                    'app to get a real account with cloud sync and household collaboration.',
                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final memberCount = appData.householdMemberIds.length;

    return Scaffold(
      appBar: const SimpleTopBar(title: 'Household & Sync'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.cloud_done_rounded, color: AppColors.actionPrimary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appData.householdName.isEmpty ? 'Household' : appData.householdName,
                            style: AppTextStyles.bodySmallBold,
                          ),
                          Text(
                            '$memberCount ${memberCount == 1 ? 'member' : 'members'} · synced live',
                            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('INVITE MEMBERS', style: AppTextStyles.captionSemibold.copyWith(color: AppColors.textSecondary, letterSpacing: 0.6)),
          const SizedBox(height: 8),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Share this code with family members. Anyone who enters it (or joins from a new '
                  'account) sees the same projects, people and transactions as you — in real time.',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderDefault),
                  ),
                  child: Center(
                    child: Text(
                      appData.householdInviteCode.isEmpty ? '——————' : appData.householdInviteCode,
                      style: AppTextStyles.h1.copyWith(letterSpacing: 6),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: SecondaryButton(
                        label: 'Copy code',
                        radius: 10,
                        icon: Icons.copy_rounded,
                        onPressed: appData.householdInviteCode.isEmpty
                            ? null
                            : () async {
                                await Clipboard.setData(ClipboardData(text: appData.householdInviteCode));
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Invite code copied')),
                                  );
                                }
                              },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: PrimaryButton(
                        label: 'Share',
                        radius: 10,
                        icon: Icons.ios_share_rounded,
                        onPressed: appData.householdInviteCode.isEmpty
                            ? null
                            : () => Share.share(
                                  'Join our Money Care household — enter this code in the app: '
                                  '${appData.householdInviteCode}',
                                ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('JOIN A HOUSEHOLD', style: AppTextStyles.captionSemibold.copyWith(color: AppColors.textSecondary, letterSpacing: 0.6)),
          const SizedBox(height: 8),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Have a code from someone else's household? Joining switches you over to their "
                  'shared data — your current household stays intact if you want to switch back later.',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                SecondaryButton(
                  label: _joining ? 'Joining…' : 'Enter invite code',
                  radius: 10,
                  onPressed: _joining ? null : () => _joinHousehold(appData),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.surfaceSubtle, borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 16, color: AppColors.actionPrimary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Money Care syncs everything to the cloud automatically — there is no manual sync '
                    'step. Changes made offline are sent as soon as you reconnect.',
                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
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
