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

/// sign-up
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  bool _agreed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 34),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 12),
                const MoneyCareLogo(size: 90, showWordmark: false),
                const SizedBox(height: 16),
                Text(
                  'Create your account',
                  style: AppTextStyles.h1.copyWith(fontSize: 26),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Start managing your money today',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                const LabeledField(label: 'Full Name', hint: 'John Doe'),
                const SizedBox(height: 12),
                const LabeledField(label: 'Email', hint: 'name@example.com'),
                const SizedBox(height: 12),
                const LabeledField(
                  label: 'Create Password',
                  hint: 'At least 8 characters',
                  obscureText: true,
                ),
                const SizedBox(height: 12),
                const LabeledField(
                  label: 'Confirm Password',
                  hint: 'Repeat your password',
                  obscureText: true,
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: Checkbox(
                        value: _agreed,
                        onChanged: (v) => setState(() => _agreed = v ?? false),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        side: BorderSide(color: AppColors.borderDefault, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: AppTextStyles.label.copyWith(color: AppColors.textSecondary, height: 1.4),
                          children: [
                            const TextSpan(text: 'I agree to the '),
                            TextSpan(
                              text: 'Terms of Service',
                              style: AppTextStyles.labelSemibold.copyWith(color: AppColors.actionPrimary),
                            ),
                            const TextSpan(text: ' & '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: AppTextStyles.labelSemibold.copyWith(color: AppColors.actionPrimary),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  label: 'Create account',
                  onPressed: () {
                    ref.read(appDataProvider).signIn();
                    context.go('/home');
                  },
                ),
                const SizedBox(height: 10),
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
                const SizedBox(height: 10),
                SocialButton(
                  label: 'Continue with Google',
                  onPressed: () {
                    ref.read(appDataProvider).signIn();
                    context.go('/home');
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                    LinkButton(label: 'Sign in', onPressed: () => context.pushReplacement('/sign-in')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
