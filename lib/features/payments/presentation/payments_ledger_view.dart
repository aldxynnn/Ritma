import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/ritma_spacing.dart';
import '../../../core/widgets/async_state_view.dart';
import '../../../core/widgets/ritma_metric_tile.dart';
import '../../../core/widgets/ritma_page_container.dart';
import '../../../core/widgets/ritma_section_header.dart';
import '../../../core/widgets/ritma_status_pill.dart';
import '../application/payment_providers.dart';
import '../domain/payment_record_model.dart';

class PaymentsLedgerView extends ConsumerWidget {
  const PaymentsLedgerView({super.key, this.forMemberOnly = false});

  final bool forMemberOnly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(
      forMemberOnly ? memberPaymentsProvider : orgPaymentsProvider,
    );

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
                    : 'Verified subscription payments across the active scope',
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
                  final timeFmt = DateFormat.yMMMd().add_jm();
                  final paidMinor = payments
                      .where((p) => p.status == PaymentStatus.paid)
                      .fold<int>(0, (sum, p) => sum + p.amountMinor);
                  final summaryFmt = NumberFormat.currency(
                    symbol: r'$',
                    decimalDigits: 2,
                  );

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!forMemberOnly) ...[
                        Row(
                          children: [
                            Expanded(
                              child: RitmaMetricTile(
                                label: 'Paid Volume',
                                value: summaryFmt.format(paidMinor / 100.0),
                                caption: 'Listed transactions',
                                icon: Icons.payments_outlined,
                                highlighted: paidMinor > 0,
                              ),
                            ),
                            const SizedBox(width: RitmaSpacing.sm),
                            Expanded(
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
                        final moneyFmt = NumberFormat.currency(
                          symbol: p.currencyCode == 'USD'
                              ? r'$'
                              : '${p.currencyCode} ',
                          decimalDigits: 2,
                        );
                        final tone = switch (p.status) {
                          PaymentStatus.paid => RitmaPillTone.success,
                          PaymentStatus.pending => RitmaPillTone.warning,
                          PaymentStatus.refunded => RitmaPillTone.neutral,
                          PaymentStatus.voided => RitmaPillTone.danger,
                        };

                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: RitmaSpacing.xs,
                          ),
                          child: Card(
                            child: ListTile(
                              leading: const Icon(Icons.receipt_long_outlined),
                              title: Text(
                                moneyFmt.format(p.amountMinor / 100.0),
                              ),
                              subtitle: Text(
                                '${p.memberDisplayName.isNotEmpty ? '${p.memberDisplayName} • ' : ''}'
                                '${p.method.label} • ${timeFmt.format(p.paidAt.toLocal())}',
                              ),
                              trailing: RitmaStatusPill(
                                label: p.status.displayLabel.toUpperCase(),
                                tone: tone,
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
