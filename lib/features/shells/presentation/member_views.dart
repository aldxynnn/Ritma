import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/ritma_spacing.dart';
import '../../../core/widgets/ritma_section_header.dart';
import '../../../core/widgets/ritma_status_pill.dart';
import '../../auth/application/auth_providers.dart';

class MemberHomeView extends ConsumerWidget {
  const MemberHomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspace = ref.watch(activeWorkspaceProvider);
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(RitmaSpacing.lg),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(RitmaSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const RitmaStatusPill(
                        label: 'Member Experience',
                        icon: Icons.qr_code_2_outlined,
                        tone: RitmaPillTone.lime,
                      ),
                      const SizedBox(height: RitmaSpacing.md),
                      Text(
                        workspace?.organizationName ?? 'Member Pass',
                        style: theme.textTheme.headlineMedium,
                      ),
                      const SizedBox(height: RitmaSpacing.xs),
                      Text(
                        'Home branch: ${workspace?.scopeLabel ?? 'Unassigned'}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: RitmaSpacing.lg),
                      const Divider(),
                      const SizedBox(height: RitmaSpacing.md),
                      Text(
                        'Rotating QR Check-In Pass & Entitlement Summary',
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: RitmaSpacing.xs),
                      Text(
                        'Your rotating 60-second signed QR pass (issue_member_qr_token) and separated Facility Access vs Class Credit balances activate here in the Entitlement & QR Check-In slices.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MemberScheduleView extends StatelessWidget {
  const MemberScheduleView({super.key});

  @override
  Widget build(BuildContext context) {
    return const _MemberModulePlaceholder(
      title: 'Class Schedule',
      subtitle: 'Discover classes by branch, instructor, and discipline',
      icon: Icons.calendar_today_outlined,
      description: 'Backed by class_sessions and atomic book_class_session RPC capacity locking. No synthetic schedule rows are shown until connected.',
    );
  }
}

class MemberBookingsView extends StatelessWidget {
  const MemberBookingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const _MemberModulePlaceholder(
      title: 'My Bookings & Waitlists',
      subtitle:
          'Confirmed classes, FIFO waitlist positions, and credit refunds',
      icon: Icons.bookmark_border,
      description: 'Displays live class_bookings and credit_ledger_entries refunds on early cancellations.',
    );
  }
}

class _MemberModulePlaceholder extends StatelessWidget {
  const _MemberModulePlaceholder({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.description,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String description;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(RitmaSpacing.lg),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(RitmaSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RitmaSectionHeader(
                    title: title,
                    subtitle: subtitle,
                    trailing: Icon(icon),
                  ),
                  const SizedBox(height: RitmaSpacing.md),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall,
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
