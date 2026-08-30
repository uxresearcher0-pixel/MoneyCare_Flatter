import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/cards.dart';
import '../../data/providers/app_data.dart';

/// 03 Workspaces / Workspace List — Populated
class WorkspaceListScreen extends ConsumerWidget {
  const WorkspaceListScreen({super.key, this.embedded = false});

  /// When true, this screen is hosted inside [HomeShell]'s tab bar and
  /// should not push its own Scaffold app bar spacing twice.
  final bool embedded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appData = ref.watch(appDataProvider);
    final workspaces = appData.workspaces.values.toList();
    final activeProjectCount =
        workspaces.fold<int>(0, (sum, w) => sum + w.projectIds.length);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workspaces'),
        titleTextStyle: AppTextStyles.h2,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_rounded, color: AppColors.actionPrimary, size: 26),
            onPressed: () => context.push('/workspace/create'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search workspaces...',
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.borderDefault),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceSubtle,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${workspaces.length} workspaces', style: AppTextStyles.labelSemibold),
                Text(
                  '$activeProjectCount active projects',
                  style: AppTextStyles.captionMedium.copyWith(color: AppColors.actionPrimary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          for (final ws in workspaces)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppCard(
                padding: const EdgeInsets.all(14),
                onTap: () {
                  appData.setActiveWorkspace(ws.id);
                  context.push('/workspace/${ws.id}');
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const AppAvatar(
                          icon: Icons.family_restroom_rounded,
                          size: 44,
                          shape: BoxShape.rectangle,
                          background: AppColors.surfaceSubtle,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(ws.name, style: AppTextStyles.bodyLargeSemibold.copyWith(fontSize: 16)),
                              Text(
                                '${ws.memberCount} members',
                                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.more_vert_rounded, color: AppColors.textSecondary),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${ws.projectIds.length} active projects',
                          style: AppTextStyles.captionMedium.copyWith(color: AppColors.textSecondary),
                        ),
                        StatusBadge.neutral('Owner'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
