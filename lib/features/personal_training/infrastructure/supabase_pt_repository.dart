import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../../core/repository/base_repository.dart';
import '../../../core/result/result.dart';
import '../domain/pt_models.dart';
import '../domain/pt_repository.dart';

class SupabasePtRepository extends BaseRepository implements PtRepository {
  SupabasePtRepository(this._client) : super(loggerName: 'supabase_pt_repo');

  final sb.SupabaseClient _client;

  @override
  Future<Result<List<TrainerProfileModel>>> fetchTrainers({
    required String orgId,
    String? branchId,
  }) {
    return guard(() async {
      var builder = _client
          .from('trainer_profiles')
          .select(
            'id, organization_id, user_id, home_branch_id, display_name, bio, '
            'specialties, default_credit_cost, is_active',
          )
          .eq('organization_id', orgId)
          .eq('is_active', true);
      if (branchId != null) {
        builder = builder.eq('home_branch_id', branchId);
      }
      final rows = await builder.order('created_at', ascending: true);
      return rows
          .map(
            (r) => TrainerProfileModel.fromJson(Map<String, dynamic>.from(r)),
          )
          .toList();
    }, operation: 'fetchTrainers');
  }

  @override
  Future<Result<List<TrainerAvailabilityModel>>> fetchTrainerAvailabilities({
    required String orgId,
    required String trainerId,
  }) {
    return guard(() async {
      final rows = await _client
          .from('trainer_availabilities')
          .select(
            'id, organization_id, branch_id, trainer_id, weekday, start_time, end_time',
          )
          .eq('organization_id', orgId)
          .eq('trainer_id', trainerId)
          .order('weekday', ascending: true);
      return rows
          .map(
            (r) =>
                TrainerAvailabilityModel.fromJson(Map<String, dynamic>.from(r)),
          )
          .toList();
    }, operation: 'fetchTrainerAvailabilities');
  }

  @override
  Future<Result<List<PtSessionModel>>> fetchPtSessions({
    required String orgId,
    String? branchId,
    String? memberId,
  }) {
    return guard(() async {
      final raw = await _client.rpc<dynamic>(
        'get_pt_sessions_for_workspace',
        params: <String, dynamic>{
          'p_org_id': orgId,
          'p_branch_id': branchId,
          'p_member_id': memberId,
        },
      );
      if (raw is! List<dynamic>) {
        return const <PtSessionModel>[];
      }
      return raw
          .whereType<Map<dynamic, dynamic>>()
          .map((r) => PtSessionModel.fromJson(Map<String, dynamic>.from(r)))
          .toList();
    }, operation: 'fetchPtSessions');
  }

  @override
  Future<Result<List<PtClientLookup>>> lookupMembersForPtBooking({
    required String orgId,
    required String branchId,
    String query = '',
  }) {
    return guard(() async {
      final raw = await _client.rpc<dynamic>(
        'lookup_members_for_pt_booking',
        params: <String, dynamic>{
          'p_org_id': orgId,
          'p_branch_id': branchId,
          'p_query': query.trim(),
        },
      );
      if (raw is! List<dynamic>) {
        return const <PtClientLookup>[];
      }
      return raw
          .whereType<Map<dynamic, dynamic>>()
          .map((r) => PtClientLookup.fromJson(Map<String, dynamic>.from(r)))
          .toList();
    }, operation: 'lookupMembersForPtBooking');
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
    return guard(() async {
      final raw = await _client.rpc<Map<String, dynamic>>(
        'book_pt_session',
        params: <String, dynamic>{
          'p_org_id': orgId,
          'p_branch_id': branchId,
          'p_trainer_id': trainerId,
          'p_member_id': memberId,
          'p_starts_at': startsAt.toUtc().toIso8601String(),
          'p_ends_at': endsAt.toUtc().toIso8601String(),
          'p_credit_cost': creditCost,
          'p_idempotency_key': idempotencyKey,
        },
      );
      return PtBookingOutcome.fromJson(Map<String, dynamic>.from(raw));
    }, operation: 'bookPtSession');
  }

  @override
  Future<Result<void>> completePtSession({
    required String orgId,
    required String ptSessionId,
    String? notes,
  }) {
    return guard(() async {
      await _client.rpc<void>(
        'complete_pt_session',
        params: <String, dynamic>{
          'p_org_id': orgId,
          'p_pt_session_id': ptSessionId,
          'p_notes': notes,
        },
      );
    }, operation: 'completePtSession');
  }

  @override
  Future<Result<PtCancelOutcome>> cancelPtSession({
    required String orgId,
    required String ptSessionId,
    String? reason,
  }) {
    return guard(() async {
      final raw = await _client.rpc<dynamic>(
        'cancel_pt_session',
        params: <String, dynamic>{
          'p_org_id': orgId,
          'p_pt_session_id': ptSessionId,
          'p_reason': reason?.trim().isEmpty ?? true ? null : reason!.trim(),
        },
      );
      return PtCancelOutcome.fromJson(Map<String, dynamic>.from(raw as Map));
    }, operation: 'cancelPtSession');
  }
}
