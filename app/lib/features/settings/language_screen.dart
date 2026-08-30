import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/cards.dart';
import '../../core/widgets/top_bar.dart';
import '../../data/providers/app_data.dart';

const _languages = ['English', 'বাংলা (Bangla)', 'हिन्दी (Hindi)', 'اردو (Urdu)'];

/// 12 Settings / Language
class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appData = ref.watch(appDataProvider);

    return Scaffold(
      appBar: const SimpleTopBar(title: 'Language'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < _languages.length; i++)
                  ListTile(
                    title: Text(_languages[i], style: AppTextStyles.bodySmallSemibold),
                    trailing: Icon(
                      appData.language == _languages[i]
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: appData.language == _languages[i] ? AppColors.actionPrimary : AppColors.borderStrong,
                    ),
                    onTap: () {
                      appData.setLanguage(_languages[i]);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Language set to ${_languages[i]}')),
                      );
                      context.pop();
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Only the language label is switched in this preview build — full in-app translation is on the roadmap.',
            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
