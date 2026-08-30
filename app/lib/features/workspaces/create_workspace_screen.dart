import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/inputs.dart';
import '../../core/widgets/top_bar.dart';
import '../../data/providers/app_data.dart';

/// 03 Workspaces / Create Workspace — Essentials
class CreateWorkspaceScreen extends ConsumerStatefulWidget {
  const CreateWorkspaceScreen({super.key});

  @override
  ConsumerState<CreateWorkspaceScreen> createState() => _CreateWorkspaceScreenState();
}

class _CreateWorkspaceScreenState extends ConsumerState<CreateWorkspaceScreen> {
  final _name = TextEditingController();
  String _type = 'Family';

  static const _types = ['Family', 'Team', 'Personal', 'Roommates'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SimpleTopBar(title: 'Create workspace'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A workspace groups the people and projects you track money with.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            LabeledField(label: 'Workspace name', hint: "e.g. Shanto's Family", controller: _name),
            const SizedBox(height: 16),
            Text('Workspace type', style: AppTextStyles.bodySmallSemibold),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _types
                  .map(
                    (t) => ChoiceChip(
                      label: Text(t),
                      selected: _type == t,
                      onSelected: (_) => setState(() => _type = t),
                      showCheckmark: false,
                      selectedColor: AppColors.actionSelected,
                      backgroundColor: AppColors.surface,
                      side: BorderSide(
                        color: _type == t ? AppColors.actionPrimary : AppColors.borderDefault,
                      ),
                      labelStyle: AppTextStyles.labelMedium.copyWith(
                        color: _type == t ? AppColors.actionPrimary : AppColors.textPrimary,
                      ),
                    ),
                  )
                  .toList(),
            ),
            const Spacer(),
            AnimatedBuilder(
              animation: _name,
              builder: (context, _) => PrimaryButton(
                label: 'Create workspace',
                radius: 10,
                onPressed: _name.text.trim().isEmpty
                    ? null
                    : () {
                        final ws = ref.read(appDataProvider).createWorkspace(_name.text.trim());
                        context.pushReplacement('/workspace/${ws.id}');
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
