import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'buttons.dart';

/// The 5-slot sticky bottom navigation bar (Home / Workspaces / + / Activity / More)
/// matching the "sticky-bottom-nav" component from the Figma dashboard screens.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onAddTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onAddTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.borderDefault)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NavTab(
                icon: Icons.home_rounded,
                label: 'Home',
                selected: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavTab(
                icon: Icons.workspaces_rounded,
                label: 'Workspaces',
                selected: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              SizedBox(
                width: 60,
                child: Center(child: FabIconButton(icon: Icons.add_rounded, onPressed: onAddTap)),
              ),
              _NavTab(
                icon: Icons.schedule_rounded,
                label: 'Activity',
                selected: currentIndex == 2,
                onTap: () => onTap(2),
              ),
              _NavTab(
                icon: Icons.grid_view_rounded,
                label: 'More',
                selected: currentIndex == 3,
                onTap: () => onTap(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.actionPrimary : AppColors.textSecondary;
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              // Explicit height (rather than inheriting AppTextStyles.caption's
              // 1.4) keeps this label from overflowing the fixed-height nav
              // bar when the Inter font hasn't loaded yet and a taller
              // fallback font's metrics are used instead.
              style: (selected ? AppTextStyles.captionSemibold : AppTextStyles.caption)
                  .copyWith(color: color, height: 1.0),
            ),
          ],
        ),
      ),
    );
  }
}
