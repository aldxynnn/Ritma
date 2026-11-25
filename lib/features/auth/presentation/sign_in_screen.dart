import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../core/config/app_env_provider.dart';
import '../../../core/theme/ritma_spacing.dart';
import '../../../core/theme/theme_mode_provider.dart';
import '../../../core/widgets/ritma_status_pill.dart';
import '../../../core/widgets/ritma_surface_badge.dart';
import '../application/auth_providers.dart';
import '../domain/auth_session_state.dart';

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
        setState(() {
          _submitting = false;
          _errorMessage = failure.message;
        });
      },
    );
  }

  void _fillCredentials(String email, String password) {
    setState(() {
      _emailController.text = email;
      _passwordController.text = password;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final env = ref.watch(appEnvProvider);
    final mode = ref.watch(appModeProvider);
    final theme = Theme.of(context);
    final showShowcaseAccounts = !env.isProduction;

    final authCard = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 440),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(RitmaSpacing.md),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: RitmaSpacing.xs,
                  runSpacing: RitmaSpacing.xs,
                  children: [
                    Text('RITMA', style: theme.textTheme.headlineMedium),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RitmaStatusPill(
                          label: mode == AppMode.demoSandbox
                              ? 'Demo Sandbox'
                              : 'Member & Ops',
                          tone: mode == AppMode.demoSandbox
                              ? RitmaPillTone.warning
                              : RitmaPillTone.lime,
                        ),
                        const ThemeModeToggleButton(),
                      ],
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
                const SizedBox(height: RitmaSpacing.md),
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(RitmaSpacing.sm),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(RitmaRadius.md),
                      border: Border.all(color: theme.colorScheme.error),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                  const SizedBox(height: RitmaSpacing.sm),
                ],
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
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
                const SizedBox(height: RitmaSpacing.sm),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  onFieldSubmitted: (_) {
                    if (!_submitting) {
                      _submit();
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      tooltip: _obscurePassword
                          ? 'Show password'
                          : 'Hide password',
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
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
                        : () => context.go(AppRoutes.forgotPassword),
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
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Sign In'),
                ),
                const SizedBox(height: RitmaSpacing.sm),
                OutlinedButton(
                  onPressed: _submitting
                      ? null
                      : () => context.go(AppRoutes.signUp),
                  child: const Text('Create Account'),
                ),
                if (showShowcaseAccounts && mode == AppMode.demoSandbox) ...[
                  const SizedBox(height: RitmaSpacing.md),
                  const Divider(),
                  const SizedBox(height: RitmaSpacing.xs),
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
                            _fillCredentials('owner@ritma.demo', 'RitmaDemo1!'),
                      ),
                      ActionChip(
                        label: const Text('Member Only'),
                        onPressed: () => _fillCredentials(
                          'member@ritma.demo',
                          'RitmaDemo1!',
                        ),
                      ),
                      ActionChip(
                        label: const Text('Unassigned User'),
                        onPressed: () =>
                            _fillCredentials('new@ritma.demo', 'RitmaDemo1!'),
                      ),
                    ],
                  ),
                ],
                if (showShowcaseAccounts && mode == AppMode.supabase) ...[
                  const SizedBox(height: RitmaSpacing.md),
                  const Divider(),
                  const SizedBox(height: RitmaSpacing.xs),
                  Text(
                    'Showcase Demo Accounts (Live Cloud)',
                    style: theme.textTheme.labelMedium,
                  ),
                  const SizedBox(height: RitmaSpacing.xxs),
                  Text(
                    'Portfolio showcase environment (automatically hidden in APP_ENV=prod). Pre-fills demo credentials, then click Sign In.',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: RitmaSpacing.xs),
                  Wrap(
                    spacing: RitmaSpacing.xs,
                    runSpacing: RitmaSpacing.xs,
                    children: [
                      ActionChip(
                        avatar: const Icon(
                          Icons.admin_panel_settings_outlined,
                          size: 16,
                        ),
                        label: const Text('Owner (Multi-Role)'),
                        onPressed: () => _fillCredentials(
                          'demo.owner@ritma.app',
                          'RitmaDemo2026!',
                        ),
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.storefront_outlined, size: 16),
                        label: const Text('Branch Manager'),
                        onPressed: () => _fillCredentials(
                          'demo.manager@ritma.app',
                          'RitmaDemo2026!',
                        ),
                      ),
                      ActionChip(
                        avatar: const Icon(
                          Icons.support_agent_outlined,
                          size: 16,
                        ),
                        label: const Text('Receptionist'),
                        onPressed: () => _fillCredentials(
                          'demo.receptionist@ritma.app',
                          'RitmaDemo2026!',
                        ),
                      ),
                      ActionChip(
                        avatar: const Icon(
                          Icons.event_available_outlined,
                          size: 16,
                        ),
                        label: const Text('Instructor'),
                        onPressed: () => _fillCredentials(
                          'demo.instructor@ritma.app',
                          'RitmaDemo2026!',
                        ),
                      ),
                      ActionChip(
                        avatar: const Icon(
                          Icons.fitness_center_outlined,
                          size: 16,
                        ),
                        label: const Text('Personal Trainer'),
                        onPressed: () => _fillCredentials(
                          'demo.trainer1@ritma.app',
                          'RitmaDemo2026!',
                        ),
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.qr_code_2_outlined, size: 16),
                        label: const Text('Fitness Member'),
                        onPressed: () => _fillCredentials(
                          'demo.member@ritma.app',
                          'RitmaDemo2026!',
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const RitmaSurfaceBadge(),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final wideHero = constraints.maxWidth >= 900;
                  return Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: RitmaSpacing.lg,
                        vertical: RitmaSpacing.md,
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1080),
                        child: wideHero
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        right: RitmaSpacing.xxl,
                                      ),
                                      child: _BrandShowcaseHero(),
                                    ),
                                  ),
                                  authCard,
                                ],
                              )
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  authCard,
                                  const SizedBox(height: RitmaSpacing.md),
                                  Text(
                                    'One platform. Every fitness business.',
                                    style: theme.textTheme.bodySmall,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandShowcaseHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const RitmaStatusPill(
          label: 'Unified Fitness Operating System',
          icon: Icons.bolt_outlined,
          tone: RitmaPillTone.lime,
        ),
        const SizedBox(height: RitmaSpacing.md),
        Text(
          'One platform.\nEvery fitness business.',
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: RitmaSpacing.md),
        Text(
          'Operate multi-branch athletic clubs, boutique reformer studios, and personal training teams on a single multi-tenant ledger with isolated Member & Operations experiences.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: RitmaSpacing.lg),
        const Wrap(
          spacing: RitmaSpacing.xs,
          runSpacing: RitmaSpacing.xs,
          children: [
            RitmaStatusPill(
              label: 'Multi-Branch RBAC',
              icon: Icons.account_tree_outlined,
            ),
            RitmaStatusPill(
              label: 'HMAC-Signed QR Pass',
              icon: Icons.qr_code_2_outlined,
            ),
            RitmaStatusPill(
              label: 'Waitlist & Credit Ledger',
              icon: Icons.layers_outlined,
            ),
            RitmaStatusPill(
              label: '1-on-1 PT & Equipment',
              icon: Icons.fitness_center_outlined,
            ),
          ],
        ),
      ],
    );
  }
}
