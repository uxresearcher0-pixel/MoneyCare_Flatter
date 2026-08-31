import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/cards.dart';
import '../../core/widgets/top_bar.dart';

/// 12 Settings / Sync
class SyncScreen extends StatefulWidget {
  const SyncScreen({super.key});

  @override
  State<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends State<SyncScreen> {
  bool _syncing = false;
  DateTime _lastSynced = DateTime.now().subtract(const Duration(minutes: 12));

  Future<void> _syncNow() async {
    setState(() => _syncing = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() {
      _syncing = false;
      _lastSynced = DateTime.now();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('All up to date'), backgroundColor: AppColors.actionPrimary),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SimpleTopBar(title: 'Sync'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _syncing ? Icons.sync_rounded : Icons.cloud_done_outlined,
                      color: AppColors.actionPrimary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_syncing ? 'Syncing…' : 'Up to date', style: AppTextStyles.bodySmallBold),
                          Text(
                            'Last synced ${_lastSynced.hour.toString().padLeft(2, '0')}:${_lastSynced.minute.toString().padLeft(2, '0')}',
                            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  label: _syncing ? 'Syncing…' : 'Sync now',
                  radius: 10,
                  isLoading: _syncing,
                  onPressed: _syncing ? null : _syncNow,
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
                    'Money Care currently keeps data on this device only; cloud sync across devices is on the roadmap.',
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
