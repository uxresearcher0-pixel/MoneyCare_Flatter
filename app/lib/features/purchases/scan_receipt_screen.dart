import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/cards.dart';
import '../../data/providers/app_data.dart';

class _DetectedItem {
  _DetectedItem(this.name, this.qty, this.unit, this.amount);
  final String name;
  final num qty;
  final String unit;
  final num amount;
}

final _detected = [
  _DetectedItem('Chicken', 3.3, 'kg', 924),
  _DetectedItem('Rice', 5, 'kg', 90),
  _DetectedItem('Oil', 2, 'kg', 420),
];

/// scan-receipt
class ScanReceiptScreen extends ConsumerStatefulWidget {
  const ScanReceiptScreen({super.key});

  @override
  ConsumerState<ScanReceiptScreen> createState() => _ScanReceiptScreenState();
}

class _ScanReceiptScreenState extends ConsumerState<ScanReceiptScreen> {
  late List<_DetectedItem> _items = List.of(_detected);

  void _addToBulk() {
    final appData = ref.read(appDataProvider);
    final period = appData.activePeriod;
    if (period == null) return;
    final defaultCategory = appData.categories.keys.first;
    for (final item in _items) {
      appData.addPurchase(
        periodId: period.id,
        title: item.name,
        amount: item.amount,
        categoryId: defaultCategory,
        quantity: item.qty,
        unit: item.unit,
      );
    }
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
        title: const Text('Scan Receipt'),
        titleTextStyle: AppTextStyles.h3,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.surfaceSubtle,
              child: const Icon(Icons.flash_on_rounded, size: 16, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.receipt_long_rounded, color: AppColors.textSecondary),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('IMG08302026ABC1.jpeg', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary)),
                        SizedBox(height: 2),
                        Text('3024×4032 · 4.2 MB', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderDefault),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(color: AppColors.actionPrimary, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.receipt_long_outlined, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 6),
                        Text('Last scan · 2 mins ago', style: AppTextStyles.captionSemibold.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Enable Scan Result is on',
                            style: AppTextStyles.captionMedium.copyWith(color: AppColors.textSecondary),
                          ),
                        ),
                        StatusBadge.neutral('${_items.length} items detected'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: ListView.separated(
                        itemCount: _items.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final item = _items[i];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item.name, style: AppTextStyles.bodySmallSemibold),
                                      Row(
                                        children: [
                                          Text(
                                            '${item.qty} ${item.unit}',
                                            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                                          ),
                                          const SizedBox(width: 6),
                                          Text('৳${item.amount}', style: AppTextStyles.captionSemibold),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    border: Border.all(color: AppColors.borderDefault),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text('Edit', style: AppTextStyles.captionSemibold.copyWith(color: AppColors.textSecondary)),
                                ),
                                const SizedBox(width: 10),
                                InkWell(
                                  onTap: () => setState(() => _items.removeAt(i)),
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: const BoxDecoration(color: Color(0xFFFCEBEB), shape: BoxShape.circle),
                                    child: const Icon(Icons.close_rounded, size: 14, color: AppColors.statusNegative),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => setState(() => _items = List.of(_detected)),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: AppColors.background,
                              side: BorderSide.none,
                              foregroundColor: AppColors.textSecondary,
                            ),
                            child: const Text('Rescan'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => context.pushReplacement('/purchase/add'),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: AppColors.background,
                              side: BorderSide.none,
                              foregroundColor: AppColors.textSecondary,
                            ),
                            child: const Text('Custom Add'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _items.isEmpty ? null : _addToBulk,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add to bulk purchase'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
