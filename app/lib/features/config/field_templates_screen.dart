import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/cards.dart';
import '../../core/widgets/top_bar.dart';

class _Template {
  const _Template(this.name, this.description, this.icon, this.fieldCount);
  final String name;
  final String description;
  final IconData icon;
  final int fieldCount;
}

const _templates = [
  _Template('Grocery Budget', 'Wallet, category caps, receipts', Icons.shopping_cart_rounded, 4),
  _Template('Shared Trip', 'Per-person split, currency, itinerary', Icons.flight_rounded, 5),
  _Template('Household Bills', 'Due dates, recurring flag, payee', Icons.receipt_long_rounded, 3),
  _Template('Savings Goal', 'Target amount, deadline, progress', Icons.savings_rounded, 3),
];

/// 12 Configuration / Field Templates — Use Case Presets
class FieldTemplatesScreen extends StatelessWidget {
  const FieldTemplatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SimpleTopBar(title: 'Field templates'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Apply a preset bundle of custom fields tuned for common use cases.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          for (final t in _templates)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppCard(
                onTap: () => context.pop(),
                child: Row(
                  children: [
                    AppAvatar(icon: t.icon, size: 44, shape: BoxShape.rectangle),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t.name, style: AppTextStyles.labelSemibold),
                          Text(t.description, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    StatusBadge.neutral('${t.fieldCount} fields'),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
