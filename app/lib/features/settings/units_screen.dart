import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/cards.dart';
import '../../core/widgets/top_bar.dart';

class _Unit {
  const _Unit(this.name, this.abbr);
  final String name;
  final String abbr;
}

const _units = [
  _Unit('Kilogram', 'kg'),
  _Unit('Litre', 'L'),
  _Unit('Piece', 'pcs'),
  _Unit('Gram', 'g'),
  _Unit('Dozen', 'dz'),
  _Unit('Pack', 'pack'),
];

/// 12 Settings / Units
class UnitsScreen extends StatelessWidget {
  const UnitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SimpleTopBar(
        title: 'Units',
        actions: [IconButton(icon: const Icon(Icons.add_rounded, color: AppColors.actionPrimary), onPressed: () {})],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _units.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final u = _units[i];
          return AppCard(
            child: Row(
              children: [
                AppAvatar(label: u.abbr, size: 32),
                const SizedBox(width: 12),
                Expanded(child: Text(u.name, style: AppTextStyles.labelSemibold)),
                Text(u.abbr, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          );
        },
      ),
    );
  }
}
