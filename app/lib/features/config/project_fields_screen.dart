import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/cards.dart';
import '../../core/widgets/top_bar.dart';
import '../../data/models/models.dart';
import '../../data/providers/app_data.dart';

/// 12 Configuration / Project Fields — Monthly Grocery
class ProjectFieldsScreen extends ConsumerWidget {
  const ProjectFieldsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appData = ref.watch(appDataProvider);
    final fields = appData.customFields.values.where((f) => f.scope == CustomFieldScope.project).toList();

    return Scaffold(
      appBar: SimpleTopBar(
        title: 'Project fields',
        actions: [
          IconButton(
            icon: Icon(Icons.dashboard_customize_outlined, color: AppColors.actionPrimary),
            onPressed: () => context.push('/config/field-templates'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Custom fields let you capture extra structured information for every purchase in this project.',
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
                      const AppAvatar(icon: Icons.view_list_rounded, size: 36, shape: BoxShape.rectangle),
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
            onPressed: () => context.push('/config/custom-field-builder?scope=project'),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add custom field'),
            style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          ),
        ],
      ),
    );
  }
}
