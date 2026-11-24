import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_env_provider.dart';
import '../../../core/demo/demo_sandbox_engine.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/errors/error_mapper.dart';
import '../../../core/network/supabase_provider.dart';
import '../../../core/result/result.dart';
import '../domain/auth_repository.dart';
import '../domain/auth_session_state.dart';
import '../domain/auth_user.dart';
import '../domain/workspace_context.dart';
import '../infrastructure/demo_sandbox_auth_repository.dart';
import '../infrastructure/supabase_auth_repository.dart';

/// Explicit runtime mode distinguishing live Supabase, local non-production
/// Demo Sandbox, and unconfigured setup guidance.
enum AppMode { unconfigured, supabase, demoSandbox }

final appModeProvider = Provider<AppMode>((ref) {
  final env = ref.watch(appEnvProvider);
  if (env.hasSupabaseConfig) {
    return AppMode.supabase;
  }
  if (!env.isProduction && env.enableDemoMode) {
    return AppMode.demoSandbox;
  }
  return AppMode.unconfigured;
});

final authRepositoryProvider = Provider<AuthRepository?>((ref) {
  final mode = ref.watch(appModeProvider);
  switch (mode) {
    case AppMode.supabase:
      final client = ref.watch(supabaseClientProvider);
      if (client == null) {
        return null;
      }
      return SupabaseAuthRepository(client);
    case AppMode.demoSandbox:
      final engine = ref.watch(demoSandboxEngineProvider);
      return DemoSandboxAuthRepository(engine);
    case AppMode.unconfigured:
      return null;
  }
});

/// Holds the active organization/branch/role context for the signed-in session.
class ActiveWorkspaceNotifier extends Notifier<WorkspaceContext?> {
  @override
  WorkspaceContext? build() => null;

  void select(WorkspaceContext workspace) {
    state = workspace;
  }

  void clear() {
    state = null;
  }
}

final activeWorkspaceProvider =
    NotifierProvider<ActiveWorkspaceNotifier, WorkspaceContext?>(
      ActiveWorkspaceNotifier.new,
    );

/// Convenience permission lookup bound to the currently selected workspace.
final hasPermissionProvider = Provider.family<bool, String>((ref, permission) {
  final workspace = ref.watch(activeWorkspaceProvider);
  return workspace?.hasPermission(permission) ?? false;
});

/// Coordinates authentication state, user profile loading, and multi-role
/// workspace discovery.
class AuthController extends AsyncNotifier<AuthSessionState> {
  StreamSubscription<AuthUser?>? _authSubscription;
  String? _loadingUserId;

  @override
  Future<AuthSessionState> build() async {
    final repo = ref.watch(authRepositoryProvider);
    if (repo == null) {
      return const AuthSessionState.unauthenticated();
    }

    await _authSubscription?.cancel();
    _authSubscription = repo.watchAuthChanges().listen((user) {
      if (user == null) {
        _loadingUserId = null;
        ref.read(activeWorkspaceProvider.notifier).clear();
        state = const AsyncData<AuthSessionState>(
          AuthSessionState.unauthenticated(),
        );
      } else {
        final current = state.asData?.value;
        final alreadyLoaded =
            current is AuthenticatedSession && current.user.id == user.id;
        if (!alreadyLoaded && _loadingUserId != user.id) {
          unawaited(_loadAuthenticatedSession(repo, user));
        }
      }
    });

    ref.onDispose(() {
      unawaited(_authSubscription?.cancel());
    });

    final userResult = await repo.getCurrentUser();
    return userResult.when(
      success: (user) async {
        if (user == null) {
          return const AuthSessionState.unauthenticated();
        }
        return _resolveSessionData(repo, user);
      },
      failure: (_) => const AuthSessionState.unauthenticated(),
    );
  }

  Future<Result<void>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final repo = ref.read(authRepositoryProvider);
    if (repo == null) {
      return const Failure<void>(
        AppFailure.validation(message: 'Backend is not configured.'),
      );
    }

