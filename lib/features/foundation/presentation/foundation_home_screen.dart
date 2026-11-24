import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_env_provider.dart';
import '../../../core/theme/ritma_spacing.dart';

/// Minimal foundation landing view confirming core shell, theming,
/// routing, and environment configuration prior to business module rollout.
class FoundationHomeScreen extends ConsumerWidget {
  const FoundationHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final env = ref.watch(appEnvProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(RitmaSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(RitmaSpacing.lg),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('RITMA', style: theme.textTheme.displaySmall),
                      const SizedBox(height: RitmaSpacing.xs),
                      Text(
                        'One platform. Every fitness business.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: RitmaSpacing.lg),
                      const Divider(),
                      const SizedBox(height: RitmaSpacing.md),
                      _StatusRow(
                        label: 'Environment',
                        value: env.environment.name.toUpperCase(),
                      ),
                      const SizedBox(height: RitmaSpacing.xs),
                      _StatusRow(
                        label: 'Backend Config',
                        value: env.hasSupabaseConfig
                            ? 'Configured'
                            : 'Pending Milestone 2',
                      ),
                      const SizedBox(height: RitmaSpacing.xs),
                      const _StatusRow(
                        label: 'Workspace Status',
                        value: 'Foundation Ready',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(label, style: theme.textTheme.bodySmall)),
        const SizedBox(width: RitmaSpacing.sm),
        Flexible(
          child: Text(
            value,
            style: theme.textTheme.labelLarge,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
