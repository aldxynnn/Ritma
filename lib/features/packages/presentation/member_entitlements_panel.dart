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
    final packages =
        ref.watch(orgPackagesProvider).asData?.value ?? const <PackageModel>[];
    final packageNames = <String, String>{
      for (final p in packages) p.id: p.name,
    };
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
                                packageNames[sub.packageId] ??
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
    String orgId,
  ) async {
    final feedback = await showDialog<String>(
      context: context,
      builder: (_) => _AdjustCreditsDialog(orgId: orgId, memberId: memberId),
    );
    if (feedback != null && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(feedback)));
    }
  }
}

class _AdjustCreditsDialog extends ConsumerStatefulWidget {
  const _AdjustCreditsDialog({required this.orgId, required this.memberId});

  final String orgId;
  final String memberId;

  @override
  ConsumerState<_AdjustCreditsDialog> createState() =>
      _AdjustCreditsDialogState();
}

class _AdjustCreditsDialogState extends ConsumerState<_AdjustCreditsDialog> {
  final _formKey = GlobalKey<FormState>();
  final _deltaCtrl = TextEditingController(text: '1');
  final _reasonCtrl = TextEditingController();
  CreditType _creditType = CreditType.classCredit;
  bool _saving = false;
  String? _inlineError;
  final String _idempotencyKey = const Uuid().v4();

  @override
  void dispose() {
    _deltaCtrl.dispose();
    _reasonCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      setState(() => _inlineError = 'Fix highlighted fields before applying.');
      return;
    }
    final repo = ref.read(packageEntitlementRepositoryProvider);
    final delta = int.tryParse(_deltaCtrl.text.trim()) ?? 0;
    if (repo == null || delta == 0) {
      setState(() => _inlineError = 'Repository unavailable.');
      return;
    }
    setState(() {
      _saving = true;
      _inlineError = null;
    });
    final res = await repo.adjustMemberCredits(
      orgId: widget.orgId,
      memberId: widget.memberId,
      creditType: _creditType,
      delta: delta,
      reason: _reasonCtrl.text,
      idempotencyKey: _idempotencyKey,
    );
    if (!mounted) {
      return;
    }
    setState(() => _saving = false);
    res.when(
      success: (_) {
        ref.invalidate(memberWalletProvider(widget.memberId));
        Navigator.of(context).pop(
          'Adjusted ${_creditType.label} by ${delta > 0 ? '+' : ''}$delta.',
        );
      },
      failure: (f) => setState(() => _inlineError = f.message),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: const Text('Adjust Member Credits'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_inlineError != null) ...[
                Container(
                  padding: const EdgeInsets.all(RitmaSpacing.sm),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(RitmaRadius.md),
                    border: Border.all(color: theme.colorScheme.error),
                  ),
                  child: Text(
                    _inlineError!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
                const SizedBox(height: RitmaSpacing.sm),
              ],
              DropdownButtonFormField<CreditType>(
                initialValue: _creditType,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Credit Type'),
                items: CreditType.values
                    .map(
                      (t) => DropdownMenuItem(
                        value: t,
                        child: Text(t.label, overflow: TextOverflow.ellipsis),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _creditType = val);
                  }
                },
              ),
              const SizedBox(height: RitmaSpacing.sm),
              TextFormField(
                controller: _deltaCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  signed: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Delta (e.g. +2 or -1)',
                ),
                validator: (v) {
                  final n = int.tryParse((v ?? '').trim());
                  if (n == null || n == 0) {
                    return 'Enter a non-zero integer.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: RitmaSpacing.sm),
              TextFormField(
                controller: _reasonCtrl,
                decoration: const InputDecoration(
                  labelText: 'Audit Reason (required)',
                ),
                validator: (v) => (v == null || v.trim().length < 3)
                    ? 'Enter an audit reason (min 3 chars).'
                    : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _submit,
          child: Text(_saving ? 'Applying...' : 'Apply'),
        ),
      ],
    );
  }
}
