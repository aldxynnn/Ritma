import '../../../core/result/result.dart';
import 'operational_metrics_model.dart';

abstract interface class DashboardRepository {
  Future<Result<OperationalMetricsModel>> fetchOperationalMetrics({
    required String orgId,
    String? branchId,
    int windowDays = 30,
  });
}
