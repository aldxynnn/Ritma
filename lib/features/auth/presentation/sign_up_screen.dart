import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/ritma_spacing.dart';
import '../../../core/widgets/ritma_surface_badge.dart';
import '../application/auth_providers.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _submitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
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
        .signUpWithEmail(
          email: _emailController.text,
          password: _passwordController.text,
          fullName: _nameController.text,
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
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
                              Text(
                                'Join RITMA',
                                style: theme.textTheme.headlineSmall,
                              ),
                              const SizedBox(height: RitmaSpacing.xs),
                              Text(
                                'Create your identity to manage fitness clubs or claim your member pass.',
                                style: theme.textTheme.bodySmall,
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
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  labelText: 'Full Name',
                                  prefixIcon: Icon(Icons.person_outline),
                                ),
                                validator: (v) => (v?.trim().length ?? 0) < 2
                                    ? 'Enter your full name.'
                                    : null,
                              ),
                              const SizedBox(height: RitmaSpacing.md),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: Icon(Icons.mail_outline),
                                ),
                                validator: (v) {
                                  final val = v?.trim() ?? '';
                                  return val.isEmpty || !val.contains('@')
                                      ? 'Enter a valid email.'
                                      : null;
                                },
                              ),
                              const SizedBox(height: RitmaSpacing.md),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  labelText: 'Password (min 6 chars)',
                                  prefixIcon: Icon(Icons.lock_outline),
                                ),
                                validator: (v) => (v?.length ?? 0) < 6
                                    ? 'Minimum 6 characters required.'
                                    : null,
                              ),
                              const SizedBox(height: RitmaSpacing.lg),
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
                                    : const Text('Create Account'),
                              ),
                              const SizedBox(height: RitmaSpacing.xs),
                              TextButton(
                                onPressed: _submitting
                                    ? null
                                    : () => context.pop(),
                                child: const Text('Back to Sign In'),
                              ),
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
