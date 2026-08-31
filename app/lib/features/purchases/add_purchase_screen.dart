import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/models.dart';
import '../../data/providers/app_data.dart';

const _recentItems = ['Chicken', 'Rice', 'Fish', 'Oil', 'Vegetables'];

/// 09 Purchases / Add Purchase — Smart Defaults
class AddPurchaseScreen extends ConsumerStatefulWidget {
  const AddPurchaseScreen({super.key});

  @override
  ConsumerState<AddPurchaseScreen> createState() => _AddPurchaseScreenState();
}

class _AddPurchaseScreenState extends ConsumerState<AddPurchaseScreen> {
  final _item = TextEditingController(text: '');
  final _quantity = TextEditingController(text: '1');
  final _unitPrice = TextEditingController(text: '');
  String? _categoryId;
  String? _personId;
  String? _unitId;
  String _unitAbbr = 'kg';

  num get _total {
    final qty = num.tryParse(_quantity.text) ?? 0;
    final price = num.tryParse(_unitPrice.text) ?? 0;
    return qty * price;
  }

  void _save({bool addAnother = false}) {
    final appData = ref.read(appDataProvider);
    final period = appData.activePeriod;
    if (period == null || _item.text.trim().isEmpty || _categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add an item name and pick a category')),
      );
      return;
    }
    appData.addPurchase(
      periodId: period.id,
      title: _item.text.trim(),
      amount: _total,
      categoryId: _categoryId!,
      personId: _personId ?? appData.currentUser.id,
      quantity: num.tryParse(_quantity.text),
      unit: _unitAbbr,
    );
    if (addAnother) {
      setState(() {
        _item.clear();
        _unitPrice.clear();
        _quantity.text = '1';
      });
    } else {
      context.pop();
    }
  }

  Future<void> _pickUnit(BuildContext context, List<Unit> units) async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: units
              .map((u) => ListTile(
                    title: Text('${u.name} (${u.abbr})', style: AppTextStyles.bodyMedium),
                    trailing: u.id == _unitId ? Icon(Icons.check_rounded, color: AppColors.actionPrimary) : null,
                    onTap: () => Navigator.pop(context, u.id),
                  ))
              .toList(),
        ),
      ),
    );
    if (picked != null) setState(() => _unitId = picked);
  }

  @override
  Widget build(BuildContext context) {
    final appData = ref.watch(appDataProvider);
    final project = appData.activeProject;
    final period = appData.activePeriod;
    final categories = appData.categories.values.toList();
    _categoryId ??= categories.isNotEmpty ? categories.first.id : null;
    final people = project != null ? appData.peopleInProject(project.id) : appData.people.values.toList();
    _personId ??= people.isNotEmpty ? people.first.id : null;
    final units = appData.units.values.toList();
    _unitId ??= units.isNotEmpty ? units.first.id : null;
    _unitAbbr = units.firstWhere((u) => u.id == _unitId, orElse: () => const Unit(id: '', name: '', abbr: 'kg')).abbr;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
        title: const Text('Add purchase'),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.auto_awesome_rounded, size: 20, color: AppColors.actionPrimary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Ready for ${project?.name ?? 'project'}', style: AppTextStyles.bodySmallSemibold),
                                Text(
                                  'Today · ${period?.label ?? ''}',
                                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                                ),
                              ],
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
                      Text('What did you buy?', style: AppTextStyles.captionMedium.copyWith(color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.search_rounded, color: AppColors.textSecondary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _item,
                              style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w500),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                hintText: 'e.g. Chicken',
                              ),
                            ),
                          ),
                          Icon(Icons.mic_rounded, color: AppColors.actionPrimary),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _recentItems
                            .map(
                              (item) => InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () => setState(() => _item.text = item),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceSubtle,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(item, style: AppTextStyles.captionMedium.copyWith(color: AppColors.actionPrimary)),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _MiniField(
                        label: 'Quantity',
                        controller: _quantity,
                        suffix: _unitAbbr,
                        onSuffixTap: units.length <= 1
                            ? null
                            : () => _pickUnit(context, units),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _MiniField(
                        label: 'Unit price',
                        controller: _unitPrice,
                        prefix: '৳',
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FAF6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderDefault),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total price · calculated',
                        style: AppTextStyles.captionMedium.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        // Symbol and number in one bold string (same weight,
                        // same color) rather than two separately-styled Text
                        // widgets — matches how every other currency amount
                        // in the app renders and avoids the sign looking
                        // like a different, lighter glyph next to the total.
                        '৳${_total.round()}',
                        style: AppTextStyles.h1.copyWith(fontSize: 32),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_quantity.text} $_unitAbbr × ৳${_unitPrice.text.isEmpty ? '0' : _unitPrice.text} = ${AppFormatters.currency(_total)}',
                        style: AppTextStyles.caption.copyWith(color: AppColors.statusPositive),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.account_balance_wallet_rounded, size: 20, color: AppColors.actionPrimary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: _categoryId,
                                items: categories
                                    .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name, style: AppTextStyles.bodySmallBold)))
                                    .toList(),
                                onChanged: (v) => setState(() => _categoryId = v),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.person_outline_rounded, size: 20, color: AppColors.actionPrimary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: _personId,
                                items: people
                                    .map((p) => DropdownMenuItem(value: p.id, child: Text('Purchased by ${p.name}', style: AppTextStyles.bodySmallBold)))
                                    .toList(),
                                onChanged: (v) => setState(() => _personId = v),
                              ),
                            ),
                          ),
                        ],
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
                      Icon(Icons.playlist_add_rounded, color: AppColors.actionPrimary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Buying several items?', style: AppTextStyles.bodySmallSemibold),
                            Text(
                              'Reuse defaults for multiple rows.',
                              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.pushReplacement('/purchase/bulk'),
                        child: Icon(Icons.arrow_forward_rounded, color: AppColors.actionPrimary),
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
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.check_rounded, size: 20),
                      label: const Text('Save purchase'),
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

class _MiniField extends StatelessWidget {
  const _MiniField({
    required this.label,
    required this.controller,
    this.suffix,
    this.prefix,
    this.onChanged,
    this.onSuffixTap,
  });

  final String label;
  final TextEditingController controller;
  final String? suffix;
  final String? prefix;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSuffixTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.captionMedium.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            onChanged: onChanged,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: AppTextStyles.bodySmallBold,
            decoration: InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 6),
              prefixText: prefix == null ? null : '$prefix ',
              prefixStyle: AppTextStyles.bodySmallBold.copyWith(color: AppColors.textSecondary),
              // A gap-bearing widget rather than suffixText — suffixText hugs
              // the entered digits with no breathing room between them and
              // the box edge.
              suffixIcon: suffix == null
                  ? null
                  : InkWell(
                      onTap: onSuffixTap,
                      borderRadius: BorderRadius.circular(6),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 6, right: 2),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(suffix!, style: AppTextStyles.captionMedium.copyWith(color: AppColors.textSecondary)),
                            if (onSuffixTap != null) ...[
                              const SizedBox(width: 2),
                              Icon(Icons.expand_more_rounded, size: 16, color: AppColors.textSecondary),
                            ],
                          ],
                        ),
                      ),
                    ),
              suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            ),
          ),
        ],
      ),
    );
  }
}
