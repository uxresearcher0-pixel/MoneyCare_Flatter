import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/empty_state.dart';
import '../../data/models/models.dart';
import '../../data/providers/app_data.dart';

/// 11 Activity / Transaction Activity — Default
class TransactionActivityScreen extends ConsumerStatefulWidget {
  const TransactionActivityScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  ConsumerState<TransactionActivityScreen> createState() => _TransactionActivityScreenState();
}

class _TransactionActivityScreenState extends ConsumerState<TransactionActivityScreen> {
  String _filter = 'All';
  final _search = TextEditingController();
  final _searchFocus = FocusNode();

  @override
  void dispose() {
    _search.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appData = ref.watch(appDataProvider);
    final period = appData.activePeriod;
    var items = period != null ? appData.transactionsInPeriod(period.id) : <AppTransaction>[];
    if (_filter == 'Purchases') {
      items = items.where((t) => t.type == TransactionType.purchase).toList();
    } else if (_filter == 'Contributions') {
      items = items.where((t) => t.type == TransactionType.contribution).toList();
    }
    final query = _search.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      items = items.where((t) => t.title.toLowerCase().contains(query)).toList();
    }

    final grouped = <String, List<AppTransaction>>{};
    for (final t in items) {
      final key = AppFormatters.relativeDay(t.date);
      grouped.putIfAbsent(key, () => []).add(t);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity'),
        titleTextStyle: AppTextStyles.h2,
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => _searchFocus.requestFocus(),
          ),
        ],
      ),
      body: (items.isEmpty && query.isEmpty)
          ? const EmptyState(
              icon: Icons.schedule_rounded,
              title: 'No activity yet',
              message: 'Purchases and contributions you log will show up here.',
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
              children: [
                TextField(
                  controller: _search,
                  focusNode: _searchFocus,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search transactions...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 18),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.borderDefault),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (items.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'No transactions match "$query"',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                Wrap(
                  spacing: 8,
                  children: ['All', 'Purchases', 'Contributions']
                      .map(
                        (f) => ChoiceChip(
                          label: Text(f),
                          selected: _filter == f,
                          onSelected: (_) => setState(() => _filter = f),
                          showCheckmark: false,
                          selectedColor: AppColors.actionPrimary,
                          labelStyle: AppTextStyles.labelSemibold.copyWith(
                            color: _filter == f ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 8),
                Text(
                  'Showing ${_filter.toLowerCase()} transactions',
                  style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                for (final entry in grouped.entries) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(entry.key, style: AppTextStyles.labelBold.copyWith(color: AppColors.textSecondary)),
                  ),
                  for (final t in entry.value)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _TxRow(
                        transaction: t,
                        subtitle: t.type == TransactionType.purchase
                            ? '${appData.people[t.personId]?.name ?? ''} · ${appData.activeProject?.name ?? ''}'
                            : '${appData.people[t.personId]?.name ?? ''} · ${appData.activeProject?.name ?? ''}',
                        onTap: () => context.push('/transaction/${t.id}'),
                      ),
                    ),
                ],
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/purchase/add'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Record'),
      ),
    );
  }
}

class _TxRow extends StatelessWidget {
  const _TxRow({required this.transaction, required this.subtitle, this.onTap});

  final AppTransaction transaction;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isPurchase = transaction.type == TransactionType.purchase;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderDefault),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: const BoxDecoration(color: AppColors.background, shape: BoxShape.circle),
              child: Icon(
                isPurchase ? Icons.shopping_cart_rounded : Icons.account_balance_wallet_rounded,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(transaction.title, style: AppTextStyles.bodySmallBold, overflow: TextOverflow.ellipsis),
                  Text(subtitle, style: AppTextStyles.captionMedium.copyWith(color: AppColors.textSecondary), overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  AppFormatters.currency(isPurchase ? -transaction.amount : transaction.amount, showSign: true).replaceFirst('-', '- ').replaceFirst('+', '+ '),
                  style: AppTextStyles.bodyLargeSemibold.copyWith(
                    color: isPurchase ? AppColors.statusNegative : AppColors.statusPositive,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isPurchase ? const Color(0xFFFEE2E2) : const Color(0xFFD1FAE5),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    isPurchase ? 'Purchase' : 'Contribution',
                    style: AppTextStyles.captionBold.copyWith(
                      color: isPurchase ? AppColors.statusNegative : AppColors.statusPositive,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
