import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Pill-shaped primary CTA button matching the Figma "Button / Primary" component.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.radius = 999,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final double radius;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: AppColors.textInverse),
                const SizedBox(width: 8),
              ],
              Text(label, style: AppTextStyles.bodyLargeSemibold.copyWith(color: AppColors.textInverse)),
            ],
          );

    final button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      ),
      child: child,
    );

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// Outlined secondary button matching the Figma "Button / Secondary" component.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.radius = 999,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double radius;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final button = OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: AppColors.actionPrimary),
            const SizedBox(width: 8),
          ],
          Text(label, style: AppTextStyles.bodyLargeSemibold.copyWith(color: AppColors.actionPrimary)),
        ],
      ),
    );
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// Small text-only link button (e.g. "View all", "Add contribution").
class LinkButton extends StatelessWidget {
  const LinkButton({
    super.key,
    required this.label,
    this.onPressed,
    this.color,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Text(label, style: AppTextStyles.labelSemibold.copyWith(color: color ?? AppColors.actionPrimary)),
    );
  }
}

/// Circular floating-style icon button used for the bottom-nav "+" action.
class FabIconButton extends StatelessWidget {
  const FabIconButton({super.key, required this.icon, this.onPressed, this.size = 50});

  final IconData icon;
  final VoidCallback? onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.actionPrimary,
      shape: const CircleBorder(),
      elevation: 4,
      shadowColor: AppColors.actionPrimary.withValues(alpha: 0.35),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, color: AppColors.textInverse, size: size * 0.44),
        ),
      ),
    );
  }
}
