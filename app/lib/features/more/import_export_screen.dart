import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/cards.dart';
import '../../core/widgets/top_bar.dart';

/// 15 More / Import & Export
class ImportExportScreen extends StatelessWidget {
  const ImportExportScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                _Row(icon: Icons.table_chart_outlined, title: 'Export to Excel', subtitle: 'All transactions as .xlsx'),
                _Row(icon: Icons.description_outlined, title: 'Export to CSV', subtitle: 'Raw data for spreadsheets'),
                _Row(icon: Icons.picture_as_pdf_outlined, title: 'Export report as PDF', subtitle: 'Formatted spending summary', showDivider: false),
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
                _Row(icon: Icons.upload_file_outlined, title: 'Import from file', subtitle: 'CSV or Excel spreadsheet', showDivider: false),
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
                _Row(icon: Icons.cloud_upload_outlined, title: 'Backup now', subtitle: 'Last backup: Today, 8:02 AM'),
                _Row(icon: Icons.restore_outlined, title: 'Restore from backup', subtitle: 'Load a previous snapshot', showDivider: false),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.icon, required this.title, required this.subtitle, this.showDivider = true});

  final IconData icon;
  final String title;
  final String subtitle;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: showDivider
            ? const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.borderDefault)))
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
            const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
