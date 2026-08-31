import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/cards.dart';
import '../../core/widgets/top_bar.dart';
import '../../data/models/models.dart';
import '../../data/providers/app_data.dart';

class _TemplateField {
  const _TemplateField(this.name, this.type, this.detail);
  final String name;
  final String type;
  final String detail;
}

class _Template {
  const _Template(this.name, this.description, this.icon, this.fields);
  final String name;
  final String description;
  final IconData icon;
  final List<_TemplateField> fields;
}

const _templates = [
  _Template('Grocery Budget', 'Wallet, category caps, receipts', Icons.shopping_cart_rounded, [
    _TemplateField('Wallet', 'Wallet', 'Default payment source'),
    _TemplateField('Category cap', 'Number', 'Per-category spend limit'),
    _TemplateField('Receipt Required', 'Toggle', 'Off by default'),
    _TemplateField('Preferred Unit', 'Dropdown', 'kg, L, pcs'),
  ]),
  _Template('Shared Trip', 'Per-person split, currency, itinerary', Icons.flight_rounded, [
    _TemplateField('Per-person split', 'Toggle', 'Split evenly by default'),
    _TemplateField('Trip currency', 'Text', 'Currency used on this trip'),
    _TemplateField('Itinerary link', 'Text', 'Link to the shared itinerary'),
    _TemplateField('Trip dates', 'Date', 'Start and end of the trip'),
    _TemplateField('Trip budget', 'Number', 'Total planned spend'),
  ]),
  _Template('Household Bills', 'Due dates, recurring flag, payee', Icons.receipt_long_rounded, [
    _TemplateField('Due date', 'Date', 'When this bill is due'),
    _TemplateField('Recurring', 'Toggle', 'Repeats every period'),
    _TemplateField('Payee', 'Text', 'Who the bill is paid to'),
  ]),
  _Template('Savings Goal', 'Target amount, deadline, progress', Icons.savings_rounded, [
    _TemplateField('Target amount', 'Number', 'Goal to reach'),
    _TemplateField('Deadline', 'Date', 'Target completion date'),
    _TemplateField('Progress', 'Calculated Total', 'Saved so far'),
  ]),
];

/// 12 Configuration / Field Templates — Use Case Presets
class FieldTemplatesScreen extends ConsumerWidget {
  const FieldTemplatesScreen({super.key});

  void _apply(BuildContext context, WidgetRef ref, _Template t) {
    final appData = ref.read(appDataProvider);
    for (final f in t.fields) {
      appData.addCustomField(f.name, f.type, CustomFieldScope.project, detail: f.detail);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added ${t.fields.length} fields from "${t.name}" to Project fields')),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: const SimpleTopBar(title: 'Field templates'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Apply a preset bundle of custom fields tuned for common use cases.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          for (final t in _templates)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppCard(
                onTap: () => _apply(context, ref, t),
                child: Row(
                  children: [
                    AppAvatar(icon: t.icon, size: 44, shape: BoxShape.rectangle),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t.name, style: AppTextStyles.labelSemibold),
                          Text(t.description, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    StatusBadge.neutral('${t.fields.length} fields'),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
