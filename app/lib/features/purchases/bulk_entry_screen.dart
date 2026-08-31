import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../data/providers/app_data.dart';

class _BulkRow {
  _BulkRow({required this.name, required this.qty, required this.unit, required this.price});
  String name;
  num qty;
  String unit;
  num price;
  String? categoryId;
  num get total => qty * price;
}

/// 10 Bulk Purchase / Bulk Entry — Empty Starter / Populated
class BulkEntryScreen extends ConsumerStatefulWidget {
  const BulkEntryScreen({super.key});

  @override
  ConsumerState<BulkEntryScreen> createState() => _BulkEntryScreenState();
}

class _BulkEntryScreenState extends ConsumerState<BulkEntryScreen> {
  final List<_BulkRow> _rows = [];

  void _addRow([String name = '']) {
    setState(() => _rows.add(_BulkRow(name: name, qty: 1, unit: 'kg', price: 0)));
  }

  void _save() {
    final appData = ref.read(appDataProvider);
    final period = appData.activePeriod;
    if (period == null || _rows.isEmpty) return;
    final defaultCategory = appData.categories.keys.first;
    for (final row in _rows) {
      if (row.name.trim().isEmpty) continue;
      appData.addPurchase(
        periodId: period.id,
        title: row.name.trim(),
        amount: row.total,
        categoryId: row.categoryId ?? defaultCategory,
        quantity: row.qty,
        unit: row.unit,
      );
    }
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final appData = ref.watch(appDataProvider);
    final project = appData.activeProject;
    final period = appData.activePeriod;
    final total = _rows.fold<num>(0, (s, r) => s + r.total);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
        title: const Text('Bulk purchase'),
        titleTextStyle: AppTextStyles.h3,
        actions: [
          TextButton.icon(
            onPressed: () => context.pushReplacement('/scan-receipt'),
            icon: const Icon(Icons.document_scanner_outlined, size: 18),
            label: const Text('Scan'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              children: [
                Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(color: AppColors.surfaceSubtle, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      Icon(Icons.auto_awesome_rounded, size: 19, color: AppColors.actionPrimary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${project?.name ?? 'Project'} · Today', style: AppTextStyles.bodySmallSemibold),
                            Text(
                              period?.label ?? '',
                              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.tune_rounded, size: 19, color: AppColors.actionPrimary),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text('Quick add', style: AppTextStyles.captionMedium.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        children: ['Rice', 'Oil', 'Eggs']
                            .map(
                              (item) => InkWell(
                                borderRadius: BorderRadius.circular(15),
                                onTap: () => _addRow(item),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceSubtle,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.add_rounded, size: 15, color: AppColors.actionPrimary),
                                      Text(item, style: AppTextStyles.captionSemibold.copyWith(color: AppColors.actionPrimary)),
                                    ],
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                for (var i = 0; i < _rows.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _BulkRowCard(
                      index: i + 1,
                      row: _rows[i],
                      onChanged: () => setState(() {}),
                      onRemove: () => setState(() => _rows.removeAt(i)),
                    ),
                  ),
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _addRow(),
                  child: Container(
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.actionPrimary),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_rounded, size: 20, color: AppColors.actionPrimary),
                        const SizedBox(width: 7),
                        Text('Add another item', style: AppTextStyles.bodySmallSemibold.copyWith(color: AppColors.actionPrimary)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _BulkTool(icon: Icons.content_copy_rounded, label: 'Duplicate last', onTap: _rows.isEmpty ? null : () => _addRow(_rows.last.name)),
                    const SizedBox(width: 14),
                    const _BulkTool(icon: Icons.mic_rounded, label: 'Voice entry'),
                    const SizedBox(width: 14),
                    _BulkTool(icon: Icons.attach_file_rounded, label: 'Receipt', onTap: () => context.pushReplacement('/scan-receipt')),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 9, 16, 9),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.borderDefault)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${_rows.length} items', style: AppTextStyles.captionMedium.copyWith(color: AppColors.textSecondary)),
                      Text('Total ${AppFormatters.currency(total)}', style: AppTextStyles.bodySmallSemibold),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _rows.isEmpty ? null : _save,
                      style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      icon: const Icon(Icons.check_rounded, size: 20),
                      label: Text('Save ${_rows.length} purchases'),
                    ),
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

class _BulkRowCard extends StatelessWidget {
  const _BulkRowCard({required this.index, required this.row, required this.onChanged, required this.onRemove});

  final int index;
  final _BulkRow row;
  final VoidCallback onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: AppColors.surfaceSubtle, shape: BoxShape.circle),
            child: Text('$index', style: AppTextStyles.captionSemibold.copyWith(color: AppColors.actionPrimary)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              initialValue: row.name,
              onChanged: (v) {
                row.name = v;
                onChanged();
              },
              style: AppTextStyles.bodyMediumSemibold,
              decoration: const InputDecoration(border: InputBorder.none, isDense: true, hintText: 'Item name'),
            ),
          ),
          SizedBox(
            width: 46,
            child: TextFormField(
              initialValue: row.qty.toString(),
              textAlign: TextAlign.end,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (v) {
                row.qty = num.tryParse(v) ?? row.qty;
                onChanged();
              },
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary),
              decoration: const InputDecoration(border: InputBorder.none, isDense: true, suffixText: 'kg'),
            ),
          ),
          const SizedBox(width: 8),
          Text(AppFormatters.currency(row.total), style: AppTextStyles.bodySmallBold),
          IconButton(
            icon: Icon(Icons.more_vert_rounded, size: 18, color: AppColors.textSecondary),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}

class _BulkTool extends StatelessWidget {
  const _BulkTool({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: AppColors.actionPrimary),
          const SizedBox(width: 5),
          Text(label, style: AppTextStyles.captionSemibold.copyWith(color: AppColors.actionPrimary)),
        ],
      ),
    );
  }
}
