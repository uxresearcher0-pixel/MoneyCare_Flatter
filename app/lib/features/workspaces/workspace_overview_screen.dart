import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/cards.dart';
import '../../core/widgets/empty_state.dart';
import '../../data/providers/app_data.dart';

const _memberColors = [
  Color(0xFF34C759),
  Color(0xFF00C7BE),
  Color(0xFF007AFF),
  Color(0xFFAF52DE),
];

/// 03 Workspaces / Workspace Overview — No Projects / Populated
class WorkspaceOverviewScreen extends ConsumerWidget {
  const WorkspaceOverviewScreen({super.key, required this.workspaceId});

  final String workspaceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appData = ref.watch(appDataProvider);
    final workspace = appData.workspaces[workspaceId];
    if (workspace == null) {
      return const Scaffold(body: Center(child: Text('Workspace not found')));
    }
    final projects = appData.projectsInWorkspace(workspaceId);

    return Scaffold(
      appBar: AppBar(
        title: Text(workspace.name),
        titleTextStyle: AppTextStyles.h2,
        actions: [
          IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () => context.push('/settings')),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const AppAvatar(
                      icon: Icons.family_restroom_rounded,
                      size: 46,
                      shape: BoxShape.rectangle,
                      background: AppColors.surfaceSubtle,
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${workspace.name} workspace', style: AppTextStyles.bodySmallSemibold),
                        Text(
                          '${workspace.memberCount} members · BDT',
                          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 30,
                  child: Stack(
                    children: [
                      for (var i = 0; i < workspace.memberCount.clamp(0, 4); i++)
                        Positioned(
                          left: i * 22,
                          child: CircleAvatar(
                            radius: 15,
                            backgroundColor: _memberColors[i % _memberColors.length],
                            child: Text(
                              String.fromCharCode(65 + i),
                              style: AppTextStyles.captionBold.copyWith(color: Colors.white),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                LinkButton(label: 'Manage members', onPressed: () => context.push('/people-hub')),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (projects.isEmpty)
            SizedBox(
              height: 380,
              child: EmptyState(
                icon: Icons.folder_open_rounded,
                title: 'Create your first project',
                message: 'Projects organize budgets, people, periods and financial records.',
                actionLabel: 'Create project',
                onAction: () => context.push('/project/create?workspaceId=$workspaceId'),
              ),
            )
          else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Projects', style: AppTextStyles.bodyMediumSemibold),
                LinkButton(
                  label: '+ New project',
                  onPressed: () => context.push('/project/create?workspaceId=$workspaceId'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            for (final project in projects)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AppCard(
                  onTap: () {
                    appData.setActiveProject(project.id);
                    context.push('/project/${project.id}');
                  },
                  child: Row(
                    children: [
                      const AppAvatar(icon: Icons.folder_rounded, size: 40, shape: BoxShape.rectangle),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(project.name, style: AppTextStyles.labelSemibold),
                            Text(
                              '${project.memberIds.length} members',
                              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
