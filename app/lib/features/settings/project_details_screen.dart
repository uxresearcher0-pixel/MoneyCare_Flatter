import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/inputs.dart';
import '../../core/widgets/top_bar.dart';
import '../../data/providers/app_data.dart';

/// 12 Settings / Project Details — edit the active project's essentials.
class ProjectDetailsScreen extends ConsumerStatefulWidget {
  const ProjectDetailsScreen({super.key});

  @override
  ConsumerState<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends ConsumerState<ProjectDetailsScreen> {
  late final TextEditingController _name;
  late final TextEditingController _description;

  @override
  void initState() {
    super.initState();
    final project = ref.read(appDataProvider).activeProject;
    _name = TextEditingController(text: project?.name ?? '');
    _description = TextEditingController(text: project?.description ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appData = ref.watch(appDataProvider);
    final project = appData.activeProject;
    if (project == null) {
      return const Scaffold(body: Center(child: Text('No active project')));
    }

    return Scaffold(
      appBar: const SimpleTopBar(title: 'Project details'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView(
                children: [
                  LabeledField(label: 'Project name', controller: _name),
                  const SizedBox(height: 16),
                  LabeledField(label: 'Description', controller: _description, maxLines: 3),
                  const SizedBox(height: 16),
                  const PickerField(label: 'Currency', value: '৳ BDT — Bangladeshi Taka'),
                ],
              ),
            ),
            PrimaryButton(
              label: 'Save changes',
              radius: 10,
              onPressed: () {
                project.name = _name.text.trim().isEmpty ? project.name : _name.text.trim();
                project.description = _description.text.trim();
                appData.setActiveProject(project.id); // triggers notifyListeners
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Project details saved'), backgroundColor: AppColors.actionPrimary),
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
