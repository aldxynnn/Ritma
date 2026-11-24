import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/ritma_spacing.dart';
import '../../../core/widgets/async_state_view.dart';
import '../../auth/application/auth_providers.dart';
import '../../dashboard/application/dashboard_providers.dart';
import '../../organizations/application/organization_providers.dart';
import '../../organizations/domain/branch_model.dart';
import '../../payments/application/payment_providers.dart';
import '../application/package_providers.dart';
import '../domain/package_models.dart';

class AssignPackageSheet extends ConsumerStatefulWidget {
  const AssignPackageSheet({
    required this.memberId,
    required this.memberName,
    required this.homeBranchId,
    super.key,
  });

  final String memberId;
  final String memberName;
  final String homeBranchId;

  @override
  ConsumerState<AssignPackageSheet> createState() => _AssignPackageSheetState();
}

class _AssignPackageSheetState extends ConsumerState<AssignPackageSheet> {
  final String _idempotencyKey = const Uuid().v4();
  String? _selectedPackageId;
  String? _selectedBranchId;
  PaymentMethod _paymentMethod = PaymentMethod.cash;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selectedBranchId = widget.homeBranchId;
  }

  Future<void> _submit() async {
    final workspace = ref.read(activeWorkspaceProvider);
    final repo = ref.read(packageEntitlementRepositoryProvider);
    final pkgId = _selectedPackageId;
    final branchId = _selectedBranchId ?? widget.homeBranchId;
    if (workspace == null || repo == null || pkgId == null) {
      setState(() => _error = 'Select a package to assign.');
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    final result = await repo.assignPackageToMember(
      orgId: workspace.organizationId,
      branchId: branchId,
      memberId: widget.memberId,
      packageId: pkgId,
      paymentMethod: _paymentMethod,
      idempotencyKey: _idempotencyKey,
    );

    if (!mounted) {
      return;
    }

    result.when(
      success: (_) {
        ref.invalidate(memberWalletProvider(widget.memberId));
        ref.invalidate(orgPaymentsProvider);
        ref.invalidate(operationalMetricsProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Package provisioned for ${widget.memberName}.'),
          ),
        );
        Navigator.of(context).pop(true);
      },
      failure: (failure) {
        setState(() {
          _submitting = false;
          _error = failure.message;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final packagesAsync = ref.watch(orgPackagesProvider);
    final branchesAsync = ref.watch(orgBranchesProvider);
    final workspace = ref.watch(activeWorkspaceProvider);

    return Padding(
      padding: EdgeInsets.only(
        left: RitmaSpacing.lg,
        right: RitmaSpacing.lg,
        top: RitmaSpacing.lg,
        bottom: MediaQuery.viewInsetsOf(context).bottom + RitmaSpacing.lg,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Assign Package to ${widget.memberName}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: RitmaSpacing.xs),
            Text(
              'Records payment idempotently and provisions separated entitlements or credit grants.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: RitmaSpacing.md),
            if (_error != null) ...[
              Text(
                _error!,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: Theme.of(context).colorScheme.error),
              ),
              const SizedBox(height: RitmaSpacing.sm),
            ],
            AsyncStateView<List<PackageModel>>(
              value: packagesAsync,
              isEmpty: (list) => list.isEmpty,
              emptyTitle: 'No packages available',
              data: (packages) {
                _selectedPackageId ??= packages.first.id;
                return DropdownButtonFormField<String>(
                  initialValue: _selectedPackageId,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Package'),
                  items: packages
                      .map(
                        (p) => DropdownMenuItem(
                          value: p.id,
                          child: Text(
                            '${p.name} (${p.packageType.label})',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => _selectedPackageId = val),
                );
              },
            ),
            const SizedBox(height: RitmaSpacing.sm),
            AsyncStateView<List<BranchModel>>(
              value: branchesAsync,
              data: (branches) {
                if (branches.isEmpty) {
                  return const SizedBox.shrink();
                }
                final isBranchLocked = workspace?.branchId != null;
                final currentBranch = isBranchLocked
                    ? workspace!.branchId!
                    : (_selectedBranchId ?? branches.first.id);
                _selectedBranchId = currentBranch;
                return DropdownButtonFormField<String>(
                  initialValue: currentBranch,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Assigned Branch',
                  ),
                  items: branches
                      .map(
                        (b) => DropdownMenuItem(
                          value: b.id,
                          child: Text(b.name, overflow: TextOverflow.ellipsis),
                        ),
                      )
                      .toList(),
                  onChanged: isBranchLocked
                      ? null
                      : (val) => setState(() => _selectedBranchId = val),
                );
              },
            ),
            const SizedBox(height: RitmaSpacing.sm),
            DropdownButtonFormField<PaymentMethod>(
              initialValue: _paymentMethod,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Payment Method'),
              items:
                  const [
                        PaymentMethod.cash,
                        PaymentMethod.bankTransfer,
                        PaymentMethod.cardTerminal,
                      ]
                      .map(
                        (m) => DropdownMenuItem(
                          value: m,
                          child: Text(m.label, overflow: TextOverflow.ellipsis),
                        ),
                      )
                      .toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _paymentMethod = val);
                }
              },
            ),
            const SizedBox(height: RitmaSpacing.md),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Confirm & Provision Entitlements'),
            ),
          ],
        ),
      ),
    );
  }
}
