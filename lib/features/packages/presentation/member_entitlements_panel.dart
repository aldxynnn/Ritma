import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/ritma_spacing.dart';
import '../../../core/widgets/async_state_view.dart';
import '../../../core/widgets/ritma_metric_tile.dart';
import '../../../core/widgets/ritma_section_header.dart';
import '../../../core/widgets/ritma_status_pill.dart';
import '../../auth/application/auth_providers.dart';
import '../application/package_providers.dart';
import '../domain/package_models.dart';

class MemberEntitlementsPanel extends ConsumerWidget {
  const MemberEntitlementsPanel({required this.memberId, super.key});

  final String memberId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspace = ref.watch(activeWorkspaceProvider);
    final walletAsync = ref.watch(memberWalletProvider(memberId));
    final canAssign = ref.watch(hasPermissionProvider('entitlement.assign'));
    final canAdjust = ref.watch(hasPermissionProvider('credit.adjust'));

    if (workspace == null) {
      return const SizedBox.shrink();
    }

    return AsyncStateView<MemberWalletSnapshot>(
      value: walletAsync,
      onRetry: () => ref.invalidate(memberWalletProvider(memberId)),
      data: (wallet) {
        final dateFmt = DateFormat.yMMMd();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: RitmaSpacing.sm,
              runSpacing: RitmaSpacing.sm,
              children: [
                SizedBox(
                  width: 170,
                  child: RitmaMetricTile(
                    label: 'Facility Access',
                    value: wallet.hasActiveFacilityAccess ? 'Active' : 'None',
                    icon: Icons.door_front_door_outlined,
                  ),
                ),
                SizedBox(
                  width: 170,
                  child: RitmaMetricTile(
                    label: 'Class Credits',
                    value: '${wallet.totalClassCredits}',
                    icon: Icons.confirmation_number_outlined,
                  ),
                ),
                SizedBox(
                  width: 170,
                  child: RitmaMetricTile(
                    label: 'PT Credits',
                    value: '${wallet.totalPtCredits}',
                    icon: Icons.fitness_center_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: RitmaSpacing.md),
            const RitmaSectionHeader(title: 'Subscriptions'),
            const SizedBox(height: RitmaSpacing.xs),
            if (wallet.subscriptions.isEmpty)
              Text(
                'No subscriptions assigned yet.',
                style: Theme.of(context).textTheme.bodySmall,
              )
            else
              ...wallet.subscriptions.map(
                (sub) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(RitmaSpacing.sm),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Subscription ${sub.id.substring(0, 8)}',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              Text(
                                'Ends: ${sub.endsAt != null ? dateFmt.format(sub.endsAt!.toLocal()) : 'No expiry'}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        RitmaStatusPill(
                          label: sub.status.name.toUpperCase(),
                          tone: sub.status == SubscriptionStatus.active
                              ? RitmaPillTone.success
                              : RitmaPillTone.warning,
                        ),
                        if (canAssign &&
                            (sub.status == SubscriptionStatus.active ||
                                sub.status == SubscriptionStatus.frozen)) ...[
                          const SizedBox(width: RitmaSpacing.xs),
                          TextButton(
                            onPressed: () async {
                              final repo = ref.read(
                                packageEntitlementRepositoryProvider,
                              );
                              if (repo == null) {
                                return;
                              }
                              final res =
                                  sub.status == SubscriptionStatus.active
                                  ? await repo.freezeSubscription(
                                      orgId: workspace.organizationId,
                                      subscriptionId: sub.id,
                                    )
                                  : await repo.unfreezeSubscription(
                                      orgId: workspace.organizationId,
                                      subscriptionId: sub.id,
                                    );
                              if (!context.mounted) {
                                return;
                              }
                              res.when(
                                success: (_) => ref.invalidate(
                                  memberWalletProvider(memberId),
                                ),
                                failure: (f) => ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                      SnackBar(content: Text(f.message)),
                                    ),
                              );
                            },
                            child: Text(
                              sub.status == SubscriptionStatus.active
                                  ? 'Freeze'
                                  : 'Unfreeze',
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: RitmaSpacing.md),
            RitmaSectionHeader(
              title: 'Credit Ledger (Append-Only)',
              trailing: canAdjust
                  ? OutlinedButton.icon(
                      onPressed: () => _showAdjustCreditsDialog(
                        context,
                        ref,
                        workspace.organizationId,
                      ),
                      icon: const Icon(Icons.tune, size: 16),
                      label: const Text('Adjust'),
                    )
                  : null,
            ),
            const SizedBox(height: RitmaSpacing.xs),
            if (wallet.ledgerEntries.isEmpty)
              Text(
                'No credit ledger activity yet.',
                style: Theme.of(context).textTheme.bodySmall,
              )
            else
              ...wallet.ledgerEntries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: RitmaSpacing.xxs),
                  child: Card(
                    child: ListTile(
                      dense: true,
                      title: Text(entry.reason ?? entry.entryType.name),
                      subtitle: Text(
                        '${entry.entryType.name.toUpperCase()} • ${entry.creditType.label}',
                      ),
                      trailing: RitmaStatusPill(
                        label: '${entry.delta > 0 ? '+' : ''}${entry.delta}',
                        tone: entry.delta > 0
                            ? RitmaPillTone.success
                            : RitmaPillTone.danger,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _showAdjustCreditsDialog(
    BuildContext context,
    WidgetRef ref,
    String orgId,
  ) async {
    final deltaCtrl = TextEditingController(text: '1');
    final reasonCtrl = TextEditingController();
    var creditType = CreditType.classCredit;
    final key = const Uuid().v4();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setInnerState) => AlertDialog(
          title: const Text('Adjust Member Credits'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<CreditType>(
                initialValue: creditType,
                decoration: const InputDecoration(labelText: 'Credit Type'),
                items: CreditType.values
                    .map(
                      (t) => DropdownMenuItem(value: t, child: Text(t.label)),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setInnerState(() => creditType = val);
                  }
                },
              ),
              const SizedBox(height: RitmaSpacing.sm),
              TextField(
                controller: deltaCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  signed: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Delta (e.g. +2 or -1)',
                ),
              ),
              const SizedBox(height: RitmaSpacing.sm),
              TextField(
                controller: reasonCtrl,
                decoration: const InputDecoration(
                  labelText: 'Audit Reason (required)',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final repo = ref.read(packageEntitlementRepositoryProvider);
                final delta = int.tryParse(deltaCtrl.text.trim()) ?? 0;
                if (repo == null ||
                    delta == 0 ||
                    reasonCtrl.text.trim().isEmpty) {
                  return;
                }
                final res = await repo.adjustMemberCredits(
                  orgId: orgId,
                  memberId: memberId,
                  creditType: creditType,
                  delta: delta,
                  reason: reasonCtrl.text,
                  idempotencyKey: key,
                );
                if (!dialogContext.mounted) {
                  return;
                }
                res.when(
                  success: (_) {
                    ref.invalidate(memberWalletProvider(memberId));
                    Navigator.of(dialogContext).pop();
                  },
                  failure: (f) =>
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(f.message))),
                );
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }
}
