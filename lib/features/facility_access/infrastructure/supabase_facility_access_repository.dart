import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../../core/repository/base_repository.dart';
import '../../../core/result/result.dart';
import '../domain/facility_access_models.dart';
import '../domain/facility_access_repository.dart';

class SupabaseFacilityAccessRepository extends BaseRepository
    implements FacilityAccessRepository {
  SupabaseFacilityAccessRepository(this._client)
    : super(loggerName: 'supabase_facility_access');

  final sb.SupabaseClient _client;

  @override
  Future<Result<QrPassToken>> issueMemberQrToken({
    required String orgId,
    required String memberId,
  }) {
    return guard(() async {
      final raw = await _client.rpc<dynamic>(
        'issue_member_qr_token',
        params: <String, dynamic>{'p_org_id': orgId, 'p_member_id': memberId},
      );
      return QrPassToken.fromJson(Map<String, dynamic>.from(raw as Map));
    }, operation: 'issueMemberQrToken');
  }

  @override
  Future<Result<CheckInOutcome>> validateAndCheckIn({
    required String orgId,
    required String branchId,
    required String qrToken,
    required String idempotencyKey,
    int cooldownMinutes = 15,
  }) {
    return guard(() async {
      final raw = await _client.rpc<dynamic>(
        'validate_and_check_in',
        params: <String, dynamic>{
          'p_org_id': orgId,
          'p_branch_id': branchId,
          'p_qr_token': qrToken.trim(),
          'p_idempotency_key': idempotencyKey,
          'p_cooldown_minutes': cooldownMinutes,
        },
      );
      return CheckInOutcome.fromJson(Map<String, dynamic>.from(raw as Map));
    }, operation: 'validateAndCheckIn');
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
    return guard(() async {
      final raw = await _client.rpc<dynamic>(
        'manual_facility_check_in',
        params: <String, dynamic>{
          'p_org_id': orgId,
          'p_branch_id': branchId,
          'p_member_id': memberId,
          'p_force_override': forceOverride,
          'p_reason': reason,
          'p_idempotency_key': idempotencyKey,
        },
      );
      return CheckInOutcome.fromJson(Map<String, dynamic>.from(raw as Map));
    }, operation: 'manualCheckIn');
  }

  @override
  Future<Result<void>> checkOutVisit({
    required String orgId,
    required String visitId,
  }) {
    return guard(() async {
      await _client.rpc<dynamic>(
        'check_out_facility_visit',
        params: <String, dynamic>{'p_org_id': orgId, 'p_visit_id': visitId},
      );
    }, operation: 'checkOutVisit');
  }

  @override
  Future<Result<List<CheckInMemberLookup>>> lookupMembersForCheckIn({
    required String orgId,
    required String branchId,
    required String query,
  }) {
    return guard(() async {
      final raw = await _client.rpc<dynamic>(
        'lookup_member_for_checkin',
        params: <String, dynamic>{
          'p_org_id': orgId,
          'p_branch_id': branchId,
          'p_query': query.trim(),
        },
      );
      if (raw is! List<dynamic>) {
        return const <CheckInMemberLookup>[];
      }
      return raw
          .whereType<Map<dynamic, dynamic>>()
          .map(
            (m) => CheckInMemberLookup.fromJson(Map<String, dynamic>.from(m)),
          )
          .toList();
    }, operation: 'lookupMembersForCheckIn');
  }

  @override
  Future<Result<List<FacilityVisitModel>>> fetchBranchVisits({
    required String orgId,
    String? branchId,
    int limit = 30,
  }) {
    return guard(() async {
      var builder = _client
          .from('facility_visits')
          .select(
            'id, organization_id, branch_id, member_id, entitlement_id, '
            'check_in_method, override_reason, checked_in_at, checked_out_at',
          )
          .eq('organization_id', orgId);

      if (branchId != null) {
        builder = builder.eq('branch_id', branchId);
      }
      final rows = await builder
          .order('checked_in_at', ascending: false)
          .limit(limit);
      return rows
          .map(
            (row) =>
                FacilityVisitModel.fromJson(Map<String, dynamic>.from(row)),
          )
          .toList();
    }, operation: 'fetchBranchVisits');
  }

  @override
  Future<Result<List<FacilityVisitModel>>> fetchMemberVisits({
    required String orgId,
    required String memberId,
    int limit = 20,
  }) {
    return guard(() async {
      final rows = await _client
          .from('facility_visits')
          .select(
            'id, organization_id, branch_id, member_id, entitlement_id, '
            'check_in_method, override_reason, checked_in_at, checked_out_at',
          )
          .eq('organization_id', orgId)
          .eq('member_id', memberId)
          .order('checked_in_at', ascending: false)
          .limit(limit);
      return rows
          .map(
            (row) =>
                FacilityVisitModel.fromJson(Map<String, dynamic>.from(row)),
          )
          .toList();
    }, operation: 'fetchMemberVisits');
  }
}
