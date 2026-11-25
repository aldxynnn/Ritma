import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/state/ritma_sync.dart';
import '../../../core/theme/ritma_spacing.dart';
import '../../../core/utils/ritma_timezone.dart';
import '../../../core/widgets/async_state_view.dart';
import '../../../core/widgets/ritma_page_container.dart';
import '../../../core/widgets/ritma_section_header.dart';
import '../../../core/widgets/ritma_status_pill.dart';
import '../../auth/application/auth_providers.dart';
import '../../organizations/application/organization_providers.dart';
import '../../organizations/domain/branch_model.dart';
import '../application/package_providers.dart';
import '../domain/package_models.dart';

class PackagesCatalogView extends ConsumerStatefulWidget {
  const PackagesCatalogView({super.key});

  @override
  ConsumerState<PackagesCatalogView> createState() =>
      _PackagesCatalogViewState();
}

class _PackagesCatalogViewState extends ConsumerState<PackagesCatalogView> {
  bool _showArchived = false;

  @override
  Widget build(BuildContext context) {
    final workspace = ref.watch(activeWorkspaceProvider);
    final packagesAsync = ref.watch(orgPackagesProvider);
    final branches =
        ref.watch(orgBranchesProvider).asData?.value ?? const <BranchModel>[];
    final org = ref.watch(activeOrganizationProvider).asData?.value;
    final canManagePackages = ref.watch(
      hasPermissionProvider('package.manage'),
    );
    final branchNames = <String, String>{
      for (final b in branches) b.id: b.name,
    };

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
                          org?.currencyCode ?? 'USD',
                        ),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('New Package'),
                      )
                    : null,
              ),
              const SizedBox(height: RitmaSpacing.xs),
              if (canManagePackages)
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilterChip(
                    selected: _showArchived,
                    label: const Text('Show Archived Packages'),
                    onSelected: (v) => setState(() => _showArchived = v),
                  ),
                ),
              const SizedBox(height: RitmaSpacing.md),
              AsyncStateView<List<PackageModel>>(
                value: packagesAsync,
                isEmpty: (list) =>
                    list.where((p) => _showArchived || p.isActive).isEmpty,
                emptyTitle: 'No packages in catalog',
                emptyMessage: 'Create a Gym Membership, Studio Class Pack, PT Pack, or Hybrid Package to assign to members.',
                onRetry: () => ref.invalidate(orgPackagesProvider),
                data: (packages) {
                  final visible = packages
                      .where((p) => _showArchived || p.isActive)
                      .toList();
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final cols = constraints.maxWidth >= 820 ? 2 : 1;
                      const gap = RitmaSpacing.sm;
                      final cardWidth =
                          (constraints.maxWidth - (cols - 1) * gap) / cols;

                      return Wrap(
                        spacing: gap,
                        runSpacing: gap,
                        children: visible.map((pkg) {
                          return SizedBox(
                            width: cardWidth,
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(RitmaSpacing.md),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
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
                                        Wrap(
                                          spacing: RitmaSpacing.xs,
                                          children: [
                                            if (!pkg.isActive)
                                              const RitmaStatusPill(
                                                label: 'Archived',
                                                tone: RitmaPillTone.warning,
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
                                          label: RitmaTimezone.formatMoney(
                                            pkg.priceMinor,
                                            pkg.currencyCode,
                                          ),
                                          icon: Icons.payments_outlined,
                                        ),
                                        ...pkg.rules.map(
                                          (r) => RitmaStatusPill(
                                            label: _formatRule(r, branchNames),
                                            tone:
                                                r.entitlementKind ==
                                                    EntitlementKind
                                                        .facilityAccess
                                                ? RitmaPillTone.success
                                                : RitmaPillTone.lime,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (canManagePackages) ...[
                                      const SizedBox(height: RitmaSpacing.sm),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: OutlinedButton.icon(
                                          onPressed: () =>
                                              _showEditPackageDialog(
                                                context,
                                                workspace.organizationId,
                                                pkg,
                                              ),
                                          icon: const Icon(
                                            Icons.edit_outlined,
                                            size: 16,
                                          ),
                                          label: const Text('Edit / Branches'),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatRule(
    PackageEntitlementRuleModel rule,
    Map<String, String> branchNames,
  ) {
    var scope = rule.branchAccessScope.label;
    if (rule.branchAccessScope == BranchAccessScope.selectedBranches) {
      if (rule.allowedBranchIds.isEmpty) {
        scope = 'Selected Branches (None configured)';
      } else {
        final names = rule.allowedBranchIds
            .map((id) => branchNames[id] ?? 'Branch')
            .join(', ');
        scope = 'Branches: $names';
      }
    }
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
    String currencyCode,
  ) async {
    final createdName = await showDialog<String>(
      context: context,
      builder: (_) =>
          _CreatePackageDialog(orgId: orgId, currencyCode: currencyCode),
    );
    if (createdName != null && context.mounted) {
      RitmaSync.afterPackageOrPaymentMutation(ref);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Package "$createdName" created.')),
      );
    }
  }

  Future<void> _showEditPackageDialog(
    BuildContext context,
    String orgId,
    PackageModel pkg,
  ) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => _EditPackageDialog(orgId: orgId, package: pkg),
    );
    if (saved == true && context.mounted) {
      RitmaSync.afterPackageOrPaymentMutation(ref);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Package "${pkg.name}" updated.')));
    }
  }
}

class _CreatePackageDialog extends ConsumerStatefulWidget {
  const _CreatePackageDialog({required this.orgId, required this.currencyCode});

  final String orgId;
  final String currencyCode;

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
  final _hybridPtCreditsCtrl = TextEditingController(text: '0');
  PackageType _pkgType = PackageType.gymMembership;
  BranchAccessScope _branchScope = BranchAccessScope.singleBranch;
  final Set<String> _selectedBranchIds = <String>{};
  bool _saving = false;
  String? _inlineError;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _durationCtrl.dispose();
    _creditsCtrl.dispose();
    _hybridPtCreditsCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      setState(() => _inlineError = 'Please fix the highlighted fields.');
      return;
    }
    if (_branchScope == BranchAccessScope.selectedBranches &&
        _selectedBranchIds.isEmpty) {
      setState(
        () => _inlineError =
            'Select at least one branch for Selected Branches access.',
      );
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
    final hybridPtCredits = int.tryParse(_hybridPtCreditsCtrl.text.trim()) ?? 0;
    final allowedBranches = _branchScope == BranchAccessScope.selectedBranches
        ? _selectedBranchIds.toList()
        : const <String>[];

    final rules = <CreatePackageRuleInput>[];
    if (_pkgType == PackageType.gymMembership ||
        _pkgType == PackageType.hybrid) {
      rules.add(
        CreatePackageRuleInput(
          entitlementKind: EntitlementKind.facilityAccess,
          durationDays: days,
          branchAccessScope: _branchScope,
          allowedBranchIds: allowedBranches,
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
          allowedBranchIds: allowedBranches,
        ),
      );
    }
    if (_pkgType == PackageType.hybrid && hybridPtCredits > 0) {
      rules.add(
        CreatePackageRuleInput(
          entitlementKind: EntitlementKind.ptCredit,
          durationDays: days,
          creditQuantity: hybridPtCredits,
          branchAccessScope: _branchScope,
          allowedBranchIds: allowedBranches,
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
          allowedBranchIds: allowedBranches,
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
      currencyCode: widget.currencyCode,
      rules: rules,
    );
    if (!mounted) {
      return;
    }
    setState(() => _saving = false);
    res.when(
      success: (_) {
        RitmaSync.afterPackageOrPaymentMutation(ref);
        Navigator.of(context).pop(pkgName);
      },
      failure: (f) => setState(() => _inlineError = f.message),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final branches =
        ref.watch(orgBranchesProvider).asData?.value ?? const <BranchModel>[];

    return AlertDialog(
      title: const Text('Create Package'),
      content: SizedBox(
        width: 440,
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
                      setState(() {
                        _branchScope = val;
                        if (val == BranchAccessScope.selectedBranches &&
                            _selectedBranchIds.isEmpty &&
                            branches.isNotEmpty) {
                          _selectedBranchIds.add(branches.first.id);
                        }
                      });
                    }
                  },
                ),
                if (_branchScope == BranchAccessScope.selectedBranches) ...[
                  const SizedBox(height: RitmaSpacing.xs),
                  Text(
                    'Allowed Branches (select at least one)',
                    style: theme.textTheme.labelMedium,
                  ),
                  const SizedBox(height: RitmaSpacing.xxs),
                  if (branches.isEmpty)
                    Text(
                      'No branches available yet.',
                      style: theme.textTheme.bodySmall,
                    )
                  else
                    ...branches.map(
                      (b) => CheckboxListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        value: _selectedBranchIds.contains(b.id),
                        title: Text('${b.name} (${b.code})'),
                        onChanged: (checked) {
                          setState(() {
                            if (checked == true) {
                              _selectedBranchIds.add(b.id);
                            } else {
                              _selectedBranchIds.remove(b.id);
                            }
                          });
                        },
                      ),
                    ),
                ],
                const SizedBox(height: RitmaSpacing.sm),
                TextFormField(
                  controller: _priceCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Price (${widget.currencyCode})',
                  ),
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
                if (_pkgType == PackageType.hybrid) ...[
                  const SizedBox(height: RitmaSpacing.sm),
                  TextFormField(
                    controller: _hybridPtCreditsCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Bonus PT Credits (optional)',
                    ),
                    validator: (v) {
                      final c = int.tryParse((v ?? '').trim());
                      return (c == null || c < 0) ? 'Min 0.' : null;
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

class _EditPackageDialog extends ConsumerStatefulWidget {
  const _EditPackageDialog({required this.orgId, required this.package});

  final String orgId;
  final PackageModel package;

  @override
  ConsumerState<_EditPackageDialog> createState() => _EditPackageDialogState();
}

class _EditPackageDialogState extends ConsumerState<_EditPackageDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _priceCtrl;
  late bool _isActive;
  late BranchAccessScope _branchScope;
  late final Set<String> _selectedBranchIds;
  bool _saving = false;
  String? _inlineError;

  @override
  void initState() {
    super.initState();
    final p = widget.package;
    _nameCtrl = TextEditingController(text: p.name);
    _descCtrl = TextEditingController(text: p.description);
    _priceCtrl = TextEditingController(
      text: (p.priceMinor / 100.0).toStringAsFixed(2),
    );
    _isActive = p.isActive;
    final firstRule = p.rules.firstOrNull;
    _branchScope =
        firstRule?.branchAccessScope ?? BranchAccessScope.singleBranch;
    _selectedBranchIds = <String>{...?firstRule?.allowedBranchIds};
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_branchScope == BranchAccessScope.selectedBranches &&
        _selectedBranchIds.isEmpty) {
      setState(() => _inlineError = 'Select at least one allowed branch.');
      return;
    }
    final repo = ref.read(packageEntitlementRepositoryProvider);
    if (repo == null) return;
    final priceMinor = ((double.tryParse(_priceCtrl.text.trim()) ?? 0) * 100)
        .round();
    setState(() {
      _saving = true;
      _inlineError = null;
    });
    final res = await repo.updatePackageDetails(
      orgId: widget.orgId,
      packageId: widget.package.id,
      name: _nameCtrl.text,
      description: _descCtrl.text,
      priceMinor: priceMinor,
      isActive: _isActive,
      branchAccessScope: _branchScope,
      allowedBranchIds: _branchScope == BranchAccessScope.selectedBranches
          ? _selectedBranchIds.toList()
          : null,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    res.when(
      success: (_) => Navigator.of(context).pop(true),
      failure: (f) => setState(() => _inlineError = f.message),
    );
  }

  @override
  Widget build(BuildContext context) {
    final branches =
        ref.watch(orgBranchesProvider).asData?.value ?? const <BranchModel>[];
    return AlertDialog(
      title: const Text('Edit Package & Branch Rules'),
      content: SizedBox(
        width: 440,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_inlineError != null) ...[
                  Text(
                    _inlineError!,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: Theme.of(context).colorScheme.error),
                  ),
                  const SizedBox(height: RitmaSpacing.sm),
                ],
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Package Name'),
                  validator: (v) => (v == null || v.trim().length < 2)
                      ? 'Min 2 characters.'
                      : null,
                ),
                const SizedBox(height: RitmaSpacing.sm),
                TextFormField(
                  controller: _descCtrl,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: RitmaSpacing.sm),
                TextFormField(
                  controller: _priceCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Price (${widget.package.currencyCode})',
                  ),
                ),
                const SizedBox(height: RitmaSpacing.sm),
                DropdownButtonFormField<BranchAccessScope>(
                  initialValue: _branchScope,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Branch Access'),
                  items: BranchAccessScope.values
                      .map(
                        (s) => DropdownMenuItem(value: s, child: Text(s.label)),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _branchScope = val);
                  },
                ),
                if (_branchScope == BranchAccessScope.selectedBranches)
                  ...branches.map(
                    (b) => CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      value: _selectedBranchIds.contains(b.id),
                      title: Text('${b.name} (${b.code})'),
                      onChanged: (checked) => setState(() {
                        if (checked == true) {
                          _selectedBranchIds.add(b.id);
                        } else {
                          _selectedBranchIds.remove(b.id);
                        }
                      }),
                    ),
                  ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _isActive,
                  onChanged: (v) => setState(() => _isActive = v),
                  title: const Text('Active in Catalog'),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _submit,
          child: Text(_saving ? 'Saving...' : 'Save Changes'),
        ),
      ],
    );
  }
}
