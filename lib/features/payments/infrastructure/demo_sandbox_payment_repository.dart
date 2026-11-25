import '../../../core/demo/demo_sandbox_engine.dart';
import '../../../core/repository/base_repository.dart';
import '../../../core/result/result.dart';
import '../domain/payment_record_model.dart';
import '../domain/payment_repository.dart';

class DemoSandboxPaymentRepository extends BaseRepository
    implements PaymentRepository {
  DemoSandboxPaymentRepository(this._engine)
    : super(loggerName: 'demo_payment_repo');

  final DemoSandboxEngine _engine;

  @override
  Future<Result<List<PaymentRecordModel>>> fetchOrgPayments({
    required String orgId,
    String? branchId,
    int limit = 50,
  }) {
    return guard(() async {
      final list =
          _engine.paymentRecords
              .where(
                (p) =>
                    p.organizationId == orgId &&
                    (branchId == null || p.branchId == branchId),
              )
              .toList()
            ..sort((a, b) => b.paidAt.compareTo(a.paidAt));
      return list.take(limit).toList();
    }, operation: 'demo.fetchOrgPayments');
  }

  @override
  Future<Result<List<PaymentRecordModel>>> fetchMemberPayments({
    required String orgId,
    required String memberId,
    int limit = 30,
  }) {
    return guard(() async {
      final list =
          _engine.paymentRecords
              .where((p) => p.organizationId == orgId && p.memberId == memberId)
              .toList()
            ..sort((a, b) => b.paidAt.compareTo(a.paidAt));
      return list.take(limit).toList();
    }, operation: 'demo.fetchMemberPayments');
  }

  @override
  Future<Result<List<PaymentRefundModel>>> fetchPaymentRefunds({
    required String orgId,
    required String paymentId,
  }) {
    return guard(
      () async =>
          _engine.fetchPaymentRefunds(orgId: orgId, paymentId: paymentId),
      operation: 'demo.fetchPaymentRefunds',
    );
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
    return guard(
      () async => _engine.recordPaymentRefund(
        orgId: orgId,
        paymentId: paymentId,
        amountMinor: amountMinor,
        reason: reason,
        idempotencyKey: idempotencyKey,
        externalReference: externalReference,
      ),
      operation: 'demo.recordPaymentRefund',
    );
  }
}
