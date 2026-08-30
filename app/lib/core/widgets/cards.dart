import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// White bordered card matching the Figma card surfaces used throughout
/// dashboards, lists, and detail screens.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.color = AppColors.surface,
    this.margin,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color color;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderDefault),
        boxShadow: const [
          BoxShadow(color: Color(0x05000000), blurRadius: 2, offset: Offset(0, 2)),
        ],
      ),
      child: onTap != null
          ? Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: onTap,
                child: Padding(padding: padding, child: child),
              ),
            )
          : Padding(padding: padding, child: child),
    );
    return card;
  }
}

/// A colored circular badge/avatar used for people, categories, folders.
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    this.label,
    this.icon,
    this.size = 36,
    this.background = AppColors.actionSelected,
    this.foreground = AppColors.actionPrimary,
    this.shape = BoxShape.circle,
  });

  final String? label;
  final IconData? icon;
  final double size;
  final Color background;
  final Color foreground;
  final BoxShape shape;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        shape: shape,
        borderRadius: shape == BoxShape.rectangle ? BorderRadius.circular(size * 0.2) : null,
      ),
      child: icon != null
          ? Icon(icon, size: size * 0.5, color: foreground)
          : Text(
              label ?? '',
              style: AppTextStyles.bodySmallBold.copyWith(
                color: foreground,
                fontSize: size * 0.38,
              ),
            ),
    );
  }
}

/// Rounded status/filter pill (e.g. "On track", "August", category chips).
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    this.background = AppColors.surfaceSubtle,
    this.foreground = AppColors.statusPositive,
    this.pill = true,
    this.dense = false,
  });

  final String label;
  final Color background;
  final Color foreground;
  final bool pill;
  final bool dense;

  factory StatusBadge.positive(String label) => StatusBadge(label: label);
  factory StatusBadge.negative(String label) => StatusBadge(
        label: label,
        background: AppColors.statusNegativeBg,
        foreground: AppColors.statusNegative,
      );
  factory StatusBadge.warning(String label) => StatusBadge(
        label: label,
        background: AppColors.statusWarningBg,
        foreground: AppColors.statusWarning,
      );
  factory StatusBadge.neutral(String label) => StatusBadge(
        label: label,
        background: AppColors.actionSelected,
        foreground: AppColors.actionPrimary,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: dense ? 6 : 8, vertical: dense ? 2 : 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(pill ? 100 : 4),
      ),
      child: Text(
        label,
        style: (dense ? AppTextStyles.captionSemibold : AppTextStyles.captionBold)
            .copyWith(color: foreground),
      ),
    );
  }
}

/// Linear progress bar used for budgets and category breakdowns.
class AppProgressBar extends StatelessWidget {
  const AppProgressBar({
    super.key,
    required this.value,
    this.height = 6,
    this.color = AppColors.actionPrimary,
    this.trackColor = AppColors.borderDefault,
  });

  final double value; // 0..1
  final double height;
  final Color color;
  final Color trackColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: LinearProgressIndicator(
        value: value.clamp(0, 1),
        minHeight: height,
        backgroundColor: trackColor,
        valueColor: AlwaysStoppedAnimation(color),
      ),
    );
  }
}

/// Section title row with an optional trailing action, used at the top of
/// most dashboard/list cards ("Spending overview", "Recent activity" ...).
class SectionHeaderRow extends StatelessWidget {
  const SectionHeaderRow({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.bodyMediumSemibold),
        ?trailing,
      ],
    );
  }
}
