import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../core/theme/ritma_spacing.dart';
import '../../../core/widgets/ritma_status_pill.dart';
import '../../../core/widgets/ritma_surface_badge.dart';
import '../application/auth_providers.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _submitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    setState(() {
      _submitting = true;
      _errorMessage = null;
    });

    final result = await ref
        .read(authControllerProvider.notifier)
        .signInWithEmail(
          email: _emailController.text,
          password: _passwordController.text,
        );

    if (!mounted) {
      return;
    }

    result.when(
      success: (_) {
        setState(() => _submitting = false);
      },
      failure: (failure) {
        setState(() {
          _submitting = false;
          _errorMessage = failure.message;
        });
      },
    );
  }

  void _fillDemoAccount(String email) {
    _emailController.text = email;
    _passwordController.text = 'RitmaDemo1!';
  }

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(appModeProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const RitmaSurfaceBadge(),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(RitmaSpacing.lg),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(RitmaSpacing.lg),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Wrap(
                                alignment: WrapAlignment.spaceBetween,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: RitmaSpacing.sm,
                                runSpacing: RitmaSpacing.xs,
                                children: [
                                  Text(
                                    'RITMA',
                                    style: theme.textTheme.headlineMedium,
                                  ),
                                  RitmaStatusPill(
                                    label: mode == AppMode.demoSandbox
                                        ? 'Demo Sandbox'
                                        : 'Member & Ops',
                                    tone: mode == AppMode.demoSandbox
                                        ? RitmaPillTone.warning
                                        : RitmaPillTone.lime,
                                  ),
                                ],
                              ),
                              const SizedBox(height: RitmaSpacing.xs),
                              Text(
                                'Sign in to access your gym, studio, or member pass.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: RitmaSpacing.lg),
                              if (_errorMessage != null) ...[
                                Container(
                                  padding: const EdgeInsets.all(
                                    RitmaSpacing.sm,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.error.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      RitmaRadius.md,
                                    ),
                                    border: Border.all(
                                      color: theme.colorScheme.error,
                                    ),
                                  ),
                                  child: Text(
                                    _errorMessage!,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.error,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: RitmaSpacing.md),
                              ],
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                autofillHints: const [AutofillHints.email],
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: Icon(Icons.mail_outline),
                                ),
                                validator: (value) {
                                  final v = value?.trim() ?? '';
                                  if (v.isEmpty || !v.contains('@')) {
                                    return 'Enter a valid email address.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: RitmaSpacing.md),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                autofillHints: const [AutofillHints.password],
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    tooltip: _obscurePassword
                                        ? 'Show password'
                                        : 'Hide password',
                                    onPressed: () => setState(
                                      () =>
                                          _obscurePassword = !_obscurePassword,
                                    ),
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if ((value ?? '').length < 6) {
                                    return 'Password must be at least 6 characters.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: RitmaSpacing.xs),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: _submitting
                                      ? null
                                      : () => context.push(
                                          AppRoutes.forgotPassword,
                                        ),
                                  child: const Text('Forgot password?'),
                                ),
                              ),
                              const SizedBox(height: RitmaSpacing.sm),
                              FilledButton(
                                onPressed: _submitting ? null : _submit,
                                child: _submitting
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text('Sign In'),
                              ),
                              const SizedBox(height: RitmaSpacing.sm),
                              OutlinedButton(
                                onPressed: _submitting
                                    ? null
                                    : () => context.push(AppRoutes.signUp),
                                child: const Text('Create Account'),
                              ),
                              if (mode == AppMode.demoSandbox) ...[
                                const SizedBox(height: RitmaSpacing.lg),
                                const Divider(),
                                const SizedBox(height: RitmaSpacing.sm),
                                Text(
                                  'Quick Demo Sandbox Accounts',
                                  style: theme.textTheme.labelMedium,
                                ),
                                const SizedBox(height: RitmaSpacing.xs),
                                Wrap(
                                  spacing: RitmaSpacing.xs,
                                  runSpacing: RitmaSpacing.xs,
                                  children: [
                                    ActionChip(
                                      label: const Text('Multi-Role Owner'),
                                      onPressed: () =>
                                          _fillDemoAccount('owner@ritma.demo'),
                                    ),
                                    ActionChip(
                                      label: const Text('Member Only'),
                                      onPressed: () =>
                                          _fillDemoAccount('member@ritma.demo'),
                                    ),
                                    ActionChip(
                                      label: const Text('Unassigned User'),
                                      onPressed: () =>
                                          _fillDemoAccount('new@ritma.demo'),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
