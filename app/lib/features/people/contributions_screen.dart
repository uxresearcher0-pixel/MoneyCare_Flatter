import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/cards.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/top_bar.dart';
import '../../data/providers/app_data.dart';

/// 07 People / Contributions — Default
class ContributionsScreen extends ConsumerWidget {
  const ContributionsScreen({super.key, required this.personId});

  final String personId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appData = ref.watch(appDataProvider);
    final person = appData.people[personId];
    final period = appData.activePeriod;
    final contributions = (period != null && person != null)
        ? appData.contributionsInPeriod(period.id).where((t) => t.personId == personId).toList()
        : [];

    return Scaffold(
      appBar: SimpleTopBar(title: '${person?.name ?? ''} contributions'),
      body: contributions.isEmpty
          ? const EmptyState(
              icon: Icons.volunteer_activism_rounded,
              title: 'No contributions yet',
              message: 'Contributions logged for this person will appear here.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: contributions.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final t = contributions[i];
                return AppCard(
                  child: Row(
                    children: [
                      const AppAvatar(icon: Icons.arrow_downward_rounded, size: 32, shape: BoxShape.rectangle, background: AppColors.surfaceSubtle, foreground: AppColors.statusPositive),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t.contributionType, style: AppTextStyles.labelSemibold),
                            Text(
                              AppFormatters.relativeDay(t.date),
                              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        AppFormatters.currency(t.amount, showSign: true),
                        style: AppTextStyles.labelSemibold.copyWith(color: AppColors.statusPositive),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
