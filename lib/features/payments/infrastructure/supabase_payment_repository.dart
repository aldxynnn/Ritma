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
      'amount_minor, currency_code, method, status, external_reference, paid_at, '
      'refunded_amount_minor, refund_reason, refunded_at, members(full_name)';

  PaymentRecordModel _mapPayment(Map<dynamic, dynamic> raw) {
    final map = Map<String, dynamic>.from(raw);
    final memberRel = map.remove('members');
    if (memberRel is Map && memberRel['full_name'] is String) {
      map['member_display_name'] = memberRel['full_name'] as String;
    }
    return PaymentRecordModel.fromJson(map);
  }

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
      return rows.map(_mapPayment).toList();
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
      return rows.map(_mapPayment).toList();
    }, operation: 'fetchMemberPayments');
  }

  @override
  Future<Result<List<PaymentRefundModel>>> fetchPaymentRefunds({
    required String orgId,
    required String paymentId,
  }) {
    return guard(() async {
      final rows = await _client
          .from('payment_refunds')
          .select(
            'id, organization_id, branch_id, payment_id, member_id, '
            'amount_minor, currency_code, refund_channel, reason, '
            'external_reference, refunded_by, created_at',
          )
          .eq('organization_id', orgId)
          .eq('payment_id', paymentId)
          .order('created_at', ascending: false);
      return rows
          .map((r) => PaymentRefundModel.fromJson(Map<String, dynamic>.from(r)))
          .toList();
    }, operation: 'fetchPaymentRefunds');
  }

  @override
  Future<Result<RefundOutcome>> recordPaymentRefund({
    required String orgId,
    required String paymentId,
    required int amountMinor,
    required String reason,
    required String idempotencyKey,
    String? externalReference,
  }) {
    return guard(() async {
      final raw = await _client.rpc<dynamic>(
        'record_payment_refund',
        params: <String, dynamic>{
          'p_org_id': orgId,
          'p_payment_id': paymentId,
          'p_amount_minor': amountMinor,
          'p_reason': reason.trim(),
          'p_idempotency_key': idempotencyKey,
          'p_external_reference': externalReference?.trim().isEmpty ?? true
              ? null
              : externalReference!.trim(),
        },
      );
      return RefundOutcome.fromJson(Map<String, dynamic>.from(raw as Map));
    }, operation: 'recordPaymentRefund');
  }
}
