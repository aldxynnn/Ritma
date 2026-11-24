import '../../../core/demo/demo_sandbox_engine.dart';
import '../../../core/repository/base_repository.dart';
import '../../../core/result/result.dart';
import '../domain/pt_models.dart';
import '../domain/pt_repository.dart';

class DemoSandboxPtRepository extends BaseRepository implements PtRepository {
  DemoSandboxPtRepository(this._engine) : super(loggerName: 'demo_pt_repo');

  final DemoSandboxEngine _engine;

  @override
  Future<Result<List<TrainerProfileModel>>> fetchTrainers({
    required String orgId,
    String? branchId,
  }) {
    return guard(() async {
      return _engine.trainerProfiles.values
          .where(
            (t) =>
                t.organizationId == orgId &&
                t.isActive &&
                (branchId == null || t.homeBranchId == branchId),
          )
          .toList();
    }, operation: 'demo.fetchTrainers');
  }

  @override
  Future<Result<List<TrainerAvailabilityModel>>> fetchTrainerAvailabilities({
    required String orgId,
    required String trainerId,
  }) {
    return guard(() async {
      return _engine.trainerAvailabilities
          .where((a) => a.organizationId == orgId && a.trainerId == trainerId)
          .toList()
        ..sort((a, b) => a.weekday.compareTo(b.weekday));
    }, operation: 'demo.fetchTrainerAvailabilities');
  }

  @override
  Future<Result<List<PtSessionModel>>> fetchPtSessions({
    required String orgId,
    String? branchId,
    String? memberId,
  }) {
    return guard(() async {
      return _engine.ptSessions.values
          .where(
            (s) =>
                s.organizationId == orgId &&
                (branchId == null || s.branchId == branchId) &&
                (memberId == null || s.memberId == memberId),
          )
          .toList()
        ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
    }, operation: 'demo.fetchPtSessions');
  }

  @override
  Future<Result<PtBookingOutcome>> bookPtSession({
    required String orgId,
    required String branchId,
    required String trainerId,
    required String memberId,
    required DateTime startsAt,
    required DateTime endsAt,
    int? creditCost,
    required String idempotencyKey,
  }) {
    return guard(
      () async => _engine.bookPtSession(
        orgId: orgId,
        branchId: branchId,
        trainerId: trainerId,
        memberId: memberId,
        startsAt: startsAt,
        endsAt: endsAt,
        creditCost: creditCost,
        idempotencyKey: idempotencyKey,
      ),
      operation: 'demo.bookPtSession',
    );
  }

  @override
  Future<Result<void>> completePtSession({
    required String orgId,
    required String ptSessionId,
    String? notes,
  }) {
    return guard(
      () async => _engine.completePtSession(
        orgId: orgId,
        ptSessionId: ptSessionId,
        notes: notes,
      ),
      operation: 'demo.completePtSession',
    );
  }
}
