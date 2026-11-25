// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_export_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReportExportPayload _$ReportExportPayloadFromJson(Map<String, dynamic> json) =>
    _ReportExportPayload(
      reportType: json['report_type'] as String,
      organizationName: json['organization_name'] as String,
      branchScope: json['branch_scope'] as String,
      currencyCode: json['currency_code'] as String? ?? 'USD',
      timezone: json['timezone'] as String? ?? 'UTC',
      generatedAt: DateTime.parse(json['generated_at'] as String),
      columns:
          (json['columns'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      rows:
          (json['rows'] as List<dynamic>?)
              ?.map((e) => e as List<dynamic>)
              .toList() ??
          const <List<dynamic>>[],
    );

Map<String, dynamic> _$ReportExportPayloadToJson(
  _ReportExportPayload instance,
) => <String, dynamic>{
  'report_type': instance.reportType,
  'organization_name': instance.organizationName,
  'branch_scope': instance.branchScope,
  'currency_code': instance.currencyCode,
  'timezone': instance.timezone,
  'generated_at': instance.generatedAt.toIso8601String(),
  'columns': instance.columns,
  'rows': instance.rows,
};
