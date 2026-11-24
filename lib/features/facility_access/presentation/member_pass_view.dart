import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/theme/ritma_spacing.dart';
import '../../../core/widgets/async_state_view.dart';
import '../../../core/widgets/ritma_metric_tile.dart';
import '../../../core/widgets/ritma_page_container.dart';
import '../../../core/widgets/ritma_section_header.dart';
import '../../../core/widgets/ritma_status_pill.dart';
import '../../auth/application/auth_providers.dart';
import '../../packages/application/package_providers.dart';
import '../../packages/domain/package_models.dart';
import '../application/facility_access_providers.dart';
import '../domain/facility_access_models.dart';

class MemberPassView extends ConsumerWidget {
  const MemberPassView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspace = ref.watch(activeWorkspaceProvider);
    final memberId = workspace?.memberId;
    final theme = Theme.of(context);

    if (workspace == null || memberId == null) {
      return Padding(
        padding: const EdgeInsets.all(RitmaSpacing.lg),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(RitmaSpacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No Member Profile Linked',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: RitmaSpacing.xs),
                Text(
                  'This workspace role is not linked to a member pass record yet.',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final walletAsync = ref.watch(memberWalletProvider(memberId));
    final qrAsync = ref.watch(memberQrPassProvider);
    final visitsAsync = ref.watch(memberVisitsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(memberWalletProvider(memberId));
        ref.invalidate(memberQrPassProvider);
        ref.invalidate(memberVisitsProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: RitmaPageContainer(
          maxWidth: 960,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(RitmaRadius.lg),
                  side: BorderSide(
                    color: theme.colorScheme.primary.withValues(alpha: 0.45),
                    width: 1.25,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(RitmaSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Wrap(
                        spacing: RitmaSpacing.xs,
                        runSpacing: RitmaSpacing.xs,
                        children: [
                          const RitmaStatusPill(
                            label: 'Digital Access Pass',
                            icon: Icons.qr_code_2_outlined,
                            tone: RitmaPillTone.lime,
                          ),
                          RitmaStatusPill(label: workspace.organizationName),
                          RitmaStatusPill(label: workspace.scopeLabel),
                        ],
                      ),
                      const SizedBox(height: RitmaSpacing.md),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final wide = constraints.maxWidth >= 680;
                          final walletSection =
                              AsyncStateView<MemberWalletSnapshot>(
                                value: walletAsync,
                                onRetry: () => ref.invalidate(
                                  memberWalletProvider(memberId),
                                ),
                                data: (wallet) {
                                  final hasAccess =
                                      wallet.hasActiveFacilityAccess;
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Wrap(
                                        spacing: RitmaSpacing.xs,
                                        runSpacing: RitmaSpacing.xs,
                                        children: [
                                          RitmaStatusPill(
                                            label: hasAccess
                                                ? 'Facility Access Active'
                                                : 'No Active Facility Pass',
                                            icon: hasAccess
                                                ? Icons.verified_user_outlined
                                                : Icons.lock_outline,
                                            tone: hasAccess
                                                ? RitmaPillTone.success
                                                : RitmaPillTone.warning,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: RitmaSpacing.md),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: RitmaMetricTile(
                                              label: 'Class Credits',
                                              value:
                                                  '${wallet.totalClassCredits}',
                                              caption: 'Booking balance',
                                              icon: Icons
                                                  .confirmation_number_outlined,
                                              highlighted:
                                                  wallet.totalClassCredits > 0,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: RitmaSpacing.sm,
                                          ),
                                          Expanded(
                                            child: RitmaMetricTile(
                                              label: 'PT Credits',
                                              value: '${wallet.totalPtCredits}',
                                              caption: '1-on-1 balance',
                                              icon:
                                                  Icons.fitness_center_outlined,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              );

                          final qrSection = AsyncStateView<QrPassToken?>(
                            value: qrAsync,
                            onRetry: () => ref.invalidate(memberQrPassProvider),
                            data: (pass) {
                              if (pass == null) {
                                return Text(
                                  'Unable to issue a dynamic QR token.',
                                  style: theme.textTheme.bodySmall,
                                );
                              }
                              final expFmt = DateFormat.Hms().format(
                                pass.expiresAt.toLocal(),
                              );
                              return Column(
                                children: [
                                  Center(
                                    child: Container(
                                      padding: const EdgeInsets.all(
                                        RitmaSpacing.md,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(
                                          RitmaRadius.lg,
                                        ),
                                        border: Border.all(
                                          color: theme.colorScheme.primary
                                              .withValues(alpha: 0.5),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: QrImageView(
                                        data: pass.token,
                                        size: 196,
                                        backgroundColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: RitmaSpacing.sm),
                                  Text(
                                    'Valid for ${pass.ttlSeconds}s • Expires at $expFmt',
                                    style: theme.textTheme.bodySmall,
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: RitmaSpacing.sm),
                                  Wrap(
                                    alignment: WrapAlignment.center,
                                    spacing: RitmaSpacing.xs,
                                    runSpacing: RitmaSpacing.xs,
                                    children: [
                                      FilledButton.icon(
                                        onPressed: () => ref.invalidate(
                                          memberQrPassProvider,
                                        ),
                                        icon: const Icon(
                                          Icons.refresh,
                                          size: 18,
                                        ),
                                        label: const Text('Rotate QR'),
                                      ),
                                      OutlinedButton.icon(
                                        onPressed: () async {
                                          await Clipboard.setData(
                                            ClipboardData(text: pass.token),
                                          );
                                          if (!context.mounted) {
                                            return;
                                          }
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text('QR token copied.'),
                                            ),
                                          );
                                        },
                                        icon: const Icon(Icons.copy, size: 18),
                                        label: const Text('Copy Token'),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          );

                          if (wide) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(flex: 6, child: walletSection),
                                const SizedBox(width: RitmaSpacing.lg),
                                Expanded(flex: 5, child: qrSection),
                              ],
                            );
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              walletSection,
                              const SizedBox(height: RitmaSpacing.md),
                              qrSection,
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: RitmaSpacing.lg),
              RitmaSectionHeader(
                title: 'Recent Facility Visits',
                subtitle: 'Verified check-ins and checkout timestamps',
                trailing: IconButton(
                  tooltip: 'Refresh visits',
                  onPressed: () => ref.invalidate(memberVisitsProvider),
                  icon: const Icon(Icons.refresh),
                ),
              ),
              const SizedBox(height: RitmaSpacing.sm),
              AsyncStateView<List<FacilityVisitModel>>(
                value: visitsAsync,
                isEmpty: (visits) => visits.isEmpty,
                emptyTitle: 'No gym visits yet',
                emptyMessage: 'Present your rotating QR pass at reception to record a visit.',
                onRetry: () => ref.invalidate(memberVisitsProvider),
                data: (visits) {
                  final timeFmt = DateFormat.MMMd().add_jm();
                  return Column(
                    children: visits
                        .map(
                          (visit) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: RitmaSpacing.xs,
                            ),
                            child: Card(
                              child: ListTile(
                                leading: Icon(
                                  visit.checkInMethod == 'qr'
                                      ? Icons.qr_code_scanner
                                      : Icons.badge_outlined,
                                ),
                                title: Text(
                                  timeFmt.format(visit.checkedInAt.toLocal()),
                                ),
                                subtitle: Text(
                                  visit.checkedOutAt != null
                                      ? 'Checked out at ${DateFormat.jm().format(visit.checkedOutAt!.toLocal())}'
                                      : 'Currently checked in',
                                ),
                                trailing: RitmaStatusPill(
                                  label: visit.checkInMethod.toUpperCase(),
                                  tone: visit.overrideReason != null
                                      ? RitmaPillTone.warning
                                      : RitmaPillTone.success,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
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
