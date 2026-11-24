import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/ritma_spacing.dart';
import '../../../core/widgets/ritma_surface_badge.dart';
import '../application/auth_providers.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _submitting = false;
  bool _sent = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
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
        .sendPasswordResetEmail(email: _emailController.text);

    if (!mounted) {
      return;
    }

    result.when(
      success: (_) {
        setState(() {
          _submitting = false;
          _sent = true;
        });
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
      appBar: AppBar(title: const Text('Reset Password')),
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
                                'Password Recovery',
                                style: theme.textTheme.headlineSmall,
                              ),
                              const SizedBox(height: RitmaSpacing.xs),
                              Text(
                                'Enter your account email and we will send a recovery link.',
                                style: theme.textTheme.bodySmall,
                              ),
                              const SizedBox(height: RitmaSpacing.lg),
                              if (_sent)
                                Text(
                                  'If an account exists for ${_emailController.text.trim()}, a password recovery email has been dispatched.',
                                  style: theme.textTheme.bodyMedium,
                                )
                              else ...[
                                if (_errorMessage != null) ...[
                                  Text(
                                    _errorMessage!,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.error,
                                    ),
                                  ),
                                  const SizedBox(height: RitmaSpacing.sm),
                                ],
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
                                      : const Text('Send Recovery Link'),
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
