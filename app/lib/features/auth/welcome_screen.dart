import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/buttons.dart';
import 'widgets/money_care_logo.dart';

/// 01 Authentication / Welcome
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 32, 16, 24),
          child: Column(
            children: [
              const Spacer(),
              const MoneyCareLogo(size: 136),
              const SizedBox(height: 20),
              Text(
                'Take control of your money',
                style: AppTextStyles.h1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Track purchases, shared contributions, budgets and projects in one accessible place.',
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 2),
              PrimaryButton(
                label: 'Get started',
                radius: 8,
                onPressed: () => context.push('/sign-up'),
              ),
              const SizedBox(height: 12),
              SecondaryButton(
                label: 'I already have an account',
                radius: 8,
                onPressed: () => context.push('/sign-in'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
