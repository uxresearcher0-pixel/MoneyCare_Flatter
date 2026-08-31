import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/cards.dart';
import '../../core/widgets/top_bar.dart';
import '../../data/providers/app_data.dart';

/// 12 Settings / Units
class UnitsScreen extends ConsumerWidget {
  const UnitsScreen({super.key});

  void _addUnit(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final abbrController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New unit'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, autofocus: true, decoration: const InputDecoration(hintText: 'e.g. Bag')),
            const SizedBox(height: 8),
            TextField(controller: abbrController, decoration: const InputDecoration(hintText: 'Short form, e.g. bag')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty && abbrController.text.trim().isNotEmpty) {
                ref.read(appDataProvider).addUnit(nameController.text.trim(), abbrController.text.trim());
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
    final units = appData.units.values.toList();

    return Scaffold(
      appBar: SimpleTopBar(
        title: 'Units',
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppColors.actionPrimary),
            onPressed: () => _addUnit(context, ref),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: units.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final u = units[i];
          return Dismissible(
            key: ValueKey(u.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(color: AppColors.statusNegativeBg, borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.delete_outline_rounded, color: AppColors.statusNegative),
            ),
            onDismissed: (_) => appData.deleteUnit(u.id),
            child: AppCard(
              child: Row(
                children: [
                  AppAvatar(label: u.abbr, size: 32),
                  const SizedBox(width: 12),
                  Expanded(child: Text(u.name, style: AppTextStyles.labelSemibold)),
                  Text(u.abbr, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
