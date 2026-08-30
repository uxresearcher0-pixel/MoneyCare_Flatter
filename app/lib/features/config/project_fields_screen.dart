import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/cards.dart';
import '../../core/widgets/top_bar.dart';

class _FieldSpec {
  const _FieldSpec(this.name, this.type, this.detail);
  final String name;
  final String type;
  final String detail;
}

const _fields = [
  _FieldSpec('Grocery Fund', 'Wallet', 'Default payment source'),
  _FieldSpec('Monthly Budget Cap', 'Calculated Total', 'Sum of category budgets'),
  _FieldSpec('Receipt Required', 'Toggle', 'Off by default'),
  _FieldSpec('Preferred Unit', 'Dropdown', 'kg, L, pcs'),
];

/// 12 Configuration / Project Fields — Monthly Grocery
class ProjectFieldsScreen extends StatelessWidget {
  const ProjectFieldsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SimpleTopBar(
        title: 'Project fields',
        actions: [
          IconButton(
            icon: const Icon(Icons.dashboard_customize_outlined, color: AppColors.actionPrimary),
            onPressed: () => context.push('/config/field-templates'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Custom fields let you capture extra structured information for every purchase in this project.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          for (final field in _fields)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                onTap: () => context.push('/config/field-editor'),
                child: Row(
                  children: [
                    const AppAvatar(icon: Icons.view_list_rounded, size: 36, shape: BoxShape.rectangle),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(field.name, style: AppTextStyles.labelSemibold),
                          Text(field.detail, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    StatusBadge.neutral(field.type),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => context.push('/config/custom-field-builder'),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add custom field'),
            style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          ),
        ],
      ),
    );
  }
}
