import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../../core/repository/base_repository.dart';
import '../../../core/result/result.dart';
import '../domain/dashboard_repository.dart';
import '../domain/operational_metrics_model.dart';

class SupabaseDashboardRepository extends BaseRepository
    implements DashboardRepository {
  SupabaseDashboardRepository(this._client)
    : super(loggerName: 'supabase_dashboard_repo');

  final sb.SupabaseClient _client;

  @override
  Future<Result<OperationalMetricsModel>> fetchOperationalMetrics({
    required String orgId,
    String? branchId,
    int windowDays = 30,
  }) {
    return guard(() async {
      final raw = await _client.rpc<dynamic>(
        'get_operational_dashboard_metrics',
        params: <String, dynamic>{
          'p_org_id': orgId,
          'p_branch_id': branchId,
          'p_window_days': windowDays,
        },
      );
      return OperationalMetricsModel.fromJson(
        Map<String, dynamic>.from(raw as Map),
      );
    }, operation: 'fetchOperationalMetrics');
  }
}
