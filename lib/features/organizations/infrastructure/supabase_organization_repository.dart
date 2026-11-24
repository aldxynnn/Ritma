import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../../core/repository/base_repository.dart';
import '../../../core/result/result.dart';
import '../domain/branch_model.dart';
import '../domain/organization_invitation_result.dart';
import '../domain/organization_repository.dart';
import '../domain/room_model.dart';

class SupabaseOrganizationRepository extends BaseRepository
    implements OrganizationRepository {
  SupabaseOrganizationRepository(this._client)
    : super(loggerName: 'supabase_org_repo');

  final sb.SupabaseClient _client;

  @override
  Future<Result<String>> createOrganizationWithOwner({
    required String name,
    required String slug,
    required String businessType,
    required String timezone,
    required String currencyCode,
    required String firstBranchName,
    required String firstBranchCode,
  }) {
    return guard(() async {
      final raw = await _client.rpc<dynamic>(
        'create_organization_with_owner',
        params: <String, dynamic>{
          'p_name': name.trim(),
          'p_slug': slug.trim().toLowerCase(),
          'p_business_type': businessType,
          'p_timezone': timezone,
          'p_currency_code': currencyCode.trim().toUpperCase(),
          'p_first_branch_name': firstBranchName.trim(),
          'p_first_branch_code': firstBranchCode.trim().toUpperCase(),
        },
      );
      final map = Map<String, dynamic>.from(raw as Map);
      return map['organization_id'] as String;
    }, operation: 'createOrganizationWithOwner');
  }

  @override
  Future<Result<List<BranchModel>>> fetchBranches(String orgId) {
    return guard(() async {
      final rows = await _client
          .from('branches')
          .select(
            'id, organization_id, name, code, address, timezone, is_active',
          )
          .eq('organization_id', orgId)
          .order('name', ascending: true);
      return rows
          .map((row) => BranchModel.fromJson(Map<String, dynamic>.from(row)))
          .toList();
    }, operation: 'fetchBranches');
  }

  @override
  Future<Result<BranchModel>> createBranch({
    required String orgId,
    required String name,
    required String code,
    String? address,
    String? timezone,
  }) {
    return guard(() async {
      final row = await _client
          .from('branches')
          .insert(<String, dynamic>{
            'organization_id': orgId,
            'name': name.trim(),
            'code': code.trim().toUpperCase(),
            'address': address?.trim().isEmpty ?? true ? null : address!.trim(),
            'timezone': timezone,
          })
          .select(
            'id, organization_id, name, code, address, timezone, is_active',
          )
          .single();
      return BranchModel.fromJson(Map<String, dynamic>.from(row));
    }, operation: 'createBranch');
  }

  @override
  Future<Result<List<RoomModel>>> fetchRooms(String orgId, {String? branchId}) {
    return guard(() async {
      var query = _client
          .from('rooms')
          .select(
            'id, organization_id, branch_id, name, room_type, default_capacity, is_active',
          )
          .eq('organization_id', orgId);
      if (branchId != null) {
        query = query.eq('branch_id', branchId);
      }
      final rows = await query.order('name', ascending: true);
      return rows
          .map((row) => RoomModel.fromJson(Map<String, dynamic>.from(row)))
          .toList();
    }, operation: 'fetchRooms');
  }

  @override
  Future<Result<RoomModel>> createRoom({
    required String orgId,
    required String branchId,
    required String name,
    required String roomType,
    required int defaultCapacity,
  }) {
    return guard(() async {
      final row = await _client
          .from('rooms')
          .insert(<String, dynamic>{
            'organization_id': orgId,
            'branch_id': branchId,
            'name': name.trim(),
            'room_type': roomType.trim().isEmpty ? 'studio' : roomType.trim(),
            'default_capacity': defaultCapacity,
          })
          .select(
            'id, organization_id, branch_id, name, room_type, default_capacity, is_active',
          )
          .single();
      return RoomModel.fromJson(Map<String, dynamic>.from(row));
    }, operation: 'createRoom');
  }

  @override
  Future<Result<OrganizationInvitationResult>> inviteStaff({
    required String orgId,
    required String email,
    required String roleCode,
    String? branchId,
  }) {
    return guard(() async {
      final raw = await _client.rpc<dynamic>(
        'invite_user_to_organization',
        params: <String, dynamic>{
          'p_org_id': orgId,
          'p_invited_email': email.trim().toLowerCase(),
          'p_role_code': roleCode,
          'p_branch_id': branchId,
        },
      );
      final map = Map<String, dynamic>.from(raw as Map);
      return OrganizationInvitationResult(
        invitationId: map['invitation_id'] as String,
        token: map['token'] as String,
        invitedEmail: email.trim().toLowerCase(),
        roleCode: roleCode,
        branchId: branchId,
      );
    }, operation: 'inviteStaff');
  }
}
