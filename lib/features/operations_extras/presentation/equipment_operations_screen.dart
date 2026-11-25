import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/state/ritma_sync.dart';
import '../../../core/theme/ritma_spacing.dart';
import '../../../core/widgets/async_state_view.dart';
import '../../../core/widgets/ritma_page_container.dart';
import '../../../core/widgets/ritma_section_header.dart';
import '../../../core/widgets/ritma_status_pill.dart';
import '../../auth/application/auth_providers.dart';
import '../../organizations/application/organization_providers.dart';
import '../../organizations/domain/branch_model.dart';
import '../application/operations_extras_providers.dart';
import '../domain/operations_extras_models.dart';

class EquipmentOperationsScreen extends ConsumerWidget {
  const EquipmentOperationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspace = ref.watch(activeWorkspaceProvider);
    final assetsAsync = ref.watch(equipmentAssetsProvider);
    final ticketsAsync = ref.watch(maintenanceTicketsProvider);
    final branches =
        ref.watch(orgBranchesProvider).asData?.value ?? const <BranchModel>[];
    final assets = assetsAsync.asData?.value ?? const <EquipmentAssetModel>[];

    if (workspace == null) {
      return const Scaffold(body: SizedBox.shrink());
    }

    final assetMap = <String, EquipmentAssetModel>{
      for (final a in assets) a.id: a,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Equipment & Maintenance'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => RitmaSync.afterEquipmentMutation(ref),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: RitmaPageContainer(
          maxWidth: 960,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              RitmaSectionHeader(
                title: 'Equipment Assets',
                subtitle: 'Branch-scoped machines, rigs, and reformers',
                trailing: FilledButton.icon(
                  onPressed: () async {
                    final added = await showDialog<bool>(
                      context: context,
                      builder: (_) => _CreateAssetDialog(branches: branches),
                    );
                    if (added == true) {
                      RitmaSync.afterEquipmentMutation(ref);
                    }
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Asset'),
                ),
              ),
              const SizedBox(height: RitmaSpacing.sm),
              AsyncStateView<List<EquipmentAssetModel>>(
                value: assetsAsync,
                isEmpty: (list) => list.isEmpty,
                emptyTitle: 'No equipment assets registered',
                emptyMessage:
                    'Add machines or studio rigs to track service state.',
                onRetry: () => ref.invalidate(equipmentAssetsProvider),
                data: (list) => Column(
                  children: list.map((asset) {
                    final tone = switch (asset.status) {
                      EquipmentStatus.operational => RitmaPillTone.success,
                      EquipmentStatus.needsService => RitmaPillTone.warning,
                      EquipmentStatus.outOfOrder => RitmaPillTone.danger,
                      EquipmentStatus.retired => RitmaPillTone.neutral,
                    };
                    return Padding(
                      padding: const EdgeInsets.only(bottom: RitmaSpacing.xs),
                      child: Card(
                        child: ListTile(
                          title: Text('${asset.name} (${asset.assetCode})'),
                          subtitle: Text(asset.category),
                          trailing: Wrap(
                            spacing: RitmaSpacing.xs,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              RitmaStatusPill(
                                label: asset.status.displayLabel,
                                tone: tone,
                              ),
                              PopupMenuButton<EquipmentStatus>(
                                tooltip: 'Change asset status',
                                onSelected: (next) async {
                                  final repo = ref.read(
                                    operationsExtrasRepositoryProvider,
                                  );
                                  if (repo == null) return;
                                  final res = await repo.updateEquipmentStatus(
                                    orgId: workspace.organizationId,
                                    assetId: asset.id,
                                    status: next,
                                  );
                                  if (!context.mounted) return;
                                  res.when(
                                    success: (_) =>
                                        ref.invalidate(equipmentAssetsProvider),
                                    failure: (f) =>
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(content: Text(f.message)),
                                        ),
                                  );
                                },
                                itemBuilder: (_) => EquipmentStatus.values
                                    .map(
                                      (s) => PopupMenuItem<EquipmentStatus>(
                                        value: s,
                                        child: Text(s.displayLabel),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: RitmaSpacing.lg),
              RitmaSectionHeader(
                title: 'Maintenance Tickets',
                subtitle: 'Open equipment defects and repair tracking',
                trailing: OutlinedButton.icon(
                  onPressed: assets.isEmpty
                      ? null
                      : () async {
                          final added = await showDialog<bool>(
                            context: context,
                            builder: (_) => _CreateTicketDialog(assets: assets),
                          );
                          if (added == true) {
                            RitmaSync.afterEquipmentMutation(ref);
                          }
                        },
                  icon: const Icon(Icons.build_outlined, size: 18),
                  label: const Text('Log Ticket'),
                ),
              ),
              const SizedBox(height: RitmaSpacing.sm),
              AsyncStateView<List<MaintenanceTicketModel>>(
                value: ticketsAsync,
                isEmpty: (list) => list.isEmpty,
                emptyTitle: 'No maintenance tickets',
                emptyMessage: 'Everything in this scope is running smoothly.',
                onRetry: () => ref.invalidate(maintenanceTicketsProvider),
                data: (tickets) {
                  final fmt = DateFormat.MMMd().add_jm();
                  return Column(
                    children: tickets.map((t) {
                      final asset = assetMap[t.assetId];
                      final tone = switch (t.status) {
                        TicketStatus.open => RitmaPillTone.warning,
                        TicketStatus.inProgress => RitmaPillTone.lime,
                        TicketStatus.resolved => RitmaPillTone.success,
                        TicketStatus.closed => RitmaPillTone.neutral,
                      };
                      return Padding(
                        padding: const EdgeInsets.only(bottom: RitmaSpacing.xs),
                        child: Card(
                          child: ListTile(
                            title: Text(t.summary),
                            subtitle: Text(
                              '${asset?.assetCode ?? 'Asset'} • ${t.priority.displayLabel} priority • ${fmt.format(t.createdAt.toLocal())}',
                            ),
                            trailing: Wrap(
                              spacing: RitmaSpacing.xs,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                RitmaStatusPill(
                                  label: t.status.displayLabel,
                                  tone: tone,
                                ),
                                PopupMenuButton<TicketStatus>(
                                  tooltip: 'Update ticket status',
                                  onSelected: (next) async {
                                    final repo = ref.read(
                                      operationsExtrasRepositoryProvider,
                                    );
                                    if (repo == null) return;
                                    final res = await repo.updateTicketStatus(
                                      orgId: workspace.organizationId,
                                      ticketId: t.id,
                                      status: next,
                                    );
                                    if (!context.mounted) return;
                                    res.when(
                                      success: (_) =>
                                          RitmaSync.afterEquipmentMutation(ref),
                                      failure: (f) =>
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(content: Text(f.message)),
                                          ),
                                    );
                                  },
                                  itemBuilder: (_) => TicketStatus.values
                                      .map(
                                        (s) => PopupMenuItem<TicketStatus>(
                                          value: s,
                                          child: Text(s.displayLabel),
                                        ),
                                      )
                                      .toList(),
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
            ],
          ),
        ),
      ),
    );
  }
}

class _CreateAssetDialog extends ConsumerStatefulWidget {
  const _CreateAssetDialog({required this.branches});

  final List<BranchModel> branches;

  @override
  ConsumerState<_CreateAssetDialog> createState() => _CreateAssetDialogState();
}

class _CreateAssetDialogState extends ConsumerState<_CreateAssetDialog> {
  final _formKey = GlobalKey<FormState>();
  final _codeCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _catCtrl = TextEditingController(text: 'Strength');
  String? _branchId;
  bool _saving = false;
  String? _inlineError;

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    _catCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workspace = ref.watch(activeWorkspaceProvider);
    _branchId ??= workspace?.branchId ?? widget.branches.firstOrNull?.id;

    return AlertDialog(
      title: const Text('Register Equipment Asset'),
      content: SizedBox(
        width: 400,
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
                if (workspace?.branchId == null &&
                    widget.branches.isNotEmpty) ...[
                  DropdownButtonFormField<String>(
                    initialValue: _branchId,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Branch'),
                    items: widget.branches
                        .map(
                          (b) => DropdownMenuItem<String>(
                            value: b.id,
                            child: Text(
                              b.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _branchId = v),
                  ),
                  const SizedBox(height: RitmaSpacing.xs),
                ],
                TextFormField(
                  controller: _codeCtrl,
                  decoration: const InputDecoration(labelText: 'Asset Code'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: RitmaSpacing.xs),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Equipment Name',
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: RitmaSpacing.xs),
                TextFormField(
                  controller: _catCtrl,
                  decoration: const InputDecoration(labelText: 'Category'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
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
          onPressed: _saving
              ? null
              : () async {
                  if (!(_formKey.currentState?.validate() ?? false)) {
                    setState(
                      () => _inlineError = 'Fix the highlighted fields.',
                    );
                    return;
                  }
                  final repo = ref.read(operationsExtrasRepositoryProvider);
                  if (repo == null || workspace == null || _branchId == null) {
                    setState(() => _inlineError = 'Select a branch first.');
                    return;
                  }
                  setState(() {
                    _saving = true;
                    _inlineError = null;
                  });
                  final res = await repo.createEquipmentAsset(
                    orgId: workspace.organizationId,
                    branchId: _branchId!,
                    assetCode: _codeCtrl.text,
                    name: _nameCtrl.text,
                    category: _catCtrl.text,
                  );
                  if (!context.mounted) return;
                  setState(() => _saving = false);
                  res.when(
                    success: (_) => Navigator.of(context).pop(true),
                    failure: (f) => setState(() => _inlineError = f.message),
                  );
                },
          child: Text(_saving ? 'Saving...' : 'Add Asset'),
        ),
      ],
    );
  }
}

class _CreateTicketDialog extends ConsumerStatefulWidget {
  const _CreateTicketDialog({required this.assets});

  final List<EquipmentAssetModel> assets;

  @override
  ConsumerState<_CreateTicketDialog> createState() =>
      _CreateTicketDialogState();
}

class _CreateTicketDialogState extends ConsumerState<_CreateTicketDialog> {
  final _formKey = GlobalKey<FormState>();
  final _summaryCtrl = TextEditingController();
  String? _assetId;
  TicketPriority _priority = TicketPriority.normal;
  bool _saving = false;
  String? _inlineError;

  @override
  void dispose() {
    _summaryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _assetId ??= widget.assets.firstOrNull?.id;
    return AlertDialog(
      title: const Text('Log Maintenance Ticket'),
      content: SizedBox(
        width: 400,
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
                DropdownButtonFormField<String>(
                  initialValue: _assetId,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Equipment Asset',
                  ),
                  items: widget.assets
                      .map(
                        (a) => DropdownMenuItem<String>(
                          value: a.id,
                          child: Text(
                            '${a.assetCode} — ${a.name}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _assetId = v),
                ),
                const SizedBox(height: RitmaSpacing.xs),
                DropdownButtonFormField<TicketPriority>(
                  initialValue: _priority,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Priority'),
                  items: TicketPriority.values
                      .map(
                        (p) => DropdownMenuItem<TicketPriority>(
                          value: p,
                          child: Text(
                            p.displayLabel,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _priority = v);
                  },
                ),
                const SizedBox(height: RitmaSpacing.xs),
                TextFormField(
                  controller: _summaryCtrl,
                  decoration: const InputDecoration(labelText: 'Issue Summary'),
                  maxLines: 2,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
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
          onPressed: _saving
              ? null
              : () async {
                  if (!(_formKey.currentState?.validate() ?? false)) {
                    setState(
                      () => _inlineError = 'Fix the highlighted fields.',
                    );
                    return;
                  }
                  final workspace = ref.read(activeWorkspaceProvider);
                  final repo = ref.read(operationsExtrasRepositoryProvider);
                  final asset = widget.assets
                      .where((a) => a.id == _assetId)
                      .firstOrNull;
                  if (workspace == null || repo == null || asset == null) {
                    setState(() => _inlineError = 'Select an equipment asset.');
                    return;
                  }
                  setState(() {
                    _saving = true;
                    _inlineError = null;
                  });
                  final res = await repo.createMaintenanceTicket(
                    orgId: workspace.organizationId,
                    branchId: asset.branchId,
                    assetId: asset.id,
                    summary: _summaryCtrl.text,
                    priority: _priority,
                  );
                  if (!context.mounted) return;
                  setState(() => _saving = false);
                  res.when(
                    success: (_) => Navigator.of(context).pop(true),
                    failure: (f) => setState(() => _inlineError = f.message),
                  );
                },
          child: Text(_saving ? 'Submitting...' : 'Log Ticket'),
        ),
      ],
    );
  }
}
