import '../../../core/result/result.dart';
import 'facility_access_models.dart';

abstract interface class FacilityAccessRepository {
  Future<Result<QrPassToken>> issueMemberQrToken({
    required String orgId,
    required String memberId,
  });

  Future<Result<CheckInOutcome>> validateAndCheckIn({
    required String orgId,
    required String branchId,
    required String qrToken,
    required String idempotencyKey,
    int cooldownMinutes = 15,
  });

  Future<Result<CheckInOutcome>> manualCheckIn({
    required String orgId,
    required String branchId,
    required String memberId,
    required String idempotencyKey,
    bool forceOverride = false,
    String? reason,
  });

  Future<Result<void>> checkOutVisit({
    required String orgId,
    required String visitId,
  });

  Future<Result<List<CheckInMemberLookup>>> lookupMembersForCheckIn({
    required String orgId,
    required String branchId,
    required String query,
  });

  Future<Result<List<FacilityVisitModel>>> fetchBranchVisits({
    required String orgId,
    String? branchId,
    int limit = 30,
  });

  Future<Result<List<FacilityVisitModel>>> fetchMemberVisits({
    required String orgId,
    required String memberId,
    int limit = 20,
  });
}
