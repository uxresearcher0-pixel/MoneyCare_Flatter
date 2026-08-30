import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/cards.dart';
import '../../core/widgets/top_bar.dart';
import '../../data/providers/app_data.dart';

/// 07 People / Project Members — Roles & Participation
class ProjectMembersScreen extends ConsumerWidget {
  const ProjectMembersScreen({super.key, required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appData = ref.watch(appDataProvider);
    final project = appData.projects[projectId];
    final people = project != null ? appData.peopleInProject(projectId) : [];

    return Scaffold(
      appBar: SimpleTopBar(
        title: 'Members & roles',
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_rounded, color: AppColors.actionPrimary),
            onPressed: () => context.push('/project/$projectId/people/add'),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: people.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final person = people[i];
          return AppCard(
            onTap: () => context.push('/project/$projectId/people/${person.id}/setup'),
            child: Row(
              children: [
                AppAvatar(label: person.initial, size: 36),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(person.name, style: AppTextStyles.labelSemibold),
                      Text(
                        '${person.role} · ${person.contributionType}',
                        style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                if (person.isOwner) StatusBadge.warning('Owner') else StatusBadge.neutral(person.role),
              ],
            ),
          );
        },
      ),
    );
  }
}
