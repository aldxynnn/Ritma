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
}
