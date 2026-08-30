import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/inputs.dart';
import '../../core/widgets/top_bar.dart';
import '../../data/providers/app_data.dart';

/// 07 People / Add Person — Essentials
class AddPersonScreen extends ConsumerStatefulWidget {
  const AddPersonScreen({super.key, required this.projectId});

  final String projectId;

  @override
  ConsumerState<AddPersonScreen> createState() => _AddPersonScreenState();
}

class _AddPersonScreenState extends ConsumerState<AddPersonScreen> {
  final _name = TextEditingController();
  String _role = 'Contributor';
  String _contributionType = 'Regular';

  static const _roles = ['Contributor', 'Member', 'Admin', 'Viewer'];
  static const _types = ['Regular', 'Extra', 'Occasion'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SimpleTopBar(title: 'Add person'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView(
                children: [
                  LabeledField(label: 'Full name', hint: 'e.g. Rima Das', controller: _name),
                  const SizedBox(height: 16),
                  Text('Role', style: AppTextStyles.bodySmallSemibold),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _roles
                        .map(
                          (r) => ChoiceChip(
                            label: Text(r),
                            selected: _role == r,
                            onSelected: (_) => setState(() => _role = r),
                            showCheckmark: false,
                            selectedColor: AppColors.actionSelected,
                            labelStyle: AppTextStyles.labelMedium.copyWith(
                              color: _role == r ? AppColors.actionPrimary : AppColors.textPrimary,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  Text('Default contribution type', style: AppTextStyles.bodySmallSemibold),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _types
                        .map(
                          (t) => ChoiceChip(
                            label: Text(t),
                            selected: _contributionType == t,
                            onSelected: (_) => setState(() => _contributionType = t),
                            showCheckmark: false,
                            selectedColor: AppColors.actionSelected,
                            labelStyle: AppTextStyles.labelMedium.copyWith(
                              color: _contributionType == t ? AppColors.actionPrimary : AppColors.textPrimary,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
            PrimaryButton(
              label: 'Add person',
              radius: 10,
              onPressed: () {
                if (_name.text.trim().isEmpty) return;
                ref.read(appDataProvider).addPerson(
                      projectId: widget.projectId,
                      name: _name.text.trim(),
                      role: _role,
                      contributionType: _contributionType,
                    );
                context.pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
