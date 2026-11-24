import '../../../core/demo/demo_sandbox_engine.dart';
import '../../../core/repository/base_repository.dart';
import '../../../core/result/result.dart';
import '../domain/facility_access_models.dart';
import '../domain/facility_access_repository.dart';

class DemoSandboxFacilityAccessRepository extends BaseRepository
    implements FacilityAccessRepository {
  DemoSandboxFacilityAccessRepository(this._engine)
    : super(loggerName: 'demo_facility_access');

  final DemoSandboxEngine _engine;

  @override
  Future<Result<QrPassToken>> issueMemberQrToken({
    required String orgId,
    required String memberId,
  }) {
    return guard(
      () async => _engine.issueMemberQrToken(orgId: orgId, memberId: memberId),
      operation: 'demo.issueMemberQrToken',
    );
  }

  @override
  Future<Result<CheckInOutcome>> validateAndCheckIn({
    required String orgId,
    required String branchId,
    required String qrToken,
    required String idempotencyKey,
    int cooldownMinutes = 15,
  }) {
    return guard(
      () async => _engine.validateAndCheckIn(
        orgId: orgId,
        branchId: branchId,
        qrToken: qrToken,
        idempotencyKey: idempotencyKey,
        cooldownMinutes: cooldownMinutes,
      ),
      operation: 'demo.validateAndCheckIn',
    );
  }

  @override
  Future<Result<CheckInOutcome>> manualCheckIn({
    required String orgId,
    required String branchId,
    required String memberId,
    required String idempotencyKey,
    bool forceOverride = false,
    String? reason,
  }) {
    return guard(
      () async => _engine.manualCheckIn(
        orgId: orgId,
        branchId: branchId,
        memberId: memberId,
        idempotencyKey: idempotencyKey,
        forceOverride: forceOverride,
        reason: reason,
      ),
      operation: 'demo.manualCheckIn',
    );
  }

  @override
  Future<Result<void>> checkOutVisit({
    required String orgId,
    required String visitId,
  }) {
    return guard(
      () async => _engine.checkOutVisit(orgId: orgId, visitId: visitId),
      operation: 'demo.checkOutVisit',
    );
  }

  @override
  Future<Result<List<CheckInMemberLookup>>> lookupMembersForCheckIn({
    required String orgId,
    required String branchId,
    required String query,
  }) {
    return guard(
      () async => _engine.lookupMembersForCheckIn(orgId: orgId, query: query),
      operation: 'demo.lookupMembersForCheckIn',
    );
  }

  @override
  Future<Result<List<FacilityVisitModel>>> fetchBranchVisits({
    required String orgId,
    String? branchId,
    int limit = 30,
  }) {
    return guard(() async {
      final visits =
          _engine.facilityVisits
              .where(
                (v) =>
                    v.organizationId == orgId &&
                    (branchId == null || v.branchId == branchId),
              )
              .toList()
            ..sort((a, b) => b.checkedInAt.compareTo(a.checkedInAt));
      return visits.take(limit).toList();
    }, operation: 'demo.fetchBranchVisits');
  }

  @override
  Future<Result<List<FacilityVisitModel>>> fetchMemberVisits({
    required String orgId,
    required String memberId,
    int limit = 20,
  }) {
    return guard(() async {
      final visits =
          _engine.facilityVisits
              .where((v) => v.organizationId == orgId && v.memberId == memberId)
              .toList()
            ..sort((a, b) => b.checkedInAt.compareTo(a.checkedInAt));
      return visits.take(limit).toList();
    }, operation: 'demo.fetchMemberVisits');
  }
}
