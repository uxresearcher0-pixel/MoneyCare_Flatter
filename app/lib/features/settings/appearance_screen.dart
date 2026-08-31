import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/cards.dart';
import '../../core/widgets/top_bar.dart';
import '../../data/providers/app_data.dart';

/// 12 Settings / Appearance — real Light/Dark/System switching.
class AppearanceScreen extends ConsumerWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appData = ref.watch(appDataProvider);

    Widget option(ThemeMode mode, String label, String subtitle, IconData icon) {
      final selected = appData.themeMode == mode;
      return AppCard(
        onTap: () => appData.setThemeMode(mode),
        color: selected ? AppColors.actionSelected : AppColors.surface,
        child: Row(
          children: [
            Icon(icon, color: AppColors.actionPrimary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTextStyles.bodySmallSemibold),
                  Text(subtitle, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
              color: selected ? AppColors.actionPrimary : AppColors.borderStrong,
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: const SimpleTopBar(title: 'Appearance'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          option(ThemeMode.light, 'Light', "Money Care's signature light palette", Icons.light_mode_rounded),
          const SizedBox(height: 10),
          option(ThemeMode.dark, 'Dark', 'Dark system dialogs, switches and controls', Icons.dark_mode_rounded),
          const SizedBox(height: 10),
          option(ThemeMode.system, 'System', 'Match your device setting', Icons.settings_suggest_rounded),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.surfaceSubtle, borderRadius: BorderRadius.circular(10)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, size: 16, color: AppColors.actionPrimary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "This preview build's screens are hand-styled to match the Figma light design, so Dark/System currently reskins native "
                    'dialogs, menus and switches rather than every screen — a full dark palette for every screen is on the roadmap.',
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
