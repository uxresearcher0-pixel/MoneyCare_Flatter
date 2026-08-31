import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/cards.dart';
import '../../data/providers/app_data.dart';

const _contributionTypes = ['Regular', 'Extra', 'Occasion'];

/// 08 Contributions / Add Contribution — Smart Defaults
class AddContributionScreen extends ConsumerStatefulWidget {
  const AddContributionScreen({super.key});

  @override
  ConsumerState<AddContributionScreen> createState() => _AddContributionScreenState();
}

class _AddContributionScreenState extends ConsumerState<AddContributionScreen> {
  final _amount = TextEditingController();
  String? _personId;
  String _type = 'Regular';

  void _save({bool addAnother = false}) {
    final appData = ref.read(appDataProvider);
    final period = appData.activePeriod;
    final amount = num.tryParse(_amount.text);
    if (period == null || amount == null || amount <= 0 || _personId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter an amount and pick a contributor')),
      );
      return;
    }
    appData.addContribution(
      periodId: period.id,
      personId: _personId!,
      amount: amount,
      contributionType: _type,
    );
    if (addAnother) {
      setState(() => _amount.clear());
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final appData = ref.watch(appDataProvider);
    final project = appData.activeProject;
    final period = appData.activePeriod;
    final people = project != null ? appData.peopleInProject(project.id) : appData.people.values.toList();
    _personId ??= people.isNotEmpty ? people.first.id : null;
    final recents = people.where((p) => p.id != _personId).take(3).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
        title: const Text('Add contribution'),
        titleTextStyle: AppTextStyles.h3,
        actions: [IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => context.pop())],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.surfaceSubtle, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      Icon(Icons.auto_awesome_rounded, size: 20, color: AppColors.actionPrimary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${project?.name ?? 'Project'} contribution', style: AppTextStyles.bodySmallSemibold),
                            Text(
                              'Today · ${period?.label ?? ''}',
                              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderDefault),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Amount', style: AppTextStyles.captionMedium.copyWith(color: AppColors.textSecondary)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text('৳', style: AppTextStyles.h1.copyWith(color: AppColors.textSecondary, fontSize: 28)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _amount,
                              autofocus: true,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              style: AppTextStyles.h1.copyWith(fontSize: 32),
                              decoration: const InputDecoration(border: InputBorder.none, isDense: true, hintText: '0'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderDefault),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Who contributed?', style: AppTextStyles.captionMedium.copyWith(color: AppColors.textSecondary)),
                      const SizedBox(height: 10),
                      if (_personId != null)
                        Row(
                          children: [
                            AppAvatar(label: appData.people[_personId]!.initial, size: 40, background: AppColors.actionPrimary, foreground: Colors.white),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(appData.people[_personId]!.name, style: AppTextStyles.bodyLargeSemibold.copyWith(fontSize: 16)),
                                  Text('Recent contributor', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: recents
                            .map(
                              (p) => InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () => setState(() => _personId = p.id),
                                child: Container(
                                  padding: const EdgeInsets.only(left: 9, right: 10, top: 7, bottom: 7),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceSubtle,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    '${p.initial}  ${p.name}',
                                    style: AppTextStyles.captionMedium.copyWith(color: AppColors.actionPrimary),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderDefault),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.repeat_rounded, size: 20, color: AppColors.actionPrimary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: _type,
                            items: _contributionTypes
                                .map((t) => DropdownMenuItem(value: t, child: Text('$t contribution', style: AppTextStyles.bodySmallSemibold)))
                                .toList(),
                            onChanged: (v) => setState(() => _type = v ?? _type),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.surfaceSubtle, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline_rounded, size: 19, color: AppColors.actionPrimary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Only amount and contributor are required.',
                          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.borderDefault)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () => _save(),
                      style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      icon: const Icon(Icons.check_rounded, size: 20),
                      label: const Text('Save contribution'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => _save(addAnother: true),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Save and add another'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
