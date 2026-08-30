import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// "Continue with Google" pill button used on sign-in / sign-up.
class SocialButton extends StatelessWidget {
  const SocialButton({super.key, required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.borderDefault),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          foregroundColor: AppColors.textPrimary,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'G',
              style: AppTextStyles.bodySmallBold.copyWith(color: const Color(0xFF4285F4)),
            ),
            const SizedBox(width: 12),
            Text(label, style: AppTextStyles.bodyMediumSemibold),
          ],
        ),
      ),
    );
  }
}
