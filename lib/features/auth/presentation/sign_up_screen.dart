import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../core/theme/ritma_spacing.dart';
import '../../../core/theme/ritma_status_colors.dart';
import '../../../core/widgets/ritma_surface_badge.dart';
import '../application/auth_providers.dart';
import '../domain/auth_session_state.dart';

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
  String? _statusMessage;
  bool _isConfirmationNotice = false;

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
      _statusMessage = null;
      _isConfirmationNotice = false;
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
        final session = ref.read(authControllerProvider).asData?.value;
        if (session is AuthenticatedSession &&
            GoRouterState.of(context).uri.path.startsWith('/auth')) {
          final workspace = ref.read(activeWorkspaceProvider);
          final target = workspace != null
              ? AppRoutes.defaultRouteForWorkspace(workspace)
              : AppRoutes.workspaces;
          context.go(target);
        }
      },
      failure: (failure) {
        final lower = failure.message.toLowerCase();
        final isConfirmNotice =
            lower.contains('confirmation email') ||
            lower.contains('verify your email');
        setState(() {
          _submitting = false;
          _statusMessage = failure.message;
          _isConfirmationNotice = isConfirmNotice;
        });
      },
    );
  }

  void _backToSignIn() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.signIn);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColors = context.statusColors;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back to Sign In',
          onPressed: _backToSignIn,
        ),
        title: const Text('Create Account'),
      ),
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
                              if (_statusMessage != null) ...[
                                Container(
                                  padding: const EdgeInsets.all(
                                    RitmaSpacing.sm,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _isConfirmationNotice
                                        ? statusColors.infoBg
                                        : theme.colorScheme.error.withValues(
                                            alpha: 0.1,
                                          ),
                                    borderRadius: BorderRadius.circular(
                                      RitmaRadius.md,
                                    ),
                                    border: Border.all(
                                      color: _isConfirmationNotice
                                          ? statusColors.infoFg
                                          : theme.colorScheme.error,
                                    ),
                                  ),
                                  child: Text(
                                    _statusMessage!,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: _isConfirmationNotice
                                          ? statusColors.infoFg
                                          : theme.colorScheme.error,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: RitmaSpacing.md),
                              ],
                              TextFormField(
                                controller: _nameController,
                                textInputAction: TextInputAction.next,
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
                                textInputAction: TextInputAction.next,
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
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) {
                                  if (!_submitting) {
                                    _submit();
                                  }
                                },
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
                                onPressed: _submitting ? null : _backToSignIn,
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
