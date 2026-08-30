import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/cards.dart';
import '../../data/providers/app_data.dart';

/// 07 People / People Hub — Default
class PeopleHubScreen extends ConsumerStatefulWidget {
  const PeopleHubScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  ConsumerState<PeopleHubScreen> createState() => _PeopleHubScreenState();
}

class _PeopleHubScreenState extends ConsumerState<PeopleHubScreen> {
  int _tab = 0; // 0 = People, 1 = Contributions
  String _filter = 'All';
  final _search = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final appData = ref.watch(appDataProvider);
    final project = appData.activeProject;
    final period = appData.activePeriod;
    final people = project != null ? appData.peopleInProject(project.id) : appData.people.values.toList();
    final query = _search.text.trim().toLowerCase();
    final filtered = people.where((p) {
      if (query.isNotEmpty && !p.name.toLowerCase().contains(query)) return false;
      if (_filter == 'All') return true;
      if (_filter == 'Owners') return p.isOwner;
      if (_filter == 'Contributors') return p.contributionType.isNotEmpty && !p.isOwner;
      if (_filter == 'Members') return !p.isOwner;
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('People'),
        titleTextStyle: AppTextStyles.h2,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          if (project != null && period != null)
            AppCard(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const AppAvatar(icon: Icons.folder_rounded, size: 32, shape: BoxShape.rectangle),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(project.name, style: AppTextStyles.labelSemibold),
                        Text(period.label, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  const Icon(Icons.expand_more_rounded, size: 18),
                ],
              ),
            ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: const Color(0xFFEAE8E4), borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                Expanded(child: _SegButton(label: 'People', selected: _tab == 0, onTap: () => setState(() => _tab = 0))),
                Expanded(
                  child: _SegButton(
                    label: 'Contributions',
                    selected: _tab == 1,
                    onTap: () => setState(() => _tab = 1),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (_tab == 0) ...[
            TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search name...',
                prefixIcon: const Icon(Icons.search_rounded, size: 18),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.borderDefault),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: ['All', 'Contributors', 'Members', 'Owners']
                  .map(
                    (f) => ChoiceChip(
                      label: Text(f),
                      selected: _filter == f,
                      onSelected: (_) => setState(() => _filter = f),
                      showCheckmark: false,
                      selectedColor: AppColors.actionPrimary,
                      labelStyle: AppTextStyles.captionSemibold.copyWith(
                        color: _filter == f ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${filtered.length} people', style: AppTextStyles.bodyMediumSemibold),
                FilledButton.icon(
                  onPressed: () {
                    if (project != null) context.push('/project/${project.id}/people/add');
                  },
                  style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text('Add Person'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            for (final person in filtered)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AppCard(
                  onTap: () => context.push('/people/${person.id}'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          AppAvatar(label: person.initial, size: 32),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(person.name, style: AppTextStyles.labelSemibold),
                                const SizedBox(height: 2),
                                StatusBadge.neutral(person.isOwner ? 'Owner' : 'Contributor'),
                              ],
                            ),
                          ),
                          StatusBadge.positive('Active'),
                        ],
                      ),
                      const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(height: 1)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _Stat(
                            label: 'Contributed',
                            value: period != null
                                ? AppFormatters.currency(
                                    appData.contributionsByPerson(period.id)[person] ?? 0,
                                  )
                                : '৳0',
                          ),
                          _Stat(
                            label: 'Purchases',
                            value: period != null
                                ? '${appData.purchasesInPeriod(period.id).where((t) => t.personId == person.id).length} times'
                                : '0 times',
                          ),
                          const _Stat(label: 'Owed/Owes', value: '-'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ] else
            for (final person in filtered)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AppCard(
                  onTap: () => context.push('/people/${person.id}/contributions'),
                  child: Row(
                    children: [
                      AppAvatar(label: person.initial, size: 32),
                      const SizedBox(width: 10),
                      Expanded(child: Text(person.name, style: AppTextStyles.labelSemibold)),
                      Text(
                        period != null
                            ? AppFormatters.currency(appData.contributionsByPerson(period.id)[person] ?? 0)
                            : '৳0',
                        style: AppTextStyles.labelSemibold,
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

class _SegButton extends StatelessWidget {
  const _SegButton({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: (selected ? AppTextStyles.labelSemibold : AppTextStyles.labelMedium).copyWith(
            color: selected ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
        Text(value, style: AppTextStyles.labelSemibold),
      ],
    );
  }
}
