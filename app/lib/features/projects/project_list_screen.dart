import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/cards.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/top_bar.dart';
import '../../data/providers/app_data.dart';

/// 04 Projects / Project List — Populated
class ProjectListScreen extends ConsumerStatefulWidget {
  const ProjectListScreen({super.key, required this.workspaceId});

  final String workspaceId;

  @override
  ConsumerState<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends ConsumerState<ProjectListScreen> {
  final _search = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final appData = ref.watch(appDataProvider);
    final workspace = appData.workspaces[widget.workspaceId];
    final projects = appData
        .projectsInWorkspace(widget.workspaceId)
        .where((p) => p.name.toLowerCase().contains(_search.text.trim().toLowerCase()))
        .toList();

    return Scaffold(
      appBar: SimpleTopBar(
        title: workspace?.name ?? 'Projects',
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle_rounded, color: AppColors.actionPrimary),
            onPressed: () => context.push('/project/create?workspaceId=${widget.workspaceId}'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search projects...',
                prefixIcon: const Icon(Icons.search_rounded, size: 18),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.borderDefault),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: projects.isEmpty
                  ? EmptyState(
                      icon: Icons.folder_open_rounded,
                      title: _search.text.isEmpty ? 'No projects yet' : 'No matching projects',
                      message: _search.text.isEmpty
                          ? 'Create a project to start tracking budgets, people and periods.'
                          : 'Try a different search term.',
                      actionLabel: _search.text.isEmpty ? 'Create project' : null,
                      onAction: _search.text.isEmpty
                          ? () => context.push('/project/create?workspaceId=${widget.workspaceId}')
                          : null,
                    )
                  : ListView.separated(
                      itemCount: projects.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final project = projects[i];
                        final isActive = appData.activeProjectId == project.id;
                        return AppCard(
                          onTap: () {
                            appData.setActiveProject(project.id);
                            context.push('/project/${project.id}');
                          },
                          child: Row(
                            children: [
                              const AppAvatar(icon: Icons.folder_rounded, size: 40, shape: BoxShape.rectangle),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(project.name, style: AppTextStyles.labelSemibold),
                                    Text(
                                      '${project.memberIds.length} members · ${project.periodIds.length} periods',
                                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                              if (isActive) StatusBadge.positive('Active'),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
