import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/inputs.dart';
import '../../core/widgets/top_bar.dart';
import '../../data/providers/app_data.dart';

/// 12 Configuration / Field Editor — edits an existing custom field.
class FieldEditorScreen extends ConsumerStatefulWidget {
  const FieldEditorScreen({super.key, required this.fieldId});

  final String fieldId;

  @override
  ConsumerState<FieldEditorScreen> createState() => _FieldEditorScreenState();
}

class _FieldEditorScreenState extends ConsumerState<FieldEditorScreen> {
  late final TextEditingController _name;
  late String _type;
  late bool _required;
  bool _initialized = false;

  static const _types = ['Text', 'Number', 'Dropdown', 'Toggle', 'Wallet', 'Calculated Total'];

  void _init(String name, String type, bool required) {
    if (_initialized) return;
    _name = TextEditingController(text: name);
    _type = type;
    _required = required;
    _initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final appData = ref.watch(appDataProvider);
    final field = appData.customFields[widget.fieldId];
    if (field == null) {
      return const Scaffold(body: Center(child: Text('Field not found')));
    }
    _init(field.name, field.type, field.required);

    return Scaffold(
      appBar: SimpleTopBar(
        title: 'Field editor',
        actions: [
          TextButton(
            onPressed: () {
              appData.deleteCustomField(field.id);
              context.pop();
            },
            child: Text('Delete', style: AppTextStyles.bodySmallSemibold.copyWith(color: AppColors.statusNegative)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView(
                children: [
                  LabeledField(label: 'Field name', hint: 'e.g. Monthly Budget Cap', controller: _name),
                  const SizedBox(height: 16),
                  Text('Field type', style: AppTextStyles.bodySmallSemibold),
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
                            labelStyle: AppTextStyles.labelMedium.copyWith(
                              color: _type == t ? AppColors.actionPrimary : AppColors.textPrimary,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  if (_type == 'Calculated Total') ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSubtle,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.functions_rounded, size: 18, color: AppColors.actionPrimary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Sum of all category budget fields',
                              style: AppTextStyles.captionMedium.copyWith(color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    activeThumbColor: AppColors.actionPrimary,
                    title: Text('Required on entry', style: AppTextStyles.bodySmallSemibold),
                    value: _required,
                    onChanged: (v) => setState(() => _required = v),
                  ),
                ],
              ),
            ),
            PrimaryButton(
              label: 'Save field',
              radius: 10,
              onPressed: () {
                appData.updateCustomField(field.id, name: _name.text.trim(), type: _type, required: _required);
                context.pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
