import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/inputs.dart';
import '../../data/providers/app_data.dart';
import 'sign_in_screen.dart' show authErrorMessage;
import 'widgets/money_care_logo.dart';
import 'widgets/social_button.dart';

/// sign-up
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _agreed = false;
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.statusNegative),
    );
  }

  Future<void> _submit() async {
    final appData = ref.read(appDataProvider);
    if (!appData.isFirebaseBacked) {
      appData.signIn();
      if (mounted) context.go('/home');
      return;
    }
    if (_name.text.trim().isEmpty || _email.text.trim().isEmpty || _password.text.isEmpty) {
      _showError('Fill in your name, email and password.');
      return;
    }
    if (_password.text.length < 8) {
      _showError('Password must be at least 8 characters.');
      return;
    }
    if (_password.text != _confirmPassword.text) {
      _showError('Passwords do not match.');
      return;
    }
    if (!_agreed) {
      _showError('Please agree to the Terms of Service & Privacy Policy.');
      return;
    }
    setState(() => _loading = true);
    try {
      await appData.signUpWithEmail(
        name: _name.text,
        email: _email.text,
        password: _password.text,
      );
      if (mounted) context.go('/home');
    } on fb_auth.FirebaseAuthException catch (e) {
      _showError(authErrorMessage(e));
    } catch (_) {
      _showError('Something went wrong. Check your connection and try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appData = ref.watch(appDataProvider);
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
                LabeledField(label: 'Full Name', hint: 'John Doe', controller: _name),
                const SizedBox(height: 12),
                LabeledField(
                  label: 'Email',
                  hint: 'name@example.com',
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                LabeledField(
                  label: 'Create Password',
                  hint: 'At least 8 characters',
                  controller: _password,
                  obscureText: true,
                ),
                const SizedBox(height: 12),
                LabeledField(
                  label: 'Confirm Password',
                  hint: 'Repeat your password',
                  controller: _confirmPassword,
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
                      child: GestureDetector(
                        onTap: () => setState(() => _agreed = !_agreed),
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
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  label: 'Create account',
                  isLoading: _loading,
                  onPressed: _loading ? null : _submit,
                ),
                if (appData.isFirebaseBacked) ...[
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
                    onPressed: () => _showError("Google sign-in isn't set up yet — use email and password."),
                  ),
                ],
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
