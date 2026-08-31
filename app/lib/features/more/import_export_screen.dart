import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/cards.dart';
import '../../core/widgets/top_bar.dart';
import '../../data/models/models.dart';
import '../../data/providers/app_data.dart';

/// 15 More / Import & Export
class ImportExportScreen extends ConsumerWidget {
  const ImportExportScreen({super.key});

  String _csvField(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  void _exportCsv(WidgetRef ref) {
    final appData = ref.read(appDataProvider);
    final rows = <String>['Date,Type,Title,Category,Person,Amount,Unit,Quantity,Note'];
    final sorted = appData.transactions.values.toList()..sort((a, b) => b.date.compareTo(a.date));
    for (final t in sorted) {
      final category = appData.categories[t.categoryId]?.name ?? '';
      final person = appData.people[t.personId]?.name ?? '';
      rows.add([
        DateFormat('yyyy-MM-dd').format(t.date),
        t.type == TransactionType.purchase ? 'Purchase' : 'Contribution',
        _csvField(t.title),
        _csvField(category),
        _csvField(person),
        t.amount.toString(),
        t.unit ?? '',
        t.quantity?.toString() ?? '',
        _csvField(t.note),
      ].join(','));
    }
    Share.share(rows.join('\n'), subject: 'Money Care transactions export');
  }

  void _comingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature needs a connected backend — coming in a future update.')),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: const SimpleTopBar(title: 'Import & export'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('EXPORT', style: AppTextStyles.captionSemibold.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _Row(
                  icon: Icons.table_chart_outlined,
                  title: 'Export to Excel',
                  subtitle: 'All transactions as .xlsx',
                  onTap: () => _comingSoon(context, 'Excel export'),
                ),
                _Row(
                  icon: Icons.description_outlined,
                  title: 'Export to CSV',
                  subtitle: 'Raw data for spreadsheets',
                  onTap: () => _exportCsv(ref),
                ),
                _Row(
                  icon: Icons.picture_as_pdf_outlined,
                  title: 'Export report as PDF',
                  subtitle: 'Formatted spending summary',
                  showDivider: false,
                  onTap: () => _comingSoon(context, 'PDF export'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('IMPORT', style: AppTextStyles.captionSemibold.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _Row(
                  icon: Icons.upload_file_outlined,
                  title: 'Import from file',
                  subtitle: 'CSV or Excel spreadsheet',
                  showDivider: false,
                  onTap: () => _comingSoon(context, 'File import'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('BACKUP', style: AppTextStyles.captionSemibold.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _Row(
                  icon: Icons.cloud_upload_outlined,
                  title: 'Backup now',
                  subtitle: 'Cloud backup not yet connected',
                  onTap: () => _comingSoon(context, 'Cloud backup'),
                ),
                _Row(
                  icon: Icons.restore_outlined,
                  title: 'Restore from backup',
                  subtitle: 'Load a previous snapshot',
                  showDivider: false,
                  onTap: () => _comingSoon(context, 'Restore'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.showDivider = true,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: showDivider
            ? BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.borderDefault)))
            : null,
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.actionPrimary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.bodySmallSemibold),
                  Text(subtitle, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
