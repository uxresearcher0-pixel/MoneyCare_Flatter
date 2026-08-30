import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/inputs.dart';
import '../../data/providers/app_data.dart';
import 'widgets/money_care_logo.dart';
import 'widgets/social_button.dart';

/// sign-in
class SignInScreen extends ConsumerWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 34),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const MoneyCareLogo(size: 100),
                  const SizedBox(height: 20),
                  Text('Welcome back', style: AppTextStyles.h1, textAlign: TextAlign.center),
                  const SizedBox(height: 6),
                  Text(
                    'Sign in to your account',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 20),
                  const LabeledField(label: 'Email Address', hint: 'name@example.com'),
                  const SizedBox(height: 16),
                  const LabeledField(
                    label: 'Password',
                    hint: 'Enter your password',
                    obscureText: true,
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: LinkButton(label: 'Forgot password?', onPressed: () {}),
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    label: 'Sign in',
                    onPressed: () {
                      ref.read(appDataProvider).signIn();
                      context.go('/home');
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text('or', style: AppTextStyles.captionMedium),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SocialButton(
                    label: 'Continue with Google',
                    onPressed: () {
                      ref.read(appDataProvider).signIn();
                      context.go('/home');
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),
                      LinkButton(label: 'Sign up', onPressed: () => context.pushReplacement('/sign-up')),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
