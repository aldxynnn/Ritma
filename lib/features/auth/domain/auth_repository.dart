import '../../../core/result/result.dart';
import 'auth_user.dart';
import 'user_profile.dart';
import 'workspace_context.dart';

/// Backend-agnostic authentication, profile, and multi-role workspace contract.
abstract interface class AuthRepository {
  Stream<AuthUser?> watchAuthChanges();

  Future<Result<AuthUser?>> getCurrentUser();

  Future<Result<AuthUser>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<Result<AuthUser>> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  });

  Future<Result<void>> signOut();

  Future<Result<void>> sendPasswordResetEmail({required String email});

  Future<Result<UserProfile>> fetchProfile(String userId);

  Future<Result<UserProfile>> updateProfile({
    required String userId,
    required String fullName,
    String? phone,
  });

  Future<Result<List<WorkspaceContext>>> fetchWorkspaces();

  Future<Result<void>> acceptOrganizationInvitation(String token);

  Future<Result<void>> claimMemberProfile(String token);
}
