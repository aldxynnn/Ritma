import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../../core/repository/base_repository.dart';
import '../../../core/result/result.dart';
import '../domain/audit_log_model.dart';
import '../domain/branch_model.dart';
import '../domain/organization_invitation_result.dart';
import '../domain/organization_model.dart';
import '../domain/organization_repository.dart';
import '../domain/room_model.dart';
import '../domain/staff_management_models.dart';

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

  @override
  Future<Result<OrganizationModel>> fetchOrganization(String orgId) {
    return guard(() async {
      final row = await _client
          .from('organizations')
          .select(
            'id, name, slug, business_type, timezone, currency_code, status',
          )
          .eq('id', orgId)
          .single();
      return OrganizationModel.fromJson(Map<String, dynamic>.from(row));
    }, operation: 'fetchOrganization');
  }

  @override
  Future<Result<void>> updateOrganizationSettings({
    required String orgId,
    required String name,
    required String businessType,
    required String timezone,
    required String currencyCode,
  }) {
    return guard(() async {
      await _client.rpc<void>(
        'update_organization_settings',
        params: <String, dynamic>{
          'p_org_id': orgId,
          'p_name': name.trim(),
          'p_business_type': businessType,
          'p_timezone': timezone,
          'p_currency_code': currencyCode.trim().toUpperCase(),
        },
      );
    }, operation: 'updateOrganizationSettings');
  }

  @override
  Future<Result<void>> rotateOrgSigningKey(String orgId) {
    return guard(() async {
      await _client.rpc<void>(
        'rotate_org_signing_key',
        params: <String, dynamic>{'p_org_id': orgId},
      );
    }, operation: 'rotateOrgSigningKey');
  }

  @override
  Future<Result<BranchModel>> updateBranch({
    required String orgId,
    required String branchId,
    required String name,
    required String code,
    String? address,
    String? timezone,
    required bool isActive,
  }) {
    return guard(() async {
      final row = await _client
          .from('branches')
          .update(<String, dynamic>{
            'name': name.trim(),
            'code': code.trim().toUpperCase(),
            'address': address?.trim().isEmpty ?? true ? null : address!.trim(),
            'timezone': timezone,
            'is_active': isActive,
          })
          .eq('organization_id', orgId)
          .eq('id', branchId)
          .select(
            'id, organization_id, name, code, address, timezone, is_active',
          )
          .single();
      return BranchModel.fromJson(Map<String, dynamic>.from(row));
    }, operation: 'updateBranch');
  }

  @override
  Future<Result<RoomModel>> updateRoom({
    required String orgId,
    required String roomId,
    required String name,
    required String roomType,
    required int defaultCapacity,
    required bool isActive,
  }) {
    return guard(() async {
      final row = await _client
          .from('rooms')
          .update(<String, dynamic>{
            'name': name.trim(),
            'room_type': roomType.trim().isEmpty ? 'studio' : roomType.trim(),
            'default_capacity': defaultCapacity,
            'is_active': isActive,
          })
          .eq('organization_id', orgId)
          .eq('id', roomId)
          .select(
            'id, organization_id, branch_id, name, room_type, default_capacity, is_active',
          )
          .single();
      return RoomModel.fromJson(Map<String, dynamic>.from(row));
    }, operation: 'updateRoom');
  }

  @override
  Future<Result<List<StaffAssignmentModel>>> fetchOrganizationStaff({
    required String orgId,
    String? branchId,
  }) {
    return guard(() async {
      final raw = await _client.rpc<dynamic>(
        'list_organization_staff',
        params: <String, dynamic>{'p_org_id': orgId, 'p_branch_id': branchId},
      );
      if (raw is! List<dynamic>) {
        return const <StaffAssignmentModel>[];
      }
      return raw
          .whereType<Map<dynamic, dynamic>>()
          .map(
            (row) =>
                StaffAssignmentModel.fromJson(Map<String, dynamic>.from(row)),
          )
          .toList();
    }, operation: 'fetchOrganizationStaff');
  }

  @override
  Future<Result<void>> assignUserRole({
    required String orgId,
    required String targetUserId,
    required String roleCode,
    String? branchId,
  }) {
    return guard(() async {
      await _client.rpc<void>(
        'assign_user_role',
        params: <String, dynamic>{
          'p_org_id': orgId,
          'p_target_user_id': targetUserId,
          'p_role_code': roleCode,
          'p_branch_id': branchId,
        },
      );
    }, operation: 'assignUserRole');
  }

  @override
  Future<Result<void>> revokeUserRole({
    required String orgId,
    required String assignmentId,
  }) {
    return guard(() async {
      await _client.rpc<void>(
        'revoke_user_role',
        params: <String, dynamic>{
          'p_org_id': orgId,
          'p_assignment_id': assignmentId,
        },
      );
    }, operation: 'revokeUserRole');
  }

  @override
  Future<Result<List<OrganizationInvitationModel>>>
  fetchOrganizationInvitations({required String orgId, String? branchId}) {
    return guard(() async {
      final raw = await _client.rpc<dynamic>(
        'list_organization_invitations',
        params: <String, dynamic>{'p_org_id': orgId, 'p_branch_id': branchId},
      );
      if (raw is! List<dynamic>) {
        return const <OrganizationInvitationModel>[];
      }
      return raw
          .whereType<Map<dynamic, dynamic>>()
          .map(
            (row) => OrganizationInvitationModel.fromJson(
              Map<String, dynamic>.from(row),
            ),
          )
          .toList();
    }, operation: 'fetchOrganizationInvitations');
  }

  @override
  Future<Result<void>> revokeOrganizationInvitation({
    required String orgId,
    required String invitationId,
  }) {
    return guard(() async {
      await _client.rpc<void>(
        'revoke_organization_invitation',
        params: <String, dynamic>{
          'p_org_id': orgId,
          'p_invitation_id': invitationId,
        },
      );
    }, operation: 'revokeOrganizationInvitation');
  }

  @override
  Future<Result<List<AuditLogModel>>> fetchAuditLogs({
    required String orgId,
    String? branchId,
    int limit = 50,
  }) {
    return guard(() async {
      var query = _client
          .from('audit_logs')
          .select(
            'id, organization_id, branch_id, actor_user_id, action, '
            'target_type, target_id, metadata, created_at',
          )
          .eq('organization_id', orgId);
      if (branchId != null) {
        query = query.eq('branch_id', branchId);
      }
      final rows = await query
          .order('created_at', ascending: false)
          .limit(limit);
      return rows
          .map((r) => AuditLogModel.fromJson(Map<String, dynamic>.from(r)))
          .toList();
    }, operation: 'fetchAuditLogs');
  }
}
