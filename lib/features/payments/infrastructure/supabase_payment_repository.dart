import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../../core/repository/base_repository.dart';
import '../../../core/result/result.dart';
import '../domain/payment_record_model.dart';
import '../domain/payment_repository.dart';

class SupabasePaymentRepository extends BaseRepository
    implements PaymentRepository {
  SupabasePaymentRepository(this._client)
    : super(loggerName: 'supabase_payment_repo');

  final sb.SupabaseClient _client;

  static const String _columns =
      'id, organization_id, branch_id, member_id, subscription_id, '
      'amount_minor, currency_code, method, status, external_reference, paid_at';

  @override
  Future<Result<List<PaymentRecordModel>>> fetchOrgPayments({
    required String orgId,
    String? branchId,
    int limit = 50,
  }) {
    return guard(() async {
      var builder = _client
          .from('payment_records')
          .select(_columns)
          .eq('organization_id', orgId);
      if (branchId != null) {
        builder = builder.eq('branch_id', branchId);
      }
      final rows = await builder
          .order('paid_at', ascending: false)
          .limit(limit);
      return rows
          .map((r) => PaymentRecordModel.fromJson(Map<String, dynamic>.from(r)))
          .toList();
    }, operation: 'fetchOrgPayments');
  }

  @override
  Future<Result<List<PaymentRecordModel>>> fetchMemberPayments({
    required String orgId,
    required String memberId,
    int limit = 30,
  }) {
    return guard(() async {
      final rows = await _client
          .from('payment_records')
          .select(_columns)
          .eq('organization_id', orgId)
          .eq('member_id', memberId)
          .order('paid_at', ascending: false)
          .limit(limit);
      return rows
          .map((r) => PaymentRecordModel.fromJson(Map<String, dynamic>.from(r)))
          .toList();
    }, operation: 'fetchMemberPayments');
  }
}
