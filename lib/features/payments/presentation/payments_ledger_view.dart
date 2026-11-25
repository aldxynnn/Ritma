import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../core/state/ritma_sync.dart';
import '../../../core/theme/ritma_spacing.dart';
import '../../../core/utils/ritma_timezone.dart';
import '../../../core/widgets/async_state_view.dart';
import '../../../core/widgets/ritma_metric_tile.dart';
import '../../../core/widgets/ritma_page_container.dart';
import '../../../core/widgets/ritma_section_header.dart';
import '../../../core/widgets/ritma_status_pill.dart';
import '../../auth/application/auth_providers.dart';
import '../../organizations/application/organization_providers.dart';
import '../application/payment_providers.dart';
import '../domain/payment_record_model.dart';

class PaymentsLedgerView extends ConsumerWidget {
  const PaymentsLedgerView({super.key, this.forMemberOnly = false});

  final bool forMemberOnly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspace = ref.watch(activeWorkspaceProvider);
    final org = ref.watch(activeOrganizationProvider).asData?.value;
    final paymentsAsync = ref.watch(
      forMemberOnly ? memberPaymentsProvider : orgPaymentsProvider,
    );
    final canRefund =
        !forMemberOnly && ref.watch(hasPermissionProvider('payment.refund'));
    final tz = org?.timezone ?? 'UTC';
    final orgCurrency = org?.currencyCode;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(
          forMemberOnly ? memberPaymentsProvider : orgPaymentsProvider,
        );
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: RitmaPageContainer(
          maxWidth: forMemberOnly ? 720 : 1200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              RitmaSectionHeader(
                title: forMemberOnly ? 'My Payment History' : 'Payments Ledger',
                subtitle: forMemberOnly
                    ? 'Recorded package and membership transactions'
                    : 'Verified subscription payments, manual refund audit trail, and net volume',
                trailing: IconButton(
                  tooltip: 'Refresh payments',
                  onPressed: () => ref.invalidate(
                    forMemberOnly
                        ? memberPaymentsProvider
                        : orgPaymentsProvider,
                  ),
                  icon: const Icon(Icons.refresh),
                ),
              ),
              const SizedBox(height: RitmaSpacing.md),
              AsyncStateView<List<PaymentRecordModel>>(
                value: paymentsAsync,
                isEmpty: (list) => list.isEmpty,
                emptyTitle: 'No payment records yet',
                emptyMessage: 'Payments appear automatically when packages or memberships are assigned.',
                onRetry: () => ref.invalidate(
                  forMemberOnly ? memberPaymentsProvider : orgPaymentsProvider,
                ),
                data: (payments) {
                  final grossPaidMinor = payments
                      .where(
                        (p) =>
                            p.status == PaymentStatus.paid ||
                            p.status == PaymentStatus.refunded,
                      )
                      .fold<int>(0, (sum, p) => sum + p.amountMinor);
                  final refundedTotalMinor = payments.fold<int>(
                    0,
                    (sum, p) => sum + p.refundedAmountMinor,
                  );
                  final netCollectedMinor =
                      (grossPaidMinor - refundedTotalMinor).clamp(
                        0,
                        grossPaidMinor,
                      );
                  final displayCurrency =
                      payments.firstOrNull?.currencyCode ??
                      orgCurrency ??
                      'USD';

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!forMemberOnly) ...[
                        Wrap(
                          spacing: RitmaSpacing.sm,
                          runSpacing: RitmaSpacing.sm,
                          children: [
                            SizedBox(
                              width: 240,
                              child: RitmaMetricTile(
                                label: 'Paid Volume',
                                value: RitmaTimezone.formatMoney(
                                  grossPaidMinor,
                                  displayCurrency,
                                ),
                                caption: 'Gross billed',
                                icon: Icons.payments_outlined,
                              ),
                            ),
                            SizedBox(
                              width: 240,
                              child: RitmaMetricTile(
                                label: 'Refunded',
                                value: RitmaTimezone.formatMoney(
                                  refundedTotalMinor,
                                  displayCurrency,
                                ),
                                caption: 'Manual recorded refunds',
                                icon: Icons.replay_outlined,
                              ),
                            ),
                            SizedBox(
                              width: 240,
                              child: RitmaMetricTile(
                                label: 'Net Collected',
                                value: RitmaTimezone.formatMoney(
                                  netCollectedMinor,
                                  displayCurrency,
                                ),
                                caption: '${payments.length} transactions',
                                icon: Icons.account_balance_wallet_outlined,
                                highlighted: netCollectedMinor > 0,
                              ),
                            ),
                            SizedBox(
                              width: 200,
                              child: RitmaMetricTile(
                                label: 'Payment Records',
                                value: '${payments.length}',
                                caption: 'Audit-tracked entries',
                                icon: Icons.receipt_long_outlined,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: RitmaSpacing.md),
                      ],
                      ...payments.map((p) {
                        final tone = switch (p.status) {
                          PaymentStatus.paid =>
                            p.isPartiallyRefunded
                                ? RitmaPillTone.warning
                                : RitmaPillTone.success,
                          PaymentStatus.pending => RitmaPillTone.warning,
                          PaymentStatus.refunded => RitmaPillTone.neutral,
                          PaymentStatus.voided => RitmaPillTone.danger,
                        };
                        final statusLabel = p.isPartiallyRefunded
                            ? 'PARTIAL REFUND'
                            : p.status.displayLabel.toUpperCase();

                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: RitmaSpacing.xs,
                          ),
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(RitmaSpacing.md),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.receipt_long_outlined),
                                      const SizedBox(width: RitmaSpacing.sm),
                                      Expanded(
                                        child: Text(
                                          RitmaTimezone.formatMoney(
                                            p.amountMinor,
                                            p.currencyCode,
                                          ),
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                      ),
                                      RitmaStatusPill(
                                        label: statusLabel,
                                        tone: tone,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: RitmaSpacing.xxs),
                                  Text(
                                    '${p.memberDisplayName.isNotEmpty ? '${p.memberDisplayName} • ' : ''}'
                                    '${p.method.label} • ${RitmaTimezone.formatDateTime(p.paidAt, tz)}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall,
                                  ),
                                  if (p.refundedAmountMinor > 0) ...[
                                    const SizedBox(height: RitmaSpacing.xxs),
                                    Text(
                                      'Refunded: ${RitmaTimezone.formatMoney(p.refundedAmountMinor, p.currencyCode)} '
                                      '(Net ${RitmaTimezone.formatMoney(p.netAmountMinor, p.currencyCode)}) • Recorded manually'
                                      '${p.refundReason != null && p.refundReason!.isNotEmpty ? ' • ${p.refundReason}' : ''}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall,
                                    ),
                                  ],
                                  if ((canRefund &&
                                          p.status == PaymentStatus.paid &&
                                          p.remainingRefundableMinor > 0 &&
                                          workspace != null) ||
                                      p.refundedAmountMinor > 0) ...[
                                    const SizedBox(height: RitmaSpacing.sm),
                                    Wrap(
                                      spacing: RitmaSpacing.xs,
                                      runSpacing: RitmaSpacing.xs,
                                      children: [
                                        if (canRefund &&
                                            p.status == PaymentStatus.paid &&
                                            p.remainingRefundableMinor > 0 &&
                                            workspace != null)
                                          OutlinedButton.icon(
                                            onPressed: () async {
                                              final outcome =
                                                  await showDialog<
                                                    RefundOutcome
                                                  >(
                                                    context: context,
                                                    builder: (_) =>
                                                        _RecordRefundDialog(
                                                          orgId: workspace
                                                              .organizationId,
                                                          payment: p,
                                                        ),
                                                  );
                                              if (outcome != null &&
                                                  context.mounted) {
                                                RitmaSync.afterPackageOrPaymentMutation(
                                                  ref,
                                                  memberId: p.memberId,
                                                  paymentId: p.id,
                                                );
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Manual refund of ${RitmaTimezone.formatMoney(outcome.amountMinor, p.currencyCode)} recorded.',
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                            icon: const Icon(
                                              Icons.replay_outlined,
                                              size: 16,
                                            ),
                                            label: const Text('Record Refund'),
                                          ),
                                        if (p.refundedAmountMinor > 0)
                                          TextButton.icon(
                                            onPressed: () =>
                                                showModalBottomSheet<void>(
                                                  context: context,
                                                  isScrollControlled: true,
                                                  builder: (_) =>
                                                      _RefundHistorySheet(
                                                        payment: p,
                                                        timezone: tz,
                                                      ),
                                                ),
                                            icon: const Icon(
                                              Icons.history,
                                              size: 16,
                                            ),
                                            label: const Text('Refund History'),
                                          ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecordRefundDialog extends ConsumerStatefulWidget {
  const _RecordRefundDialog({required this.orgId, required this.payment});

  final String orgId;
  final PaymentRecordModel payment;

  @override
  ConsumerState<_RecordRefundDialog> createState() =>
      _RecordRefundDialogState();
}

class _RecordRefundDialogState extends ConsumerState<_RecordRefundDialog> {
  final _formKey = GlobalKey<FormState>();
  final String _idempotencyKey = const Uuid().v4();
  late final TextEditingController _amountCtrl;
  final _reasonCtrl = TextEditingController();
  final _externalRefCtrl = TextEditingController();
  bool _saving = false;
  String? _inlineError;

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController(
      text: (widget.payment.remainingRefundableMinor / 100.0).toStringAsFixed(
        2,
      ),
    );
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _reasonCtrl.dispose();
    _externalRefCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final parsed = double.tryParse(_amountCtrl.text.trim());
    if (parsed == null || parsed <= 0) {
      setState(() => _inlineError = 'Enter a positive refund amount.');
      return;
    }
    final amountMinor = (parsed * 100).round();
    if (amountMinor > widget.payment.remainingRefundableMinor) {
      setState(
        () => _inlineError =
            'Refund exceeds remaining refundable balance (${RitmaTimezone.formatMoney(widget.payment.remainingRefundableMinor, widget.payment.currencyCode)}).',
      );
      return;
    }

    final repo = ref.read(paymentRepositoryProvider);
    if (repo == null) {
      setState(() => _inlineError = 'Payment service unavailable.');
      return;
    }
    setState(() {
      _saving = true;
      _inlineError = null;
    });
    final res = await repo.recordPaymentRefund(
      orgId: widget.orgId,
      paymentId: widget.payment.id,
      amountMinor: amountMinor,
      reason: _reasonCtrl.text.trim(),
      idempotencyKey: _idempotencyKey,
      externalReference: _externalRefCtrl.text,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    res.when(
      success: (outcome) => Navigator.of(context).pop(outcome),
      failure: (f) => setState(() => _inlineError = f.message),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.payment;
    final theme = Theme.of(context);
    return AlertDialog(
      title: const Text('Record Manual Refund'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(RitmaSpacing.sm),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer.withValues(
                      alpha: 0.45,
                    ),
                    borderRadius: BorderRadius.circular(RitmaRadius.md),
                  ),
                  child: Text(
                    'Manual accounting record only: RITMA records the refund in your financial ledger and audit log, but does NOT settle funds via an external payment gateway.',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                const SizedBox(height: RitmaSpacing.sm),
                Text(
                  'Remaining refundable: ${RitmaTimezone.formatMoney(p.remainingRefundableMinor, p.currencyCode)} of ${RitmaTimezone.formatMoney(p.amountMinor, p.currencyCode)}',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: RitmaSpacing.sm),
                if (_inlineError != null) ...[
                  Text(
                    _inlineError!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: RitmaSpacing.sm),
                ],
                TextFormField(
                  controller: _amountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Refund Amount (${p.currencyCode})',
                  ),
                  validator: (v) {
                    final parsed = double.tryParse((v ?? '').trim());
                    if (parsed == null || parsed <= 0) {
                      return 'Enter an amount > 0';
                    }
                    final minor = (parsed * 100).round();
                    if (minor > p.remainingRefundableMinor) {
                      return 'Exceeds remaining refundable balance';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: RitmaSpacing.sm),
                TextFormField(
                  controller: _reasonCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Refund Reason (required)',
                    hintText:
                        'Duplicate charge, class cancellation credit, etc.',
                  ),
                  validator: (v) => (v == null || v.trim().length < 3)
                      ? 'Enter a reason (min 3 characters).'
                      : null,
                ),
                const SizedBox(height: RitmaSpacing.sm),
                TextFormField(
                  controller: _externalRefCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Bank / Receipt Reference (optional)',
                  ),
                ),
              ],
            ),
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
          child: Text(_saving ? 'Recording...' : 'Record Manual Refund'),
        ),
      ],
    );
  }
}

class _RefundHistorySheet extends ConsumerWidget {
  const _RefundHistorySheet({required this.payment, required this.timezone});

  final PaymentRecordModel payment;
  final String timezone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final refundsAsync = ref.watch(paymentRefundsProvider(payment.id));
    final fmt = DateFormat.yMMMd().add_jm();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(RitmaSpacing.md),
        child: SizedBox(
          height: 360,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Refund Audit Trail',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: RitmaSpacing.sm),
              Expanded(
                child: AsyncStateView<List<PaymentRefundModel>>(
                  value: refundsAsync,
                  isEmpty: (list) => list.isEmpty,
                  emptyTitle: 'No refund entries',
                  data: (list) => ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (ctx, i) {
                      final r = list[i];
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.replay_outlined),
                          title: Text(
                            RitmaTimezone.formatMoney(
                              r.amountMinor,
                              r.currencyCode,
                            ),
                          ),
                          subtitle: Text(
                            '${r.reason ?? 'Manual refund'} • ${r.refundChannel}\n'
                            '${fmt.format(r.createdAt.toLocal())}'
                            '${r.externalReference != null ? ' • Ref: ${r.externalReference}' : ''}',
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
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
