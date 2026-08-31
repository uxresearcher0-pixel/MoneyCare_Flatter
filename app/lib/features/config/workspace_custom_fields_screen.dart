import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/cards.dart';
import '../../core/widgets/top_bar.dart';
import '../../data/models/models.dart';
import '../../data/providers/app_data.dart';

/// 12 Settings / Workspace Custom Fields
///
/// Distinct from Project Fields — these apply workspace-wide, to every
/// project created inside it, rather than to a single project.
class WorkspaceCustomFieldsScreen extends ConsumerWidget {
  const WorkspaceCustomFieldsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appData = ref.watch(appDataProvider);
    final fields = appData.customFields.values.where((f) => f.scope == CustomFieldScope.workspace).toList();

    return Scaffold(
      appBar: const SimpleTopBar(title: 'Workspace custom fields'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'These fields apply to every project in this workspace, not just one — use Project Fields for project-specific ones.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          for (final field in fields)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Dismissible(
                key: ValueKey(field.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(color: AppColors.statusNegativeBg, borderRadius: BorderRadius.circular(8)),
                  child: Icon(Icons.delete_outline_rounded, color: AppColors.statusNegative),
                ),
                onDismissed: (_) => appData.deleteCustomField(field.id),
                child: AppCard(
                  onTap: () => context.push('/config/field-editor?id=${field.id}'),
                  child: Row(
                    children: [
                      const AppAvatar(icon: Icons.workspaces_rounded, size: 36, shape: BoxShape.rectangle),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(field.name, style: AppTextStyles.labelSemibold),
                            Text(field.detail, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      StatusBadge.neutral(field.type),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => context.push('/config/custom-field-builder?scope=workspace'),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add workspace field'),
            style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          ),
        ],
      ),
    );
  }
}
