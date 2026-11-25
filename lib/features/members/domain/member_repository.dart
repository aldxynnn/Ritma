import '../../../core/result/result.dart';
import 'member_model.dart';

abstract interface class MemberRepository {
  Future<Result<List<MemberModel>>> fetchMembers({
    required String orgId,
    String? branchId,
    String? query,
    MemberStatus? statusFilter,
  });

  Future<Result<MemberModel>> registerMember({
    required String orgId,
    required String homeBranchId,
    required String memberCode,
    required String fullName,
    String? email,
    String? phone,
    String? emergencyContactName,
    String? emergencyContactPhone,
  });

  Future<Result<MemberModel>> updateMember({
    required String orgId,
    required String memberId,
    required String homeBranchId,
    required String fullName,
    String? email,
    String? phone,
    String? emergencyContactName,
    String? emergencyContactPhone,
  });

  Future<Result<void>> updateMyMemberContact({
    required String orgId,
    String? phone,
    String? emergencyContactName,
    String? emergencyContactPhone,
  });

  Future<Result<void>> setMemberStatus({
    required String orgId,
    required String memberId,
    required MemberStatus status,
    String? reason,
  });

  Future<Result<String>> inviteMemberClaim({
    required String orgId,
    required String memberId,
    required String email,
  });
}
