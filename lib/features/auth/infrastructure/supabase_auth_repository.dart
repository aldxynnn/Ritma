import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../../core/errors/app_failure.dart';
import '../../../core/errors/error_mapper.dart';
import '../../../core/repository/base_repository.dart';
import '../../../core/result/result.dart';
import '../domain/auth_repository.dart';
import '../domain/auth_user.dart';
import '../domain/user_profile.dart';
import '../domain/workspace_context.dart';

/// Production [AuthRepository] backed by Supabase Auth, `public.user_profiles`,
/// and `SECURITY DEFINER` multi-tenant RPCs.
class SupabaseAuthRepository extends BaseRepository implements AuthRepository {
  SupabaseAuthRepository(this._client)
    : super(loggerName: 'supabase_auth_repo');

  final sb.SupabaseClient _client;

  @override
  Stream<AuthUser?> watchAuthChanges() {
    return _client.auth.onAuthStateChange.map((event) {
      final user = event.session?.user;
      return user != null ? _mapUser(user) : null;
    });
  }

  @override
  Future<Result<AuthUser?>> getCurrentUser() {
    return guard(() async {
      final user = _client.auth.currentUser;
      return user != null ? _mapUser(user) : null;
    }, operation: 'getCurrentUser');
  }

  @override
  Future<Result<AuthUser>> signInWithEmail({
    required String email,
    required String password,
  }) {
    return guard(() async {
      final response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      final user = response.user;
      if (user == null) {
        throw const AppException(
          AppFailure.unauthorized(
            message: 'Unable to sign in with credentials.',
          ),
        );
      }
      return _mapUser(user);
    }, operation: 'signInWithEmail');
  }

  @override
  Future<Result<AuthUser>> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  }) {
    return guard(() async {
      final response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
        data: <String, dynamic>{'full_name': fullName.trim()},
      );
      final user = response.user;
      if (user == null) {
        throw const AppException(
          AppFailure.validation(message: 'Unable to complete sign up.'),
        );
      }
      if (response.session == null) {
        throw const AppException(
          AppFailure.validation(
            message: 'Confirmation email sent. Please verify your email and sign in.',
          ),
        );
      }
      return _mapUser(user);
    }, operation: 'signUpWithEmail');
  }

  @override
  Future<Result<void>> signOut() {
    return guard(() async {
      await _client.auth.signOut();
    }, operation: 'signOut');
  }

  @override
  Future<Result<void>> sendPasswordResetEmail({required String email}) {
    return guard(() async {
      await _client.auth.resetPasswordForEmail(email.trim());
    }, operation: 'sendPasswordResetEmail');
  }

  @override
  Future<Result<UserProfile>> fetchProfile(String userId) {
    return guard(() async {
      final row = await _client
          .from('user_profiles')
          .select('user_id, full_name, phone, avatar_path')
          .eq('user_id', userId)
          .maybeSingle();

      if (row == null) {
        return UserProfile(userId: userId);
      }
      return UserProfile.fromJson(Map<String, dynamic>.from(row));
    }, operation: 'fetchProfile');
  }

  @override
  Future<Result<UserProfile>> updateProfile({
    required String userId,
    required String fullName,
    String? phone,
  }) {
    return guard(() async {
      final payload = <String, dynamic>{
        'user_id': userId,
        'full_name': fullName.trim(),
        'phone': phone?.trim().isEmpty ?? true ? null : phone!.trim(),
      };
      final row = await _client
          .from('user_profiles')
          .upsert(payload)
          .select('user_id, full_name, phone, avatar_path')
          .single();
      return UserProfile.fromJson(Map<String, dynamic>.from(row));
    }, operation: 'updateProfile');
  }

  @override
  Future<Result<List<WorkspaceContext>>> fetchWorkspaces() {
    return guard(() async {
      final dynamic raw = await _client.rpc<dynamic>('get_my_workspaces');
      if (raw is! List<dynamic>) {
        return const <WorkspaceContext>[];
      }
      return raw
          .whereType<Map<dynamic, dynamic>>()
          .map(
            (item) =>
                WorkspaceContext.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    }, operation: 'fetchWorkspaces');
  }

  @override
  Future<Result<void>> acceptOrganizationInvitation(String token) {
    return guard(() async {
      await _client.rpc<dynamic>(
        'accept_organization_invitation',
        params: <String, dynamic>{'p_token': token.trim()},
      );
    }, operation: 'acceptOrganizationInvitation');
  }

  @override
  Future<Result<void>> claimMemberProfile(String token) {
    return guard(() async {
      await _client.rpc<dynamic>(
        'claim_member_profile',
        params: <String, dynamic>{'p_token': token.trim()},
      );
    }, operation: 'claimMemberProfile');
  }

  AuthUser _mapUser(sb.User user) {
    final metadata = user.userMetadata ?? const <String, dynamic>{};
    return AuthUser(
      id: user.id,
      email: user.email ?? '',
      fullName: metadata['full_name'] as String?,
    );
  }
}
