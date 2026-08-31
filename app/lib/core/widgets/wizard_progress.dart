import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// The 5-segment step progress bar used across multi-step creation flows
/// ("Step 2 of 5" / "Details").
class WizardProgress extends StatelessWidget {
  const WizardProgress({
    super.key,
    required this.totalSteps,
    required this.currentStep,
    required this.stepLabel,
  });

  final int totalSteps;
  final int currentStep; // 1-based
  final String stepLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.borderDefault)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(totalSteps, (i) {
              final filled = i < currentStep;
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: i == totalSteps - 1 ? 0 : 8),
                  height: 4,
                  decoration: BoxDecoration(
                    color: filled ? AppColors.actionPrimary : AppColors.borderDefault,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step $currentStep of $totalSteps',
                style: AppTextStyles.captionSemibold.copyWith(color: AppColors.actionPrimary),
              ),
              Text(stepLabel, style: AppTextStyles.captionBold),
            ],
          ),
        ],
      ),
    );
  }
}

/// Sticky Back / Continue action bar pinned to the bottom of wizard screens.
class WizardActionBar extends StatelessWidget {
  const WizardActionBar({
    super.key,
    this.onBack,
    required this.onContinue,
    this.continueLabel = 'Continue',
    this.showBack = true,
  });

  final VoidCallback? onBack;
  final VoidCallback onContinue;
  final String continueLabel;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.borderDefault)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (showBack) ...[
              Expanded(
                child: OutlinedButton(
                  onPressed: onBack,
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Back', style: AppTextStyles.bodyMediumSemibold),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              flex: showBack ? 1 : 1,
              child: ElevatedButton(
                onPressed: onContinue,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(continueLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
