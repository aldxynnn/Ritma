import '../../../core/result/result.dart';
import 'operational_metrics_model.dart';
import 'report_export_model.dart';

abstract interface class DashboardRepository {
  Future<Result<OperationalMetricsModel>> fetchOperationalMetrics({
    required String orgId,
    String? branchId,
    int windowDays = 30,
  });

  Future<Result<ReportExportPayload>> fetchReportExport({
    required String orgId,
    required ReportExportType reportType,
    String? branchId,
    int windowDays = 30,
  });
}
