import '../../../core/demo/demo_sandbox_engine.dart';
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
/// Backed by [DemoSandboxEngine] so workspace state stays consistent across
/// organization creation, invitations, member claims, and operational slices.
class DemoSandboxAuthRepository extends BaseRepository
    implements AuthRepository {
  DemoSandboxAuthRepository(this._engine)
    : super(loggerName: 'demo_sandbox_auth');

  final DemoSandboxEngine _engine;

  @override
  Stream<AuthUser?> watchAuthChanges() => _engine.authStreamController.stream;

  @override
  Future<Result<AuthUser?>> getCurrentUser() =>
      guard(() async => _engine.currentUser, operation: 'demo.getCurrentUser');

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

      final user = _engine.usersByEmail[normalized];
      if (user == null) {
        throw const AppException(
          AppFailure.unauthorized(
            message: 'Unknown Demo Sandbox email. Try owner@ritma.demo or member@ritma.demo.',
          ),
        );
      }

      _engine.currentUser = user;
      _engine.authStreamController.add(user);
      return user;
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
      _engine.usersByEmail[normalized] = newUser;
      _engine.profiles[newUser.id] = UserProfile(
        userId: newUser.id,
        fullName: fullName.trim(),
      );
      _engine.workspacesByUser[newUser.id] = <WorkspaceContext>[];
      _engine.currentUser = newUser;
      _engine.authStreamController.add(newUser);
      return newUser;
    }, operation: 'demo.signUpWithEmail');
  }

  @override
  Future<Result<void>> signOut() {
    return guard(() async {
      _engine.currentUser = null;
      _engine.authStreamController.add(null);
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
      return _engine.profiles[userId] ?? UserProfile(userId: userId);
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
      _engine.profiles[userId] = updated;
      return updated;
    }, operation: 'demo.updateProfile');
  }

  @override
  Future<Result<List<WorkspaceContext>>> fetchWorkspaces() {
    return guard(() async {
      final user = _engine.currentUser;
      if (user == null) {
        return const <WorkspaceContext>[];
      }
      return List<WorkspaceContext>.unmodifiable(
        _engine.workspacesByUser[user.id] ?? const <WorkspaceContext>[],
      );
    }, operation: 'demo.fetchWorkspaces');
  }

  @override
  Future<Result<void>> acceptOrganizationInvitation(String token) {
    return guard(() async {
      _engine.acceptInvitation(token);
    }, operation: 'demo.acceptOrganizationInvitation');
  }

  @override
  Future<Result<void>> claimMemberProfile(String token) {
    return guard(() async {
      _engine.claimMemberProfile(token);
    }, operation: 'demo.claimMemberProfile');
  }
}
