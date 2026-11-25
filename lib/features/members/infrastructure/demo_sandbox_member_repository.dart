import '../../../core/demo/demo_sandbox_engine.dart';
import '../../../core/repository/base_repository.dart';
import '../../../core/result/result.dart';
import '../domain/member_model.dart';
import '../domain/member_repository.dart';

class DemoSandboxMemberRepository extends BaseRepository
    implements MemberRepository {
  DemoSandboxMemberRepository(this._engine)
    : super(loggerName: 'demo_member_repo');

  final DemoSandboxEngine _engine;

  @override
  Future<Result<List<MemberModel>>> fetchMembers({
    required String orgId,
    String? branchId,
    String? query,
    MemberStatus? statusFilter,
  }) {
    return guard(() async {
      final q = query?.trim().toLowerCase();
      final list = _engine.members.values.where((m) {
        if (m.organizationId != orgId) {
          return false;
        }
        if (branchId != null && m.homeBranchId != branchId) {
          return false;
        }
        if (statusFilter != null && m.status != statusFilter) {
          return false;
        }
        if (q != null && q.isNotEmpty) {
          return m.fullName.toLowerCase().contains(q) ||
              m.memberCode.toLowerCase().contains(q) ||
              (m.email ?? '').toLowerCase().contains(q) ||
              (m.phone ?? '').toLowerCase().contains(q);
        }
        return true;
      }).toList()..sort((a, b) => a.fullName.compareTo(b.fullName));
      return list;
    }, operation: 'demo.fetchMembers');
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
    return guard(
      () async => _engine.registerMember(
        orgId: orgId,
        homeBranchId: homeBranchId,
        memberCode: memberCode,
        fullName: fullName,
        email: email,
        phone: phone,
        emergencyContactName: emergencyContactName,
        emergencyContactPhone: emergencyContactPhone,
      ),
      operation: 'demo.registerMember',
    );
  }

  @override
  Future<Result<MemberModel>> updateMember({
    required String orgId,
    required String memberId,
    required String homeBranchId,
    required String fullName,
    String? email,
    String? phone,
    String? emergencyContactName,
    String? emergencyContactPhone,
  }) {
    return guard(
      () async => _engine.updateMember(
        orgId: orgId,
        memberId: memberId,
        homeBranchId: homeBranchId,
        fullName: fullName,
        email: email,
        phone: phone,
        emergencyContactName: emergencyContactName,
        emergencyContactPhone: emergencyContactPhone,
      ),
      operation: 'demo.updateMember',
    );
  }

  @override
  Future<Result<void>> updateMyMemberContact({
    required String orgId,
    String? phone,
    String? emergencyContactName,
    String? emergencyContactPhone,
  }) {
    return guard(
      () async => _engine.updateMyMemberContact(
        orgId: orgId,
        phone: phone,
        emergencyContactName: emergencyContactName,
        emergencyContactPhone: emergencyContactPhone,
      ),
      operation: 'demo.updateMyMemberContact',
    );
  }

  @override
  Future<Result<void>> setMemberStatus({
    required String orgId,
    required String memberId,
    required MemberStatus status,
    String? reason,
  }) {
    return guard(
      () async => _engine.setMemberStatus(
        orgId: orgId,
        memberId: memberId,
        status: status,
      ),
      operation: 'demo.setMemberStatus',
    );
  }

  @override
  Future<Result<String>> inviteMemberClaim({
    required String orgId,
    required String memberId,
    required String email,
  }) {
    return guard(
      () async => _engine.inviteMemberClaim(
        orgId: orgId,
        memberId: memberId,
        email: email,
      ),
      operation: 'demo.inviteMemberClaim',
    );
  }
}
