import 'package:freezed_annotation/freezed_annotation.dart';

import 'auth_user.dart';
import 'user_profile.dart';
import 'workspace_context.dart';

part 'auth_session_state.freezed.dart';

@freezed
sealed class AuthSessionState with _$AuthSessionState {
  const factory AuthSessionState.unauthenticated() = UnauthenticatedSession;

  const factory AuthSessionState.authenticated({
    required AuthUser user,
    required UserProfile profile,
    required List<WorkspaceContext> workspaces,
  }) = AuthenticatedSession;
}
