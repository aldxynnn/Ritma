import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_env_provider.dart';
import '../theme/ritma_spacing.dart';
import '../theme/ritma_status_colors.dart';

/// Displays an explicit, unmistakable banner whenever non-production Demo
/// Sandbox mode is active without live Supabase credentials.
class RitmaSurfaceBadge extends ConsumerWidget {
  const RitmaSurfaceBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final env = ref.watch(appEnvProvider);
    final isDemoSandbox =
        !env.isProduction && env.enableDemoMode && !env.hasSupabaseConfig;

    if (!isDemoSandbox) {
      return const SizedBox.shrink();
    }

    final status = context.statusColors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: RitmaSpacing.md,
        vertical: RitmaSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: status.warningBg,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).colorScheme.outline),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.science_outlined, size: 16, color: status.warningFg),
          const SizedBox(width: RitmaSpacing.xs),
          Flexible(
            child: Text(
              'DEMO SANDBOX MODE — Local in-memory preview (not connected to live Supabase)',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: status.warningFg,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
