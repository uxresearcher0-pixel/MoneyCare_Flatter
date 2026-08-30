import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/cards.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/top_bar.dart';
import '../../data/providers/app_data.dart';

/// 15 More / Archive
class ArchiveScreen extends ConsumerWidget {
  const ArchiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appData = ref.watch(appDataProvider);
    final archived = appData.archivedProjects;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const SimpleTopBar(title: 'Archive'),
      body: archived.isEmpty
          ? const EmptyState(
              icon: Icons.archive_outlined,
              title: 'Nothing archived yet',
              message: 'Completed projects and closed periods will show up here so your active workspace stays tidy.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: archived.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final project = archived[i];
                final workspace = appData.workspaces[project.workspaceId];
                return AppCard(
                  child: Row(
                    children: [
                      const AppAvatar(icon: Icons.folder_off_outlined, size: 40, shape: BoxShape.rectangle),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(project.name, style: AppTextStyles.labelSemibold),
                            Text(
                              workspace?.name ?? '',
                              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          appData.unarchiveProject(project.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('"${project.name}" restored')),
                          );
                        },
                        child: const Text('Restore'),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
