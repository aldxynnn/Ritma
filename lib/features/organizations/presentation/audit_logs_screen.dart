import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/ritma_spacing.dart';
import '../../../core/utils/ritma_timezone.dart';
import '../../../core/widgets/async_state_view.dart';
import '../../../core/widgets/ritma_status_pill.dart';
import '../application/organization_providers.dart';
import '../domain/audit_log_model.dart';

/// Read-only operational and financial audit log viewer (`audit.read`).
class AuditLogsSheet extends ConsumerWidget {
  const AuditLogsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(auditLogsProvider);
    final org = ref.watch(activeOrganizationProvider).asData?.value;
    final tz = org?.timezone ?? 'UTC';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Security & Operations Audit Log'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => ref.invalidate(auditLogsProvider),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: AsyncStateView<List<AuditLogModel>>(
        value: logsAsync,
        isEmpty: (list) => list.isEmpty,
        emptyTitle: 'No audit events recorded yet',
        emptyMessage: 'Role changes, payment refunds, member edits, and key rotations appear here.',
        onRetry: () => ref.invalidate(auditLogsProvider),
        data: (logs) => ListView.builder(
          padding: const EdgeInsets.all(RitmaSpacing.md),
          itemCount: logs.length,
          itemBuilder: (context, index) {
            final log = logs[index];
            return Card(
              margin: const EdgeInsets.only(bottom: RitmaSpacing.xs),
              child: ListTile(
                leading: const Icon(Icons.policy_outlined),
                title: Text(log.action),
                subtitle: Text(
                  '${log.targetType}${log.targetId != null ? ' • ${log.targetId!.substring(0, log.targetId!.length >= 8 ? 8 : log.targetId!.length)}' : ''}\n'
                  '${RitmaTimezone.formatDateTime(log.createdAt, tz)}'
                  '${log.metadata.isNotEmpty ? '\n${log.metadata}' : ''}',
                ),
                isThreeLine: true,
                trailing: const RitmaStatusPill(label: 'Audit'),
              ),
            );
          },
        ),
      ),
    );
  }
}
