import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_env_provider.dart';
import '../../../core/theme/ritma_spacing.dart';
import '../../../core/widgets/ritma_status_pill.dart';

/// Displayed when neither Supabase configuration (`SUPABASE_URL` /
/// `SUPABASE_ANON_KEY`) nor local Demo Sandbox mode is enabled.
class BackendSetupScreen extends ConsumerWidget {
  const BackendSetupScreen({super.key});

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
              constraints: const BoxConstraints(maxWidth: 540),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(RitmaSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const RitmaStatusPill(
                        label: 'Configuration Required',
                        icon: Icons.settings_input_component_outlined,
                        tone: RitmaPillTone.warning,
                      ),
                      const SizedBox(height: RitmaSpacing.md),
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
                      Text(
                        'No Supabase client credentials were supplied for this ${env.environment.name.toUpperCase()} build.',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: RitmaSpacing.sm),
                      Text(
                        'To run against Supabase:\n'
                        '1. Copy env/dev.example.json to env/dev.json and set SUPABASE_URL and SUPABASE_ANON_KEY.\n'
                        '2. Run: flutter run --dart-define-from-file=env/dev.json',
                        style: theme.textTheme.bodySmall,
                      ),
                      if (!env.isProduction) ...[
                        const SizedBox(height: RitmaSpacing.md),
                        Text(
                          'Or run local UI Demo Sandbox mode (explicitly isolated from live auth):\n'
                          'flutter run --dart-define=ENABLE_DEMO_MODE=true',
                          style: theme.textTheme.bodySmall,
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
    );
  }
}
