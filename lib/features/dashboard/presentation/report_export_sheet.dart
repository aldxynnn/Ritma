import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/export/csv_exporter.dart';
import '../../../core/theme/ritma_spacing.dart';
import '../../auth/application/auth_providers.dart';
import '../application/dashboard_providers.dart';
import '../domain/report_export_model.dart';

/// Permission- and branch-scoped CSV report export sheet.
class ReportExportSheet extends ConsumerStatefulWidget {
  const ReportExportSheet({super.key, this.branchId});

  final String? branchId;

  @override
  ConsumerState<ReportExportSheet> createState() => _ReportExportSheetState();
}

class _ReportExportSheetState extends ConsumerState<ReportExportSheet> {
  ReportExportType? _selectedType;
  int _windowDays = 30;
  bool _exporting = false;
  String? _error;
  CsvExportOutcome? _lastOutcome;
  int? _lastRowCount;

  List<ReportExportType> _allowedTypes() {
    final canVisits = ref.read(hasPermissionProvider('checkin.read'));
    final canPayments = ref.read(hasPermissionProvider('payment.read'));
    final canMembers = ref.read(hasPermissionProvider('member.read'));
    final canAttendance = ref.read(hasPermissionProvider('booking.read'));

    return <ReportExportType>[
      if (canVisits) ReportExportType.visits,
      if (canPayments) ReportExportType.payments,
      if (canMembers) ReportExportType.members,
      if (canAttendance) ReportExportType.attendance,
    ];
  }

  Future<void> _runExport(ReportExportType type) async {
    final workspace = ref.read(activeWorkspaceProvider);
    final repo = ref.read(dashboardRepositoryProvider);
    if (workspace == null || repo == null) {
      setState(() => _error = 'Export service is unavailable.');
      return;
    }

    final scopedBranch =
        workspace.branchId ??
        widget.branchId ??
        ref.read(dashboardBranchFilterProvider);

    setState(() {
      _exporting = true;
      _error = null;
    });

    final res = await repo.fetchReportExport(
      orgId: workspace.organizationId,
      reportType: type,
      branchId: scopedBranch,
      windowDays: _windowDays,
    );

    if (!mounted) return;

    await res.when(
      success: (payload) async {
        final dateStamp = DateTime.now()
            .toUtc()
            .toIso8601String()
            .substring(0, 10)
            .replaceAll('-', '');
        final fileName = 'ritma_${type.code}_$dateStamp.csv';
        final outcome = await CsvExporter.export(
          fileName: fileName,
          columns: payload.columns,
          rows: payload.rows,
        );
        if (!mounted) return;
        setState(() {
          _exporting = false;
          _lastOutcome = outcome;
          _lastRowCount = payload.rows.length;
        });
      },
      failure: (failure) async {
        setState(() {
          _exporting = false;
          _error = failure.message;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final allowed = _allowedTypes();
    if (allowed.isNotEmpty &&
        (_selectedType == null || !allowed.contains(_selectedType))) {
      _selectedType = allowed.first;
    }
    final workspace = ref.watch(activeWorkspaceProvider);
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(RitmaSpacing.lg),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Export Scoped CSV Report',
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: RitmaSpacing.xxs),
              Text(
                'Scope: ${workspace?.scopeLabel ?? 'Workspace'} • Protected against spreadsheet formula injection',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: RitmaSpacing.md),
              if (allowed.isEmpty)
                const Text(
                  'Your current role does not have permission to export operational reports.',
                )
              else ...[
                DropdownButtonFormField<ReportExportType>(
                  initialValue: _selectedType,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Report Type'),
                  items: allowed
                      .map(
                        (t) => DropdownMenuItem(
                          value: t,
                          child: Text(
                            '${t.label} — ${t.description}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: _exporting
                      ? null
                      : (v) => setState(() => _selectedType = v),
                ),
                const SizedBox(height: RitmaSpacing.sm),
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 7, label: Text('7 Days')),
                    ButtonSegment(value: 30, label: Text('30 Days')),
                    ButtonSegment(value: 90, label: Text('90 Days')),
                  ],
                  selected: <int>{_windowDays},
                  onSelectionChanged: _exporting
                      ? null
                      : (s) {
                          if (s.isNotEmpty) {
                            setState(() => _windowDays = s.first);
                          }
                        },
                ),
                const SizedBox(height: RitmaSpacing.md),
                if (_error != null) ...[
                  Text(
                    _error!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: RitmaSpacing.sm),
                ],
                FilledButton.icon(
                  onPressed: (_exporting || _selectedType == null)
                      ? null
                      : () => _runExport(_selectedType!),
                  icon: _exporting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.download_outlined, size: 18),
                  label: Text(
                    _exporting ? 'Generating CSV...' : 'Generate & Export CSV',
                  ),
                ),
                if (_lastOutcome != null) ...[
                  const SizedBox(height: RitmaSpacing.md),
                  Container(
                    padding: const EdgeInsets.all(RitmaSpacing.md),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(RitmaRadius.md),
                      border: Border.all(color: theme.dividerColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Exported ${_lastRowCount ?? 0} row(s) to ${_lastOutcome!.fileName}',
                          style: theme.textTheme.titleSmall,
                        ),
                        if (_lastOutcome!.detail != null) ...[
                          const SizedBox(height: RitmaSpacing.xxs),
                          Text(
                            _lastOutcome!.detail!,
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                        const SizedBox(height: RitmaSpacing.sm),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              await Clipboard.setData(
                                ClipboardData(text: _lastOutcome!.csvContent),
                              );
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('CSV copied to clipboard.'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.copy, size: 16),
                            label: const Text('Copy CSV'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
