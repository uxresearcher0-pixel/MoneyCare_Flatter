import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/cards.dart';
import '../../core/widgets/top_bar.dart';

class _PaymentMethod {
  const _PaymentMethod(this.name, this.icon);
  final String name;
  final IconData icon;
}

/// 12 Settings / Payment Methods
class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final List<_PaymentMethod> _methods = [
    const _PaymentMethod('Cash', Icons.payments_outlined),
    const _PaymentMethod('Bank transfer', Icons.account_balance_outlined),
    const _PaymentMethod('Mobile banking (bKash/Nagad)', Icons.smartphone_outlined),
    const _PaymentMethod('Card', Icons.credit_card_outlined),
  ];

  void _addMethod() {
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
                setState(() => _methods.add(_PaymentMethod(controller.text.trim(), Icons.payments_outlined)));
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SimpleTopBar(
        title: 'Payment methods',
        actions: [IconButton(icon: const Icon(Icons.add_rounded, color: AppColors.actionPrimary), onPressed: _addMethod)],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _methods.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final m = _methods[i];
          return AppCard(
            child: Row(
              children: [
                AppAvatar(icon: m.icon, size: 32),
                const SizedBox(width: 12),
                Expanded(child: Text(m.name, style: AppTextStyles.labelSemibold)),
                InkWell(
                  onTap: () => setState(() => _methods.removeAt(i)),
                  child: const Icon(Icons.delete_outline_rounded, color: AppColors.textSecondary, size: 20),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
