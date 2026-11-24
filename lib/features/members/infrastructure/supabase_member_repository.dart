import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../../core/repository/base_repository.dart';
import '../../../core/result/result.dart';
import '../domain/member_model.dart';
import '../domain/member_repository.dart';

class SupabaseMemberRepository extends BaseRepository
    implements MemberRepository {
  SupabaseMemberRepository(this._client)
    : super(loggerName: 'supabase_member_repo');

  final sb.SupabaseClient _client;

  static const String _columns =
      'id, organization_id, user_id, home_branch_id, member_code, full_name, '
      'email, phone, emergency_contact_name, emergency_contact_phone, status';

  @override
  Future<Result<List<MemberModel>>> fetchMembers({
    required String orgId,
    String? branchId,
    String? query,
    MemberStatus? statusFilter,
  }) {
    return guard(() async {
      var builder = _client
          .from('members')
          .select(_columns)
          .eq('organization_id', orgId);

      if (branchId != null) {
        builder = builder.eq('home_branch_id', branchId);
      }
      if (statusFilter != null) {
        builder = builder.eq('status', statusFilter.name);
      }
      if (query != null && query.trim().isNotEmpty) {
        final q = query.trim();
        builder = builder.or('full_name.ilike.%$q%,member_code.ilike.%$q%');
      }

      final rows = await builder.order('full_name', ascending: true);
      return rows
          .map((row) => MemberModel.fromJson(Map<String, dynamic>.from(row)))
          .toList();
    }, operation: 'fetchMembers');
  }

  @override
  Future<Result<MemberModel>> registerMember({
    required String orgId,
    required String homeBranchId,
    required String memberCode,
    required String fullName,
    String? email,
    String? phone,
    String? emergencyContactName,
    String? emergencyContactPhone,
  }) {
    return guard(() async {
      final row = await _client
          .from('members')
          .insert(<String, dynamic>{
            'organization_id': orgId,
            'home_branch_id': homeBranchId,
            'member_code': memberCode.trim().toUpperCase(),
            'full_name': fullName.trim(),
            'email': email?.trim().isEmpty ?? true ? null : email!.trim(),
            'phone': phone?.trim().isEmpty ?? true ? null : phone!.trim(),
            'emergency_contact_name':
                emergencyContactName?.trim().isEmpty ?? true
                ? null
                : emergencyContactName!.trim(),
            'emergency_contact_phone':
                emergencyContactPhone?.trim().isEmpty ?? true
                ? null
                : emergencyContactPhone!.trim(),
          })
          .select(_columns)
          .single();
      return MemberModel.fromJson(Map<String, dynamic>.from(row));
    }, operation: 'registerMember');
  }

  @override
  Future<Result<void>> setMemberStatus({
    required String orgId,
    required String memberId,
    required MemberStatus status,
    String? reason,
  }) {
    return guard(() async {
      await _client.rpc<dynamic>(
        'set_member_status',
        params: <String, dynamic>{
          'p_org_id': orgId,
          'p_member_id': memberId,
          'p_status': status.name,
          'p_reason': reason,
        },
      );
    }, operation: 'setMemberStatus');
  }

  @override
  Future<Result<String>> inviteMemberClaim({
    required String orgId,
    required String memberId,
    required String email,
  }) {
    return guard(() async {
      final raw = await _client.rpc<dynamic>(
        'invite_member_claim',
        params: <String, dynamic>{
          'p_org_id': orgId,
          'p_member_id': memberId,
          'p_email': email.trim().toLowerCase(),
        },
      );
      final map = Map<String, dynamic>.from(raw as Map);
      return map['token'] as String;
    }, operation: 'inviteMemberClaim');
  }
}
