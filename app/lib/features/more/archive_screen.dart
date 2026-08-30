import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/top_bar.dart';

/// 15 More / Archive
class ArchiveScreen extends StatelessWidget {
  const ArchiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const SimpleTopBar(title: 'Archive'),
      body: const EmptyState(
        icon: Icons.archive_outlined,
        title: 'Nothing archived yet',
        message: 'Completed projects and closed periods will show up here so your active workspace stays tidy.',
      ),
    );
  }
}
