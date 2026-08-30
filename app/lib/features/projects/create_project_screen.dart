import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/cards.dart';
import '../../core/widgets/inputs.dart';
import '../../core/widgets/wizard_progress.dart';
import '../../data/models/models.dart';
import '../../data/providers/app_data.dart';

/// 04 Projects / Create Project — Essentials & Add People (2-step wizard)
class CreateProjectScreen extends ConsumerStatefulWidget {
  const CreateProjectScreen({super.key, this.workspaceId});

  final String? workspaceId;

  @override
  ConsumerState<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends ConsumerState<CreateProjectScreen> {
  int _step = 1;
  final _name = TextEditingController(text: '');
  final _description = TextEditingController();
  ProjectIconKind _icon = ProjectIconKind.cart;
  String _type = 'Budget';
  final Set<String> _selectedMembers = {};

  static const _iconMap = {
    ProjectIconKind.folder: Icons.folder_rounded,
    ProjectIconKind.home: Icons.home_rounded,
    ProjectIconKind.cart: Icons.shopping_cart_rounded,
    ProjectIconKind.flight: Icons.flight_rounded,
    ProjectIconKind.gift: Icons.card_giftcard_rounded,
    ProjectIconKind.wallet: Icons.account_balance_wallet_rounded,
  };

  void _pickIcon() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: _iconMap.entries
              .map(
                (e) => ListTile(
                  leading: Icon(e.value, color: AppColors.actionPrimary),
                  title: Text(e.key.name),
                  onTap: () {
                    setState(() => _icon = e.key);
                    Navigator.pop(context);
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appData = ref.watch(appDataProvider);
    final workspaceId = widget.workspaceId ?? appData.activeWorkspaceId!;
    final workspace = appData.workspaces[workspaceId];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.borderDefault),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.arrow_back_rounded, size: 18),
                      onPressed: () {
                        if (_step == 2) {
                          setState(() => _step = 1);
                        } else {
                          context.pop();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('Create Project', style: AppTextStyles.h3),
                  const Spacer(),
                  TextButton(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Draft saved — pick up where you left off any time')),
                    ),
                    child: Text('Save Draft', style: AppTextStyles.bodySmallSemibold.copyWith(color: AppColors.actionPrimary)),
                  ),
                ],
              ),
            ),
            WizardProgress(
              totalSteps: 5,
              currentStep: _step == 1 ? 2 : 4,
              stepLabel: _step == 1 ? 'Details' : 'People',
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _step == 1 ? _buildEssentials() : _buildPeople(appData, workspace),
              ),
            ),
            WizardActionBar(
              showBack: _step == 2,
              onBack: () => setState(() => _step = 1),
              continueLabel: _step == 1 ? 'Continue' : 'Create Project',
              onContinue: () {
                if (_step == 1) {
                  if (_name.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Give your project a name')),
                    );
                    return;
                  }
                  setState(() => _step = 2);
                } else {
                  final project = appData.createProject(
                    workspaceId: workspaceId,
                    name: _name.text.trim(),
                    description: _description.text.trim(),
                    icon: _icon,
                    memberIds: _selectedMembers.toList(),
                  );
                  context.pushReplacement('/project/${project.id}');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEssentials() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LabeledField(label: 'Project Name', hint: 'Monthly Grocery', controller: _name),
          const SizedBox(height: 16),
          LabeledField(
            label: 'Description',
            hint: 'Track and manage monthly grocery purchases',
            controller: _description,
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          Text('Icon', style: AppTextStyles.bodySmallSemibold),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 40,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_iconMap[_icon], size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text('${_icon.name[0].toUpperCase()}${_icon.name.substring(1)} Icon', style: AppTextStyles.bodyMedium),
              ),
              InkWell(
                onTap: _pickIcon,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.actionSelected,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('Change', style: AppTextStyles.labelSemibold.copyWith(color: AppColors.actionPrimary)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          PickerField(
            label: 'Project Type',
            value: _type,
            onTap: () async {
              final result = await showModalBottomSheet<String>(
                context: context,
                builder: (context) => SafeArea(
                  child: Wrap(
                    children: ['Budget', 'Savings goal', 'Event', 'Trip']
                        .map((t) => ListTile(title: Text(t), onTap: () => Navigator.pop(context, t)))
                        .toList(),
                  ),
                ),
              );
              if (result != null) setState(() => _type = result);
            },
          ),
          const SizedBox(height: 16),
          const PickerField(label: 'Currency', value: '৳ BDT — Bangladeshi Taka', icon: Icons.expand_more_rounded),
          const SizedBox(height: 16),
          Row(
            children: const [
              Expanded(child: PickerField(label: 'Start Date', value: 'Aug 1, 2026', icon: Icons.calendar_today_rounded)),
              SizedBox(width: 12),
              Expanded(child: PickerField(label: 'End Date', value: 'Aug 31, 2026', icon: Icons.calendar_today_rounded)),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddMemberDialog(AppData appData) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add member'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Full name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                final person = appData.addPerson(
                  projectId: 'draft',
                  name: controller.text.trim(),
                );
                setState(() => _selectedMembers.add(person.id));
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildPeople(AppData appData, Workspace? workspace) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('PROJECT OWNER', style: AppTextStyles.captionSemibold.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              Row(
                children: [
                  AppAvatar(label: appData.currentUser.initial, size: 36),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(appData.currentUser.name, style: AppTextStyles.bodySmallBold),
                      const SizedBox(height: 2),
                      StatusBadge.neutral('Owner'),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MEMBERS (${_selectedMembers.length})',
                style: AppTextStyles.captionSemibold.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              for (final person in appData.people.values)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      AppAvatar(label: person.initial, size: 32),
                      const SizedBox(width: 12),
                      Expanded(child: Text(person.name, style: AppTextStyles.labelSemibold)),
                      Checkbox(
                        value: _selectedMembers.contains(person.id),
                        activeColor: AppColors.actionPrimary,
                        onChanged: (v) => setState(() {
                          if (v == true) {
                            _selectedMembers.add(person.id);
                          } else {
                            _selectedMembers.remove(person.id);
                          }
                        }),
                      ),
                    ],
                  ),
                ),
              const Divider(),
              const SizedBox(height: 4),
              Center(
                child: TextButton.icon(
                  onPressed: () => _showAddMemberDialog(appData),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add Members'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.borderDefault),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.shield_outlined, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Admins can manage members and delete projects. Editors can log expenses and add funds. Viewers can only inspect activity.',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
