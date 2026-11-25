import '../../../core/result/result.dart';
import 'payment_record_model.dart';

abstract interface class PaymentRepository {
  Future<Result<List<PaymentRecordModel>>> fetchOrgPayments({
    required String orgId,
    String? branchId,
    int limit = 50,
  });

  Future<Result<List<PaymentRecordModel>>> fetchMemberPayments({
    required String orgId,
    required String memberId,
    int limit = 30,
  });

  Future<Result<List<PaymentRefundModel>>> fetchPaymentRefunds({
    required String orgId,
    required String paymentId,
  });

  Future<Result<RefundOutcome>> recordPaymentRefund({
    required String orgId,
    required String paymentId,
    required int amountMinor,
    required String reason,
    required String idempotencyKey,
    String? externalReference,
  });
}
