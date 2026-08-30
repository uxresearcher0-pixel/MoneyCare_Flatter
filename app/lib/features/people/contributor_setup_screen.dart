import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/cards.dart';
import '../../core/widgets/inputs.dart';
import '../../core/widgets/top_bar.dart';
import '../../data/providers/app_data.dart';

/// 07 People / Contributor Setup — Essentials
class ContributorSetupScreen extends ConsumerStatefulWidget {
  const ContributorSetupScreen({super.key, required this.projectId, required this.personId});

  final String projectId;
  final String personId;

  @override
  ConsumerState<ContributorSetupScreen> createState() => _ContributorSetupScreenState();
}

class _ContributorSetupScreenState extends ConsumerState<ContributorSetupScreen> {
  late final TextEditingController _pledge;
  late String _role;
  late String _contributionType;

  @override
  void initState() {
    super.initState();
    final person = ref.read(appDataProvider).people[widget.personId]!;
    _pledge = TextEditingController(text: person.monthlyPledge.toString());
    _role = person.role;
    _contributionType = person.contributionType;
  }

  @override
  Widget build(BuildContext context) {
    final appData = ref.watch(appDataProvider);
    final person = appData.people[widget.personId]!;

    return Scaffold(
      appBar: SimpleTopBar(title: '${person.name} · Contributor setup'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCard(
              child: Row(
                children: [
                  AppAvatar(label: person.initial, size: 40),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(person.name, style: AppTextStyles.bodySmallBold),
                      Text(_role, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  Text('Role', style: AppTextStyles.bodySmallSemibold),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['Contributor', 'Member', 'Admin', 'Viewer']
                        .map(
                          (r) => ChoiceChip(
                            label: Text(r),
                            selected: _role == r,
                            onSelected: (_) => setState(() => _role = r),
                            showCheckmark: false,
                            selectedColor: AppColors.actionSelected,
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  Text('Contribution type', style: AppTextStyles.bodySmallSemibold),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['Regular', 'Extra', 'Occasion']
                        .map(
                          (t) => ChoiceChip(
                            label: Text(t),
                            selected: _contributionType == t,
                            onSelected: (_) => setState(() => _contributionType = t),
                            showCheckmark: false,
                            selectedColor: AppColors.actionSelected,
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  LabeledField(
                    label: 'Monthly pledge amount',
                    hint: '0',
                    controller: _pledge,
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            PrimaryButton(
              label: 'Save',
              radius: 10,
              onPressed: () {
                appData.updatePerson(
                  person.id,
                  role: _role,
                  contributionType: _contributionType,
                  monthlyPledge: num.tryParse(_pledge.text),
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
