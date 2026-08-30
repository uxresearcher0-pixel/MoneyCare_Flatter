import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/cards.dart';
import '../../core/widgets/top_bar.dart';
import '../../data/providers/app_data.dart';

/// 12 Settings / Categories
class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  void _addCategory(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New category'),
        content: TextField(controller: controller, autofocus: true, decoration: const InputDecoration(hintText: 'Category name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref.read(appDataProvider).addCategory(controller.text.trim(), Icons.label_rounded);
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appData = ref.watch(appDataProvider);
    final categories = appData.categories.values.toList();

    return Scaffold(
      appBar: SimpleTopBar(
        title: 'Categories',
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppColors.actionPrimary),
            onPressed: () => _addCategory(context, ref),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final c = categories[i];
          return AppCard(
            child: Row(
              children: [
                AppAvatar(icon: c.icon, size: 32),
                const SizedBox(width: 12),
                Expanded(child: Text(c.name, style: AppTextStyles.labelSemibold)),
                const Icon(Icons.drag_handle_rounded, color: AppColors.textSecondary),
              ],
            ),
          );
        },
      ),
    );
  }
}
