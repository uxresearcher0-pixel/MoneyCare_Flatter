import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/bottom_nav.dart';
import '../activity/transaction_activity_screen.dart';
import '../more/more_hub_screen.dart';
import '../workspaces/workspace_list_screen.dart';
import 'dashboard_screen.dart';

/// Hosts the 4 bottom-nav tabs (Home / Workspaces / Activity / More) and the
/// central "+" quick-add sheet, matching the "sticky-bottom-nav" pattern.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _tabs = [
    DashboardScreen(),
    WorkspaceListScreen(embedded: true),
    TransactionActivityScreen(embedded: true),
    MoreHubScreen(embedded: true),
  ];

  void _openQuickAdd() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _QuickAddSheet(
        onSelect: (route) {
          Navigator.of(context).pop();
          context.push(route);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        onAddTap: _openQuickAdd,
      ),
    );
  }
}

class _QuickAddSheet extends StatelessWidget {
  const _QuickAddSheet({required this.onSelect});

  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quick add', style: AppTextStyles.h3),
            const SizedBox(height: 16),
            _QuickAddTile(
              icon: Icons.add_shopping_cart_rounded,
              label: 'Add Purchase',
              onTap: () => onSelect('/purchase/add'),
            ),
            _QuickAddTile(
              icon: Icons.arrow_downward_rounded,
              label: 'Add Contribution',
              onTap: () => onSelect('/contribution/add'),
            ),
            _QuickAddTile(
              icon: Icons.photo_camera_rounded,
              label: 'Scan Receipt',
              onTap: () => onSelect('/scan-receipt'),
            ),
            _QuickAddTile(
              icon: Icons.checklist_rtl_rounded,
              label: 'Bulk Purchase Entry',
              onTap: () => onSelect('/purchase/bulk'),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAddTile extends StatelessWidget {
  const _QuickAddTile({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(color: AppColors.actionSelected, shape: BoxShape.circle),
        child: Icon(icon, color: AppColors.actionPrimary, size: 20),
      ),
      title: Text(label, style: AppTextStyles.bodyMediumSemibold),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }
}
