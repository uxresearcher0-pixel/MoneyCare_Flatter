import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/cards.dart';
import '../../core/widgets/top_bar.dart';
import '../../data/providers/app_data.dart';

/// 12 Settings / Contribution Types
class ContributionTypesScreen extends ConsumerWidget {
  const ContributionTypesScreen({super.key});

  void _addType(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New contribution type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, autofocus: true, decoration: const InputDecoration(hintText: 'e.g. Loan repayment')),
            const SizedBox(height: 8),
            TextField(controller: descController, decoration: const InputDecoration(hintText: 'Short description')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                ref.read(appDataProvider).addContributionType(nameController.text.trim(), descController.text.trim());
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _editType(BuildContext context, WidgetRef ref, String id, String name, String description) {
    final nameController = TextEditingController(text: name);
    final descController = TextEditingController(text: description);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit contribution type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, autofocus: true),
            const SizedBox(height: 8),
            TextField(controller: descController),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                ref.read(appDataProvider).renameContributionType(id, nameController.text.trim(), descController.text.trim());
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appData = ref.watch(appDataProvider);
    final types = appData.contributionTypes.values.toList();

    return Scaffold(
      appBar: SimpleTopBar(
        title: 'Contribution types',
        actions: [
          IconButton(
            icon: Icon(Icons.add_rounded, color: AppColors.actionPrimary),
            onPressed: () => _addType(context, ref),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: types.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final t = types[i];
          return Dismissible(
            key: ValueKey(t.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(color: AppColors.statusNegativeBg, borderRadius: BorderRadius.circular(8)),
              child: Icon(Icons.delete_outline_rounded, color: AppColors.statusNegative),
            ),
            onDismissed: (_) => appData.deleteContributionType(t.id),
            child: AppCard(
              onTap: () => _editType(context, ref, t.id, t.name, t.description),
              child: Row(
                children: [
                  AppAvatar(icon: t.icon, size: 36, shape: BoxShape.rectangle),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.name, style: AppTextStyles.labelSemibold),
                        Text(t.description, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  Icon(Icons.edit_outlined, size: 18, color: AppColors.textSecondary),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
