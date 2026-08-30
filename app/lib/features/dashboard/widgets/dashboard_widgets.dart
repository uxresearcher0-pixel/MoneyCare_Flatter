import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/cards.dart';
import '../../../data/models/models.dart';

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: SizedBox(
        height: 76,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.captionMedium.copyWith(color: AppColors.textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(icon, size: 16, color: AppColors.textSecondary),
              ],
            ),
            const Spacer(),
            Text(value, style: AppTextStyles.labelSemibold),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class QuickActionButton extends StatelessWidget {
  const QuickActionButton({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.primary = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: primary ? AppColors.actionPrimary : AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      onTap: onTap,
      child: SizedBox(
        height: 52,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: primary ? AppColors.textInverse : AppColors.textPrimary),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: AppTextStyles.tinySemibold.copyWith(
                color: primary ? AppColors.textInverse : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryProgressRow extends StatelessWidget {
  const CategoryProgressRow({
    super.key,
    required this.category,
    required this.amount,
    required this.percent,
  });

  final Category category;
  final num amount;
  final double percent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            AppAvatar(icon: category.icon, size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Text(category.name, style: AppTextStyles.labelMedium),
            ),
            Text(AppFormatters.currency(amount), style: AppTextStyles.labelSemibold),
            const SizedBox(width: 8),
            Text(
              '${(percent * 100).round()}%',
              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 6),
        AppProgressBar(value: percent),
      ],
    );
  }
}

class ContributorRow extends StatelessWidget {
  const ContributorRow({
    super.key,
    required this.person,
    required this.amount,
    required this.detail,
    this.showDivider = true,
  });

  final Person person;
  final num amount;
  final String detail;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      decoration: showDivider
          ? const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.borderDefault)),
            )
          : null,
      child: Row(
        children: [
          AppAvatar(label: person.initial, size: 32),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(person.name, style: AppTextStyles.labelMedium),
                Text(
                  detail,
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(AppFormatters.currency(amount), style: AppTextStyles.labelSemibold),
        ],
      ),
    );
  }
}

class ActivityRow extends StatelessWidget {
  const ActivityRow({
    super.key,
    required this.transaction,
    required this.subtitle,
    this.showDivider = true,
    this.onTap,
    this.onMore,
  });

  final AppTransaction transaction;
  final String subtitle;
  final bool showDivider;
  final VoidCallback? onTap;
  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context) {
    final isPurchase = transaction.type == TransactionType.purchase;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(bottom: 10),
        decoration: showDivider
            ? const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.borderDefault)),
              )
            : null,
        child: Row(
          children: [
            AppAvatar(
              icon: isPurchase ? Icons.shopping_cart_rounded : Icons.arrow_downward_rounded,
              size: 32,
              shape: BoxShape.rectangle,
              background: isPurchase ? AppColors.statusNegativeBg : AppColors.surfaceSubtle,
              foreground: isPurchase ? AppColors.statusNegative : AppColors.statusPositive,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(transaction.title, style: AppTextStyles.labelMedium),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Text(
              AppFormatters.currency(
                isPurchase ? -transaction.amount : transaction.amount,
                showSign: true,
              ),
              style: AppTextStyles.labelSemibold.copyWith(
                color: isPurchase ? AppColors.statusNegative : AppColors.statusPositive,
              ),
            ),
            const SizedBox(width: 12),
            InkWell(
              onTap: onMore,
              child: const Icon(Icons.more_vert_rounded, size: 16, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
