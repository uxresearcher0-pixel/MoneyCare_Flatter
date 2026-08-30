import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/inputs.dart';
import '../../core/widgets/top_bar.dart';
import '../../data/providers/app_data.dart';

/// 05 Periods / Create Period — Essentials
class CreatePeriodScreen extends ConsumerStatefulWidget {
  const CreatePeriodScreen({super.key, required this.projectId});

  final String projectId;

  @override
  ConsumerState<CreatePeriodScreen> createState() => _CreatePeriodScreenState();
}

class _CreatePeriodScreenState extends ConsumerState<CreatePeriodScreen> {
  final _label = TextEditingController(text: 'September 2026');
  final _opening = TextEditingController(text: '0');
  final _budget = TextEditingController(text: '35000');
  DateTime _start = DateTime(2026, 9, 1);
  DateTime _end = DateTime(2026, 9, 30);
  bool _makeActive = true;

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _start : _end,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() => isStart ? _start = picked : _end = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SimpleTopBar(title: 'Create period'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView(
                children: [
                  LabeledField(label: 'Period label', hint: 'September 2026', controller: _label),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: PickerField(
                          label: 'Start date',
                          value: '${_start.month}/${_start.day}/${_start.year}',
                          icon: Icons.calendar_today_rounded,
                          onTap: () => _pickDate(true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: PickerField(
                          label: 'End date',
                          value: '${_end.month}/${_end.day}/${_end.year}',
                          icon: Icons.calendar_today_rounded,
                          onTap: () => _pickDate(false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LabeledField(
                    label: 'Opening balance',
                    hint: '0',
                    controller: _opening,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  LabeledField(
                    label: 'Monthly budget',
                    hint: '35000',
                    controller: _budget,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    activeThumbColor: AppColors.actionPrimary,
                    title: Text('Make this the active period', style: AppTextStyles.bodySmallSemibold),
                    value: _makeActive,
                    onChanged: (v) => setState(() => _makeActive = v),
                  ),
                ],
              ),
            ),
            PrimaryButton(
              label: 'Create period',
              radius: 10,
              onPressed: () {
                final period = ref.read(appDataProvider).createPeriod(
                      projectId: widget.projectId,
                      label: _label.text.trim(),
                      start: _start,
                      end: _end,
                      openingBalance: num.tryParse(_opening.text) ?? 0,
                      monthlyBudget: num.tryParse(_budget.text) ?? 0,
                      makeActive: _makeActive,
                    );
                if (period.id.isNotEmpty) context.go('/home');
              },
            ),
          ],
        ),
      ),
    );
  }
}
