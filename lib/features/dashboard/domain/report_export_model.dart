import 'package:freezed_annotation/freezed_annotation.dart';

part 'report_export_model.freezed.dart';
part 'report_export_model.g.dart';

enum ReportExportType {
  visits('visits', 'Facility Visits', 'Recent gym & studio entry/exit records'),
  payments(
    'payments',
    'Payments & Refunds',
    'Invoices, manual refunds, and net revenue',
  ),
  members(
    'members',
    'Members Directory',
    'Member codes, status, home branch, and claim status',
  ),
  attendance(
    'attendance',
    'Class Attendance',
    'Session attendance & booking records',
  );

  const ReportExportType(this.code, this.label, this.description);

  final String code;
  final String label;
  final String description;
}

@freezed
abstract class ReportExportPayload with _$ReportExportPayload {
  const factory ReportExportPayload({
    @JsonKey(name: 'report_type') required String reportType,
    @JsonKey(name: 'organization_name') required String organizationName,
    @JsonKey(name: 'branch_scope') required String branchScope,
    @JsonKey(name: 'currency_code') @Default('USD') String currencyCode,
    @Default('UTC') String timezone,
    @JsonKey(name: 'generated_at') required DateTime generatedAt,
    @Default(<String>[]) List<String> columns,
    @Default(<List<dynamic>>[]) List<List<dynamic>> rows,
  }) = _ReportExportPayload;

  factory ReportExportPayload.fromJson(Map<String, dynamic> json) =>
      _$ReportExportPayloadFromJson(json);
}
