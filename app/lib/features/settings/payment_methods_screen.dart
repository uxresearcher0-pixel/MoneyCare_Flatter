import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/cards.dart';
import '../../core/widgets/top_bar.dart';
import '../../data/providers/app_data.dart';

/// 12 Settings / Payment Methods
class PaymentMethodsScreen extends ConsumerWidget {
  const PaymentMethodsScreen({super.key});

  void _addMethod(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New payment method'),
        content: TextField(controller: controller, autofocus: true, decoration: const InputDecoration(hintText: 'e.g. Cheque')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref.read(appDataProvider).addPaymentMethod(controller.text.trim());
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appData = ref.watch(appDataProvider);
    final methods = appData.paymentMethods.values.toList();

    return Scaffold(
      appBar: SimpleTopBar(
        title: 'Payment methods',
        actions: [
          IconButton(
            icon: Icon(Icons.add_rounded, color: AppColors.actionPrimary),
            onPressed: () => _addMethod(context, ref),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: methods.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final m = methods[i];
          return AppCard(
            child: Row(
              children: [
                AppAvatar(icon: m.icon, size: 32),
                const SizedBox(width: 12),
                Expanded(child: Text(m.name, style: AppTextStyles.labelSemibold)),
                InkWell(
                  onTap: () => appData.deletePaymentMethod(m.id),
                  child: Icon(Icons.delete_outline_rounded, color: AppColors.textSecondary, size: 20),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
