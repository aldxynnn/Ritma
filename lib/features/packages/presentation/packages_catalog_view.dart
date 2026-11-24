import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/ritma_spacing.dart';
import '../../../core/widgets/async_state_view.dart';
import '../../../core/widgets/ritma_page_container.dart';
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

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(orgPackagesProvider),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: RitmaPageContainer(
          maxWidth: 1200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              RitmaSectionHeader(
                title: 'Commercial Packages & Entitlement Rules',
                subtitle: 'Gym memberships, credit-based class packs, PT packs, and hybrid packages remain strictly separated by entitlement kind.',
                trailing: canManagePackages
                    ? FilledButton.icon(
                        onPressed: () => _showCreatePackageDialog(
                          context,
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
                emptyMessage: 'Create a Gym Membership, Studio Class Pack, PT Pack, or Hybrid Package to assign to members.',
                onRetry: () => ref.invalidate(orgPackagesProvider),
                data: (packages) => LayoutBuilder(
                  builder: (context, constraints) {
                    final cols = constraints.maxWidth >= 820 ? 2 : 1;
                    const gap = RitmaSpacing.sm;
                    final cardWidth =
                        (constraints.maxWidth - (cols - 1) * gap) / cols;

                    return Wrap(
                      spacing: gap,
                      runSpacing: gap,
                      children: packages.map((pkg) {
                        return SizedBox(
                          width: cardWidth,
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(RitmaSpacing.md),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Wrap(
                                    alignment: WrapAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
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
                                        tone:
                                            pkg.packageType ==
                                                PackageType.hybrid
                                            ? RitmaPillTone.lime
                                            : RitmaPillTone.neutral,
                                      ),
                                    ],
                                  ),
                                  if (pkg.description.isNotEmpty) ...[
                                    const SizedBox(height: RitmaSpacing.xxs),
                                    Text(
                                      pkg.description,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall,
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
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
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
    String orgId,
  ) async {
    final createdName = await showDialog<String>(
      context: context,
      builder: (_) => _CreatePackageDialog(orgId: orgId),
    );
    if (createdName != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Package "$createdName" created.')),
      );
    }
  }
}

class _CreatePackageDialog extends ConsumerStatefulWidget {
  const _CreatePackageDialog({required this.orgId});

  final String orgId;

  @override
  ConsumerState<_CreatePackageDialog> createState() =>
      _CreatePackageDialogState();
}

class _CreatePackageDialogState extends ConsumerState<_CreatePackageDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController(text: '99.00');
  final _durationCtrl = TextEditingController(text: '30');
  final _creditsCtrl = TextEditingController(text: '8');
  PackageType _pkgType = PackageType.gymMembership;
  BranchAccessScope _branchScope = BranchAccessScope.singleBranch;
  bool _saving = false;
  String? _inlineError;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _durationCtrl.dispose();
    _creditsCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      setState(() => _inlineError = 'Please fix the highlighted fields.');
      return;
    }
    final repo = ref.read(packageEntitlementRepositoryProvider);
    if (repo == null) {
      setState(() => _inlineError = 'Package service unavailable.');
      return;
    }
    setState(() {
      _saving = true;
      _inlineError = null;
    });
    final priceDollars = double.tryParse(_priceCtrl.text.trim()) ?? 0;
    final priceMinor = (priceDollars * 100).round();
    final days = int.tryParse(_durationCtrl.text.trim()) ?? 30;
    final credits = int.tryParse(_creditsCtrl.text.trim()) ?? 1;

    final rules = <CreatePackageRuleInput>[];
    if (_pkgType == PackageType.gymMembership ||
        _pkgType == PackageType.hybrid) {
      rules.add(
        CreatePackageRuleInput(
          entitlementKind: EntitlementKind.facilityAccess,
          durationDays: days,
          branchAccessScope: _branchScope,
        ),
      );
    }
    if (_pkgType == PackageType.classPack || _pkgType == PackageType.hybrid) {
      rules.add(
        CreatePackageRuleInput(
          entitlementKind: EntitlementKind.classCredit,
          durationDays: days,
          creditQuantity: credits > 0 ? credits : 1,
          branchAccessScope: _branchScope,
        ),
      );
    }
    if (_pkgType == PackageType.ptPack) {
      rules.add(
        CreatePackageRuleInput(
          entitlementKind: EntitlementKind.ptCredit,
          durationDays: days,
          creditQuantity: credits > 0 ? credits : 1,
          branchAccessScope: _branchScope,
        ),
      );
    }

    final pkgName = _nameCtrl.text.trim();
    final res = await repo.createPackage(
      orgId: widget.orgId,
      name: pkgName,
      description: _descCtrl.text,
      packageType: _pkgType,
      priceMinor: priceMinor,
      currencyCode: 'USD',
      rules: rules,
    );
    if (!mounted) {
      return;
    }
    setState(() => _saving = false);
    res.when(
      success: (_) {
        ref.invalidate(orgPackagesProvider);
        Navigator.of(context).pop(pkgName);
      },
      failure: (f) => setState(() => _inlineError = f.message),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: const Text('Create Package'),
      content: SizedBox(
        width: 420,
        child: Form(
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
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Package Name'),
                  validator: (v) => (v == null || v.trim().length < 2)
                      ? 'Enter at least 2 characters.'
                      : null,
                ),
                const SizedBox(height: RitmaSpacing.sm),
                TextFormField(
                  controller: _descCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                  ),
                ),
                const SizedBox(height: RitmaSpacing.sm),
                DropdownButtonFormField<PackageType>(
                  initialValue: _pkgType,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Package Type'),
                  items: PackageType.values
                      .map(
                        (t) => DropdownMenuItem(
                          value: t,
                          child: Text(t.label, overflow: TextOverflow.ellipsis),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _pkgType = val);
                    }
                  },
                ),
                const SizedBox(height: RitmaSpacing.sm),
                DropdownButtonFormField<BranchAccessScope>(
                  initialValue: _branchScope,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Branch Access'),
                  items: BranchAccessScope.values
                      .map(
                        (s) => DropdownMenuItem(
                          value: s,
                          child: Text(s.label, overflow: TextOverflow.ellipsis),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _branchScope = val);
                    }
                  },
                ),
                const SizedBox(height: RitmaSpacing.sm),
                TextFormField(
                  controller: _priceCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Price (USD)'),
                  validator: (v) {
                    final p = double.tryParse((v ?? '').trim());
                    return (p == null || p < 0) ? 'Enter a valid price.' : null;
                  },
                ),
                const SizedBox(height: RitmaSpacing.sm),
                TextFormField(
                  controller: _durationCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Duration (days)',
                  ),
                  validator: (v) {
                    final d = int.tryParse((v ?? '').trim());
                    return (d == null || d < 1) ? 'Min 1 day.' : null;
                  },
                ),
                if (_pkgType != PackageType.gymMembership) ...[
                  const SizedBox(height: RitmaSpacing.sm),
                  TextFormField(
                    controller: _creditsCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: _pkgType == PackageType.ptPack
                          ? 'Included PT Credits'
                          : 'Included Class Credits',
                    ),
                    validator: (v) {
                      final c = int.tryParse((v ?? '').trim());
                      return (c == null || c < 1) ? 'Min 1 credit.' : null;
                    },
                  ),
                ],
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
          child: Text(_saving ? 'Creating...' : 'Create'),
        ),
      ],
    );
  }
}