    final result = await repo.signInWithEmail(email: email, password: password);
    return result.when(
      success: (user) async {
        await _loadAuthenticatedSession(repo, user);
        return const Success<void>(null);
      },
      failure: Failure<void>.new,
    );
  }

  Future<Result<void>> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final repo = ref.read(authRepositoryProvider);
    if (repo == null) {
      return const Failure<void>(
        AppFailure.validation(message: 'Backend is not configured.'),
      );
    }

    final result = await repo.signUpWithEmail(
      email: email,
      password: password,
      fullName: fullName,
    );
    return result.when(
      success: (user) async {
        await _loadAuthenticatedSession(repo, user);
        return const Success<void>(null);
      },
      failure: Failure<void>.new,
    );
  }

  Future<Result<void>> sendPasswordResetEmail({required String email}) async {
    final repo = ref.read(authRepositoryProvider);
    if (repo == null) {
      return const Failure<void>(
        AppFailure.validation(message: 'Backend is not configured.'),
      );
    }
    return repo.sendPasswordResetEmail(email: email);
  }

  Future<Result<void>> signOut() async {
    final repo = ref.read(authRepositoryProvider);
    if (repo == null) {
      return const Success<void>(null);
    }
    final result = await repo.signOut();
    return result.when(
      success: (_) {
        ref.read(activeWorkspaceProvider.notifier).clear();
        state = const AsyncData<AuthSessionState>(
          AuthSessionState.unauthenticated(),
        );
        return const Success<void>(null);
      },
      failure: Failure<void>.new,
    );
  }

  Future<Result<void>> updateProfile({
    required String fullName,
    String? phone,
  }) async {
    final repo = ref.read(authRepositoryProvider);
    final current = state.asData?.value;
    if (repo == null || current is! AuthenticatedSession) {
      return const Failure<void>(AppFailure.unauthorized());
    }

    final result = await repo.updateProfile(
      userId: current.user.id,
      fullName: fullName,
      phone: phone,
    );
    return result.when(
      success: (updatedProfile) {
        state = AsyncData<AuthSessionState>(
          current.copyWith(profile: updatedProfile),
        );
        return const Success<void>(null);
      },
      failure: Failure<void>.new,
    );
  }

  Future<Result<void>> acceptInvitation(String token) async {
    final repo = ref.read(authRepositoryProvider);
    final current = state.asData?.value;
    if (repo == null || current is! AuthenticatedSession) {
      return const Failure<void>(AppFailure.unauthorized());
    }

    final result = await repo.acceptOrganizationInvitation(token);
    return result.when(
      success: (_) async {
        await refreshWorkspaces();
        return const Success<void>(null);
      },
      failure: Failure<void>.new,
    );
  }

  Future<Result<void>> claimMemberProfile(String token) async {
    final repo = ref.read(authRepositoryProvider);
    final current = state.asData?.value;
    if (repo == null || current is! AuthenticatedSession) {
      return const Failure<void>(AppFailure.unauthorized());
    }

    final result = await repo.claimMemberProfile(token);
    return result.when(
      success: (_) async {
        await refreshWorkspaces();
        return const Success<void>(null);
      },
      failure: Failure<void>.new,
    );
  }

  Future<void> refreshWorkspaces() async {
    final repo = ref.read(authRepositoryProvider);
    final current = state.asData?.value;
    if (repo == null || current is! AuthenticatedSession) {
      return;
    }
    await _loadAuthenticatedSession(repo, current.user);
  }

  Future<void> _loadAuthenticatedSession(
    AuthRepository repo,
    AuthUser user,
  ) async {
    _loadingUserId = user.id;
    state = const AsyncLoading<AuthSessionState>();
    try {
      state = await AsyncValue.guard(() => _resolveSessionData(repo, user));
    } finally {
      if (_loadingUserId == user.id) {
        _loadingUserId = null;
      }
    }
  }

  Future<AuthSessionState> _resolveSessionData(
    AuthRepository repo,
    AuthUser user,
  ) async {
    final profileResult = await repo.fetchProfile(user.id);
    final workspacesResult = await repo.fetchWorkspaces();

    final profile = profileResult.when(
      success: (p) => p,
      failure: (f) => throw AppException(f),
    );
    final workspaces = workspacesResult.when(
      success: (w) => w,
      failure: (f) => throw AppException(f),
    );

    final active = ref.read(activeWorkspaceProvider);
    if (workspaces.length == 1) {
      ref.read(activeWorkspaceProvider.notifier).select(workspaces.first);
    } else if (active != null) {
      final matching = workspaces
          .where((w) => w.contextKey == active.contextKey)
          .firstOrNull;
      if (matching != null) {
        ref.read(activeWorkspaceProvider.notifier).select(matching);
      } else {
        ref.read(activeWorkspaceProvider.notifier).clear();
      }
    }

    return AuthSessionState.authenticated(
      user: user,
      profile: profile,
      workspaces: workspaces,
    );
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, AuthSessionState>(AuthController.new);
