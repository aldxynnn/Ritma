import 'dart:async';

import '../../../core/errors/app_failure.dart';
import '../../../core/errors/error_mapper.dart';
import '../../../core/repository/base_repository.dart';
import '../../../core/result/result.dart';
import '../domain/auth_repository.dart';
import '../domain/auth_user.dart';
import '../domain/user_profile.dart';
import '../domain/workspace_context.dart';

/// Non-production local preview repository used ONLY when `ENABLE_DEMO_MODE=true`
/// in non-production environments without live Supabase credentials.
///
/// Clearly identified as Demo Sandbox across the UI; never used in `prod`.
class DemoSandboxAuthRepository extends BaseRepository
    implements AuthRepository {
  DemoSandboxAuthRepository() : super(loggerName: 'demo_sandbox_auth');

  final StreamController<AuthUser?> _authController =
      StreamController<AuthUser?>.broadcast();

  AuthUser? _currentUser;
  final Map<String, UserProfile> _profiles = <String, UserProfile>{
    _ownerUser.id: const UserProfile(
      userId: 'demo-user-hybrid',
      fullName: 'Alina Santoso',
      phone: '+62-812-0000-0100',
    ),
    _memberUser.id: const UserProfile(
      userId: 'demo-user-member',
      fullName: 'Raka Pratama',
      phone: '+62-812-0000-0200',
    ),
    _emptyUser.id: const UserProfile(
      userId: 'demo-user-new',
      fullName: 'Nadia Wijaya',
    ),
  };

  final Map<String, List<WorkspaceContext>> _workspacesByUser =
      <String, List<WorkspaceContext>>{
        _ownerUser.id: List<WorkspaceContext>.of(_hybridDemoWorkspaces),
        _memberUser.id: List<WorkspaceContext>.of(_memberOnlyDemoWorkspaces),
        _emptyUser.id: <WorkspaceContext>[],
      };

  static const AuthUser _ownerUser = AuthUser(
    id: 'demo-user-hybrid',
    email: 'owner@ritma.demo',
    fullName: 'Alina Santoso',
  );

  static const AuthUser _memberUser = AuthUser(
    id: 'demo-user-member',
    email: 'member@ritma.demo',
    fullName: 'Raka Pratama',
  );

  static const AuthUser _emptyUser = AuthUser(
    id: 'demo-user-new',
    email: 'new@ritma.demo',
    fullName: 'Nadia Wijaya',
  );

  static const List<WorkspaceContext> _hybridDemoWorkspaces =
      <WorkspaceContext>[
        WorkspaceContext(
          organizationId: '11111111-1111-1111-1111-111111111111',
          organizationName: 'Ritma Flagship Club',
          roleCode: 'org_owner',
          roleDisplayName: 'Organization Owner',
          roleRank: 100,
          permissions: <String>[
            'org.manage',
            'branch.manage',
            'role.assign',
            'audit.read',
            'member.read',
            'member.write',
            'package.manage',
            'entitlement.read',
            'entitlement.assign',
            'credit.adjust',
            'payment.read',
            'payment.record',
            'payment.refund',
            'checkin.perform',
            'checkin.read',
            'checkin.force_override',
            'schedule.manage',
            'booking.read',
            'booking.manage',
            'attendance.mark',
            'dashboard.org.read',
            'dashboard.branch.read',
          ],
        ),
        WorkspaceContext(
          organizationId: '11111111-1111-1111-1111-111111111111',
          organizationName: 'Ritma Flagship Club',
          branchId: '22222222-2222-2222-2222-222222222201',
          branchName: 'Downtown Studio',
          roleCode: 'branch_manager',
          roleDisplayName: 'Branch Manager',
          roleRank: 60,
          permissions: <String>[
            'role.assign',
            'audit.read',
            'member.read',
            'member.write',
            'entitlement.read',
            'entitlement.assign',
            'credit.adjust',
            'payment.read',
            'payment.record',
            'checkin.perform',
            'checkin.read',
            'checkin.force_override',
            'schedule.manage',
            'booking.read',
            'booking.manage',
            'attendance.mark',
            'dashboard.branch.read',
          ],
        ),
        WorkspaceContext(
          organizationId: '11111111-1111-1111-1111-111111111111',
          organizationName: 'Ritma Flagship Club',
          branchId: '22222222-2222-2222-2222-222222222202',
          branchName: 'Westside Athletic',
          roleCode: 'instructor',
          roleDisplayName: 'Fitness Instructor',
          roleRank: 30,
          permissions: <String>['attendance.mark'],
        ),
        WorkspaceContext(
          organizationId: '11111111-1111-1111-1111-111111111111',
          organizationName: 'Ritma Flagship Club',
          branchId: '22222222-2222-2222-2222-222222222201',
          branchName: 'Downtown Studio',
          roleCode: 'member',
          roleDisplayName: 'Fitness Member',
          roleRank: 10,
          memberId: '99999999-9999-9999-9999-999999999901',
          permissions: <String>['member.self'],
        ),
      ];

  static const List<WorkspaceContext> _memberOnlyDemoWorkspaces =
      <WorkspaceContext>[
        WorkspaceContext(
          organizationId: '11111111-1111-1111-1111-111111111111',
          organizationName: 'Ritma Flagship Club',
          branchId: '22222222-2222-2222-2222-222222222201',
          branchName: 'Downtown Studio',
          roleCode: 'member',
          roleDisplayName: 'Fitness Member',
          roleRank: 10,
          memberId: '99999999-9999-9999-9999-999999999902',
          permissions: <String>['member.self'],
        ),
      ];

  @override
  Stream<AuthUser?> watchAuthChanges() => _authController.stream;

  @override
  Future<Result<AuthUser?>> getCurrentUser() =>
      guard(() async => _currentUser, operation: 'demo.getCurrentUser');

  @override
  Future<Result<AuthUser>> signInWithEmail({
    required String email,
    required String password,
  }) {
    return guard(() async {
      final normalized = email.trim().toLowerCase();
      if (password.length < 6) {
        throw const AppException(
          AppFailure.validation(
            message: 'Password must be at least 6 characters.',
          ),
        );
      }

      if (normalized == _ownerUser.email) {
        _currentUser = _ownerUser;
      } else if (normalized == _memberUser.email) {
        _currentUser = _memberUser;
      } else if (normalized == _emptyUser.email) {
        _currentUser = _emptyUser;
      } else {
        throw const AppException(
          AppFailure.unauthorized(
            message: 'Unknown Demo Sandbox email. Try owner@ritma.demo or member@ritma.demo.',
          ),
        );
      }

      _authController.add(_currentUser);
      return _currentUser!;
    }, operation: 'demo.signInWithEmail');
  }

  @override
  Future<Result<AuthUser>> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  }) {
    return guard(() async {
      final normalized = email.trim().toLowerCase();
      if (password.length < 6) {
        throw const AppException(
          AppFailure.validation(
            message: 'Password must be at least 6 characters.',
          ),
        );
      }
      final newUser = AuthUser(
        id: 'demo-user-${normalized.hashCode.abs()}',
        email: normalized,
        fullName: fullName.trim(),
      );
      _profiles[newUser.id] = UserProfile(
        userId: newUser.id,
        fullName: fullName.trim(),
      );
      _workspacesByUser[newUser.id] = <WorkspaceContext>[];
      _currentUser = newUser;
      _authController.add(newUser);
      return newUser;
    }, operation: 'demo.signUpWithEmail');
  }

  @override
  Future<Result<void>> signOut() {
    return guard(() async {
      _currentUser = null;
      _authController.add(null);
    }, operation: 'demo.signOut');
  }

  @override
  Future<Result<void>> sendPasswordResetEmail({required String email}) {
    return guard(() async {
      if (!email.contains('@')) {
        throw const AppException(
          AppFailure.validation(message: 'Enter a valid email address.'),
        );
      }
    }, operation: 'demo.sendPasswordResetEmail');
  }

  @override
  Future<Result<UserProfile>> fetchProfile(String userId) {
    return guard(() async {
      return _profiles[userId] ?? UserProfile(userId: userId);
    }, operation: 'demo.fetchProfile');
  }

  @override
  Future<Result<UserProfile>> updateProfile({
    required String userId,
    required String fullName,
    String? phone,
  }) {
    return guard(() async {
      final updated = UserProfile(
        userId: userId,
        fullName: fullName.trim(),
        phone: phone?.trim().isEmpty ?? true ? null : phone!.trim(),
      );
      _profiles[userId] = updated;
      return updated;
    }, operation: 'demo.updateProfile');
  }

  @override
  Future<Result<List<WorkspaceContext>>> fetchWorkspaces() {
    return guard(() async {
      final user = _currentUser;
      if (user == null) {
        return const <WorkspaceContext>[];
      }
      return List<WorkspaceContext>.unmodifiable(
        _workspacesByUser[user.id] ?? const <WorkspaceContext>[],
      );
    }, operation: 'demo.fetchWorkspaces');
  }

  @override
  Future<Result<void>> acceptOrganizationInvitation(String token) {
    return guard(() async {
      final user = _currentUser;
      if (user == null) {
        throw const AppException(AppFailure.unauthorized());
      }
      if (token.trim() != 'DEMO-STAFF-INVITE') {
        throw const AppException(
          AppFailure.validation(
            message:
                'Invalid Demo Sandbox invite token (try DEMO-STAFF-INVITE).',
          ),
        );
      }
      final existing = _workspacesByUser[user.id] ?? <WorkspaceContext>[];
      existing.add(_hybridDemoWorkspaces[1]);
      _workspacesByUser[user.id] = existing;
    }, operation: 'demo.acceptOrganizationInvitation');
  }

  @override
  Future<Result<void>> claimMemberProfile(String token) {
    return guard(() async {
      final user = _currentUser;
      if (user == null) {
        throw const AppException(AppFailure.unauthorized());
      }
      if (token.trim() != 'DEMO-MEMBER-CLAIM') {
        throw const AppException(
          AppFailure.validation(
            message:
                'Invalid Demo Sandbox claim token (try DEMO-MEMBER-CLAIM).',
          ),
        );
      }
      final existing = _workspacesByUser[user.id] ?? <WorkspaceContext>[];
      existing.add(_memberOnlyDemoWorkspaces.first);
      _workspacesByUser[user.id] = existing;
    }, operation: 'demo.claimMemberProfile');
  }

  void dispose() {
    unawaited(_authController.close());
  }
}
