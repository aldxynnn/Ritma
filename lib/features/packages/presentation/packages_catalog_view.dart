import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/ritma_spacing.dart';
import '../../../core/widgets/async_state_view.dart';
import '../../../core/widgets/ritma_section_header.dart';
import '../../../core/widgets/ritma_status_pill.dart';
import '../../auth/application/auth_providers.dart';
import '../application/package_providers.dart';
import '../domain/package_models.dart';

class PackagesCatalogView extends ConsumerWidget {
  const PackagesCatalogView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspace = ref.watch(activeWorkspaceProvider);
    final packagesAsync = ref.watch(orgPackagesProvider);
    final canManagePackages = ref.watch(
      hasPermissionProvider('package.manage'),
    );

    if (workspace == null) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(RitmaSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RitmaSectionHeader(
            title: 'Commercial Packages & Entitlement Rules',
            subtitle: 'Gym memberships, credit-based class packs, and hybrid packages remain strictly separated by entitlement kind.',
            trailing: canManagePackages
                ? FilledButton.icon(
                    onPressed: () => _showCreatePackageDialog(
                      context,
                      ref,
                      workspace.organizationId,
                    ),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('New Package'),
                  )
                : null,
          ),
          const SizedBox(height: RitmaSpacing.md),
          AsyncStateView<List<PackageModel>>(
            value: packagesAsync,
            isEmpty: (list) => list.isEmpty,
            emptyTitle: 'No packages in catalog',
            emptyMessage: 'Create a Gym Membership, Studio Class Pack, or Hybrid Package to assign to members.',
            onRetry: () => ref.invalidate(orgPackagesProvider),
            data: (packages) => Column(
              children: packages
                  .map(
                    (pkg) => Padding(
                      padding: const EdgeInsets.only(bottom: RitmaSpacing.sm),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(RitmaSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                alignment: WrapAlignment.spaceBetween,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: RitmaSpacing.sm,
                                runSpacing: RitmaSpacing.xs,
                                children: [
                                  Text(
                                    pkg.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium,
                                  ),
                                  RitmaStatusPill(
                                    label: pkg.packageType.label,
                                    tone: pkg.packageType == PackageType.hybrid
                                        ? RitmaPillTone.lime
                                        : RitmaPillTone.neutral,
                                  ),
                                ],
                              ),
                              if (pkg.description.isNotEmpty) ...[
                                const SizedBox(height: RitmaSpacing.xxs),
                                Text(
                                  pkg.description,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                              const SizedBox(height: RitmaSpacing.sm),
                              Wrap(
                                spacing: RitmaSpacing.xs,
                                runSpacing: RitmaSpacing.xs,
                                children: [
                                  RitmaStatusPill(
                                    label:
                                        '${pkg.currencyCode} ${(pkg.priceMinor / 100).toStringAsFixed(2)}',
                                    icon: Icons.payments_outlined,
                                  ),
                                  ...pkg.rules.map(
                                    (r) => RitmaStatusPill(
                                      label: _formatRule(r),
                                      tone:
                                          r.entitlementKind ==
                                              EntitlementKind.facilityAccess
                                          ? RitmaPillTone.success
                                          : RitmaPillTone.lime,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _formatRule(PackageEntitlementRuleModel rule) {
    final scope = rule.branchAccessScope.label;
    return switch (rule.entitlementKind) {
      EntitlementKind.facilityAccess =>
        'Gym Entry • ${rule.durationDays ?? 30}d ($scope)',
      EntitlementKind.classCredit =>
        '${rule.creditQuantity ?? 0} Class Credits • ${rule.durationDays ?? 90}d ($scope)',
      EntitlementKind.ptCredit =>
        '${rule.creditQuantity ?? 0} PT Credits • ${rule.durationDays ?? 90}d ($scope)',
      EntitlementKind.unlimitedClass =>
        'Unlimited Classes • ${rule.durationDays ?? 30}d ($scope)',
    };
  }

  Future<void> _showCreatePackageDialog(
    BuildContext context,
    WidgetRef ref,
    String orgId,
  ) async {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final priceCtrl = TextEditingController(text: '99.00');
    final durationCtrl = TextEditingController(text: '30');
    final creditsCtrl = TextEditingController(text: '8');
    var pkgType = PackageType.gymMembership;
    var branchScope = BranchAccessScope.singleBranch;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setInnerState) => AlertDialog(
          title: const Text('Create Package'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Package Name'),
                ),
                const SizedBox(height: RitmaSpacing.sm),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: RitmaSpacing.sm),
                DropdownButtonFormField<PackageType>(
                  initialValue: pkgType,
                  decoration: const InputDecoration(labelText: 'Package Type'),
                  items:
                      const [
                            PackageType.gymMembership,
                            PackageType.classPack,
                            PackageType.hybrid,
                          ]
                          .map(
                            (t) => DropdownMenuItem(
                              value: t,
                              child: Text(t.label),
                            ),
                          )
                          .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setInnerState(() => pkgType = val);
                    }
                  },
                ),
                const SizedBox(height: RitmaSpacing.sm),
                DropdownButtonFormField<BranchAccessScope>(
                  initialValue: branchScope,
                  decoration: const InputDecoration(labelText: 'Branch Access'),
                  items: BranchAccessScope.values
                      .map(
                        (s) => DropdownMenuItem(value: s, child: Text(s.label)),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setInnerState(() => branchScope = val);
                    }
                  },
                ),
                const SizedBox(height: RitmaSpacing.sm),
                TextField(
                  controller: priceCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Price (USD)'),
                ),
                const SizedBox(height: RitmaSpacing.sm),
                TextField(
                  controller: durationCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Duration (days)',
                  ),
                ),
                if (pkgType != PackageType.gymMembership) ...[
                  const SizedBox(height: RitmaSpacing.sm),
                  TextField(
                    controller: creditsCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Included Class Credits',
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final repo = ref.read(packageEntitlementRepositoryProvider);
                if (repo == null || nameCtrl.text.trim().length < 2) {
                  return;
                }
                final priceDollars =
                    double.tryParse(priceCtrl.text.trim()) ?? 0;
                final priceMinor = (priceDollars * 100).round();
                final days = int.tryParse(durationCtrl.text.trim()) ?? 30;
                final credits = int.tryParse(creditsCtrl.text.trim()) ?? 0;

                final rules = <CreatePackageRuleInput>[];
                if (pkgType == PackageType.gymMembership ||
                    pkgType == PackageType.hybrid) {
                  rules.add(
                    CreatePackageRuleInput(
                      entitlementKind: EntitlementKind.facilityAccess,
                      durationDays: days,
                      branchAccessScope: branchScope,
                    ),
                  );
                }
                if (pkgType == PackageType.classPack ||
                    pkgType == PackageType.hybrid) {
                  rules.add(
                    CreatePackageRuleInput(
                      entitlementKind: EntitlementKind.classCredit,
                      durationDays: days,
                      creditQuantity: credits > 0 ? credits : 1,
                      branchAccessScope: branchScope,
                    ),
                  );
                }

                final res = await repo.createPackage(
                  orgId: orgId,
                  name: nameCtrl.text,
                  description: descCtrl.text,
                  packageType: pkgType,
                  priceMinor: priceMinor,
                  currencyCode: 'USD',
                  rules: rules,
                );
                if (!dialogContext.mounted) {
                  return;
                }
                res.when(
                  success: (_) {
                    ref.invalidate(orgPackagesProvider);
                    Navigator.of(dialogContext).pop();
                  },
                  failure: (f) =>
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(f.message))),
                );
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}
