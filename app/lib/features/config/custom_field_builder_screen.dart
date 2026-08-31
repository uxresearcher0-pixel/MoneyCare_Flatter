import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/inputs.dart';
import '../../core/widgets/top_bar.dart';
import '../../data/models/models.dart';
import '../../data/providers/app_data.dart';

/// 12 Settings / Custom Field Builder
class CustomFieldBuilderScreen extends ConsumerStatefulWidget {
  const CustomFieldBuilderScreen({super.key, required this.scope});

  /// 'workspace' or 'project' — which list this field is created into.
  final String scope;

  @override
  ConsumerState<CustomFieldBuilderScreen> createState() => _CustomFieldBuilderScreenState();
}

class _CustomFieldBuilderScreenState extends ConsumerState<CustomFieldBuilderScreen> {
  final _name = TextEditingController();
  String _type = 'Text';
  final List<TextEditingController> _options = [];

  static const _types = ['Text', 'Number', 'Dropdown', 'Toggle', 'Date', 'Wallet'];

  void _create() {
    if (_name.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Give the field a name')));
      return;
    }
    final scope = widget.scope == 'workspace' ? CustomFieldScope.workspace : CustomFieldScope.project;
    final options = _options.map((c) => c.text.trim()).where((s) => s.isNotEmpty).toList();
    ref.read(appDataProvider).addCustomField(
          _name.text.trim(),
          _type,
          scope,
          detail: _type == 'Dropdown' && options.isNotEmpty ? options.join(', ') : 'Custom field',
          options: options,
        );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SimpleTopBar(title: 'New custom field'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView(
                children: [
                  LabeledField(label: 'Field name', hint: 'e.g. Payment method', controller: _name),
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
                  if (_type == 'Dropdown') ...[
                    const SizedBox(height: 16),
                    Text('Options', style: AppTextStyles.bodySmallSemibold),
                    const SizedBox(height: 8),
                    for (var i = 0; i < _options.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: TextField(
                          controller: _options[i],
                          decoration: InputDecoration(hintText: 'Option ${i + 1}'),
                        ),
                      ),
                    TextButton.icon(
                      onPressed: () => setState(() => _options.add(TextEditingController())),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Add option'),
                    ),
                  ],
                ],
              ),
            ),
            PrimaryButton(
              label: 'Create field',
              radius: 10,
              onPressed: _create,
            ),
          ],
        ),
      ),
    );
  }
}
