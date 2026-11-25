import '../../../core/result/result.dart';
import 'pt_models.dart';

abstract interface class PtRepository {
  Future<Result<List<TrainerProfileModel>>> fetchTrainers({
    required String orgId,
    String? branchId,
  });

  Future<Result<List<TrainerAvailabilityModel>>> fetchTrainerAvailabilities({
    required String orgId,
    required String trainerId,
  });

  Future<Result<List<PtSessionModel>>> fetchPtSessions({
    required String orgId,
    String? branchId,
    String? memberId,
  });

  Future<Result<List<PtClientLookup>>> lookupMembersForPtBooking({
    required String orgId,
    required String branchId,
    String query = '',
  });

  Future<Result<PtBookingOutcome>> bookPtSession({
    required String orgId,
    required String branchId,
    required String trainerId,
    required String memberId,
    required DateTime startsAt,
    required DateTime endsAt,
    int? creditCost,
    required String idempotencyKey,
  });

  Future<Result<void>> completePtSession({
    required String orgId,
    required String ptSessionId,
    String? notes,
  });

  Future<Result<PtCancelOutcome>> cancelPtSession({
    required String orgId,
    required String ptSessionId,
    String? reason,
  });
}
