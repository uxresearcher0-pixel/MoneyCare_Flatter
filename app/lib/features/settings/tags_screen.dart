import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/top_bar.dart';

/// 12 Settings / Tags
class TagsScreen extends StatefulWidget {
  const TagsScreen({super.key});

  @override
  State<TagsScreen> createState() => _TagsScreenState();
}

class _TagsScreenState extends State<TagsScreen> {
  final List<String> _tags = ['grocery', 'fish', 'bills', 'urgent', 'shared', 'reimbursable'];

  void _addTag() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New tag'),
        content: TextField(controller: controller, autofocus: true, decoration: const InputDecoration(hintText: 'tag-name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final v = controller.text.trim().toLowerCase();
              if (v.isNotEmpty && !_tags.contains(v)) setState(() => _tags.add(v));
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SimpleTopBar(
        title: 'Tags',
        actions: [IconButton(icon: const Icon(Icons.add_rounded, color: AppColors.actionPrimary), onPressed: _addTag)],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _tags
              .map(
                (tag) => Chip(
                  label: Text('#$tag', style: AppTextStyles.labelMedium.copyWith(color: AppColors.actionPrimary)),
                  backgroundColor: AppColors.actionSelected,
                  deleteIcon: const Icon(Icons.close_rounded, size: 16, color: AppColors.actionPrimary),
                  onDeleted: () => setState(() => _tags.remove(tag)),
                  side: BorderSide.none,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
