import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
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
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final appData = ref.read(appDataProvider);
    if (!appData.isFirebaseBacked) {
      appData.signIn();
      if (mounted) context.go('/home');
      return;
    }
    if (_email.text.trim().isEmpty || _password.text.isEmpty) {
      _showError('Enter your email and password.');
      return;
    }
    setState(() => _loading = true);
    try {
      await appData.signInWithEmail(email: _email.text, password: _password.text);
      if (mounted) context.go('/home');
    } on fb_auth.FirebaseAuthException catch (e) {
      _showError(authErrorMessage(e));
    } catch (_) {
      _showError('Something went wrong. Check your connection and try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.statusNegative),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appData = ref.watch(appDataProvider);
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
                  LabeledField(
                    label: 'Email Address',
                    hint: 'name@example.com',
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  LabeledField(
                    label: 'Password',
                    hint: 'Enter your password',
                    controller: _password,
                    obscureText: true,
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: LinkButton(
                      label: 'Forgot password?',
                      onPressed: () => _showForgotPasswordDialog(context, appData),
                    ),
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    label: 'Sign in',
                    isLoading: _loading,
                    onPressed: _loading ? null : _submit,
                  ),
                  if (appData.isFirebaseBacked) ...[
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
                      onPressed: () => _showError("Google sign-in isn't set up yet — use email and password."),
                    ),
                  ],
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

String authErrorMessage(fb_auth.FirebaseAuthException e) {
  switch (e.code) {
    case 'user-not-found':
    case 'wrong-password':
    case 'invalid-credential':
      return 'Email or password is incorrect.';
    case 'invalid-email':
      return 'That email address looks invalid.';
    case 'user-disabled':
      return 'This account has been disabled.';
    case 'too-many-requests':
      return 'Too many attempts — try again in a moment.';
    case 'network-request-failed':
      return 'No internet connection.';
    default:
      return e.message ?? 'Sign-in failed.';
  }
}

void _showForgotPasswordDialog(BuildContext context, AppData appData) {
  final controller = TextEditingController();
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Reset password'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("We'll send a reset link to your email."),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(hintText: 'name@example.com'),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(
          onPressed: () async {
            final email = controller.text.trim();
            if (email.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Enter an email address first')),
              );
              return;
            }
            Navigator.pop(context);
            if (!appData.isFirebaseBacked) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Reset link sent to $email')),
              );
              return;
            }
            try {
              await appData.sendPasswordReset(email);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Reset link sent to $email')),
                );
              }
            } on fb_auth.FirebaseAuthException catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(authErrorMessage(e)), backgroundColor: AppColors.statusNegative),
                );
              }
            }
          },
          child: const Text('Send link'),
        ),
      ],
    ),
  );
}
