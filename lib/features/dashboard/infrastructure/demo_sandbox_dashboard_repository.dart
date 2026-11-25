import '../../../core/demo/demo_sandbox_engine.dart';
import '../../../core/repository/base_repository.dart';
import '../../../core/result/result.dart';
import '../domain/dashboard_repository.dart';
import '../domain/operational_metrics_model.dart';
import '../domain/report_export_model.dart';

class DemoSandboxDashboardRepository extends BaseRepository
    implements DashboardRepository {
  DemoSandboxDashboardRepository(this._engine)
    : super(loggerName: 'demo_dashboard_repo');

  final DemoSandboxEngine _engine;

  @override
  Future<Result<OperationalMetricsModel>> fetchOperationalMetrics({
    required String orgId,
    String? branchId,
    int windowDays = 30,
  }) {
    return guard(
      () async => _engine.getOperationalDashboardMetrics(
        orgId: orgId,
        branchId: branchId,
        windowDays: windowDays,
      ),
      operation: 'demo.fetchOperationalMetrics',
    );
  }

  @override
  Future<Result<ReportExportPayload>> fetchReportExport({
    required String orgId,
    required ReportExportType reportType,
    String? branchId,
    int windowDays = 30,
  }) {
    return guard(
      () async => _engine.getReportExportData(
        orgId: orgId,
        reportType: reportType,
        branchId: branchId,
        windowDays: windowDays,
      ),
      operation: 'demo.fetchReportExport',
    );
  }
}
