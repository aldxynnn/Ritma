import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ritma/core/config/app_env.dart';
import 'package:ritma/core/config/app_env_provider.dart';
import 'package:ritma/core/errors/app_failure.dart';
import 'package:ritma/core/errors/error_mapper.dart';
import 'package:ritma/core/result/result.dart';
import 'package:ritma/features/auth/application/auth_providers.dart';
import 'package:ritma/features/auth/domain/auth_repository.dart';
import 'package:ritma/features/auth/domain/auth_session_state.dart';
import 'package:ritma/features/auth/domain/auth_user.dart';
import 'package:ritma/features/auth/domain/ritma_role.dart';
import 'package:ritma/features/auth/domain/user_profile.dart';
import 'package:ritma/features/auth/domain/workspace_context.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show AuthException, PostgrestException;

void main() {
  const demoEnv = AppEnv(
    environment: AppEnvironment.dev,
    appName: 'RITMA',
    supabaseUrl: '',
    supabaseAnonKey: '',
    enableDebugLogging: false,
    enableDemoMode: true,
  );

  group('RitmaRole & WorkspaceContext', () {
    test('maps role codes and distinguishes Member vs Operations surfaces', () {
      expect(RitmaRole.fromCode('org_owner').isOperationsSurface, isTrue);
      expect(RitmaRole.fromCode('instructor').isOperationsSurface, isTrue);
      expect(RitmaRole.fromCode('member').isOperationsSurface, isFalse);
      expect(RitmaRole.fromCode('unknown_code'), RitmaRole.member);
    });

    test('round-trips WorkspaceContext via JSON and checks permissions', () {
      const original = WorkspaceContext(
        organizationId: 'org-1',
        organizationName: 'Ritma Club',
        branchId: 'br-1',
        branchName: 'Downtown',
        roleCode: 'branch_manager',
        roleDisplayName: 'Branch Manager',
        roleRank: 60,
        permissions: <String>['checkin.perform', 'dashboard.branch.read'],
      );

      final decoded = WorkspaceContext.fromJson(original.toJson());
      expect(decoded, equals(original));
      expect(decoded.isOperationsSurface, isTrue);
      expect(decoded.hasPermission('checkin.perform'), isTrue);
      expect(decoded.hasPermission('org.manage'), isFalse);
      expect(decoded.scopeLabel, 'Downtown');
    });
  });

  group('AuthController (Demo Sandbox)', () {
    test(
      'supports sign-in, workspace selection, profile update, and sign-out',
      () async {
        final container = ProviderContainer(
          overrides: [appEnvProvider.overrideWithValue(demoEnv)],
        );
        addTearDown(container.dispose);

        expect(container.read(appModeProvider), AppMode.demoSandbox);

        final initial = await container.read(authControllerProvider.future);
        expect(initial, isA<UnauthenticatedSession>());

        final controller = container.read(authControllerProvider.notifier);
        final signInRes = await controller.signInWithEmail(
          email: 'owner@ritma.demo',
          password: 'RitmaDemo1!',
        );
        expect(signInRes.isSuccess, isTrue);

        final authState = container.read(authControllerProvider).asData?.value;
        expect(authState, isA<AuthenticatedSession>());
        final authed = authState! as AuthenticatedSession;
        expect(authed.workspaces.length, 4);

        // Multiple workspaces require explicit context choice
        expect(container.read(activeWorkspaceProvider), isNull);

        container
            .read(activeWorkspaceProvider.notifier)
            .select(authed.workspaces.first);
        expect(container.read(hasPermissionProvider('org.manage')), isTrue);

        final updateRes = await controller.updateProfile(
          fullName: 'Alina Updated',
          phone: '+62-811-9999',
        );
        expect(updateRes.isSuccess, isTrue);
        final afterUpdate =
            container.read(authControllerProvider).asData?.value
                as AuthenticatedSession;
        expect(afterUpdate.profile.fullName, 'Alina Updated');

        final signOutRes = await controller.signOut();
        expect(signOutRes.isSuccess, isTrue);
        expect(
          container.read(authControllerProvider).asData?.value,
          isA<UnauthenticatedSession>(),
        );
        expect(container.read(activeWorkspaceProvider), isNull);
      },
    );

    test('redeems Demo Sandbox staff invite & member claim tokens', () async {
      final container = ProviderContainer(
        overrides: [appEnvProvider.overrideWithValue(demoEnv)],
      );
      addTearDown(container.dispose);

      await container.read(authControllerProvider.future);
      final controller = container.read(authControllerProvider.notifier);

      await controller.signInWithEmail(
        email: 'new@ritma.demo',
        password: 'RitmaDemo1!',
      );
      var authed =
          container.read(authControllerProvider).asData?.value
              as AuthenticatedSession;
      expect(authed.workspaces, isEmpty);

      final inviteRes = await controller.acceptInvitation('DEMO-STAFF-INVITE');
      expect(inviteRes.isSuccess, isTrue);

      authed =
          container.read(authControllerProvider).asData?.value
              as AuthenticatedSession;
      expect(authed.workspaces.length, 1);
      expect(
        container.read(activeWorkspaceProvider)?.roleCode,
        'branch_manager',
      );

      final claimRes = await controller.claimMemberProfile('DEMO-MEMBER-CLAIM');
      expect(claimRes.isSuccess, isTrue);
      authed =
          container.read(authControllerProvider).asData?.value
              as AuthenticatedSession;
      expect(authed.workspaces.length, 2);
    });
  });

  group('AuthController hardening & ErrorMapper', () {
    test(
      'signInWithEmail returns Failure when workspace resolution fails',
      () async {
        final repo = _FakeAuthRepository(failWorkspaces: true);
        addTearDown(repo.dispose);

        final container = ProviderContainer(
          overrides: [
            appEnvProvider.overrideWithValue(demoEnv),
            authRepositoryProvider.overrideWithValue(repo),
          ],
        );
        addTearDown(container.dispose);

        await container.read(authControllerProvider.future);
        final res = await container
            .read(authControllerProvider.notifier)
            .signInWithEmail(email: 'user@ritma.test', password: 'Password1!');

        expect(res.isFailure, isTrue);
        final failure = res.when(success: (_) => null, failure: (f) => f);
        expect(failure, isA<NetworkFailure>());
      },
    );

    test('deduplicates concurrent watchAuthChanges and signInWithEmail session loads', () async {
      final repo = _FakeAuthRepository(emitOnAuthChange: true);
      addTearDown(repo.dispose);

      final container = ProviderContainer(
        overrides: [
          appEnvProvider.overrideWithValue(demoEnv),
          authRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      await container.read(authControllerProvider.future);
      final res = await container
          .read(authControllerProvider.notifier)
          .signInWithEmail(email: 'user@ritma.test', password: 'Password1!');

      expect(res.isSuccess, isTrue);
      expect(repo.fetchWorkspacesCalls, 1);
      expect(
        container.read(authControllerProvider).asData?.value,
        isA<AuthenticatedSession>(),
      );
    });

    test('maps Supabase AuthException messages cleanly', () {
      final unconfirmed = ErrorMapper.map(
        const AuthException('Email not confirmed', statusCode: '400'),
      );
      expect(unconfirmed, isA<ValidationFailure>());
      expect(unconfirmed.message.toLowerCase(), contains('confirmed'));

      final badCreds = ErrorMapper.map(
        const AuthException('Invalid login credentials', statusCode: '400'),
      );
      expect(badCreds, isA<ValidationFailure>());
      expect(badCreds.message, 'Invalid email or password.');
    });

    test('maps PostgrestException permission denied without code to ForbiddenFailure', () {
      final failure = ErrorMapper.map(
        const PostgrestException(
          message: 'permission denied for table user_profiles',
        ),
      );
      expect(failure, isA<ForbiddenFailure>());
      expect(failure.message, 'permission denied for table user_profiles');
    });
  });
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({
    this.failWorkspaces = false,
    this.emitOnAuthChange = false,
  });

  final bool failWorkspaces;
  final bool emitOnAuthChange;
  final StreamController<AuthUser?> _ctrl =
      StreamController<AuthUser?>.broadcast();
  int fetchWorkspacesCalls = 0;

  static const AuthUser _user = AuthUser(
    id: 'user-fake-1',
    email: 'user@ritma.test',
    fullName: 'Fake User',
  );

  void dispose() {
    unawaited(_ctrl.close());
  }

  @override
  Stream<AuthUser?> watchAuthChanges() => _ctrl.stream;

  @override
  Future<Result<AuthUser?>> getCurrentUser() async => const Success(null);

  @override
  Future<Result<AuthUser>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (emitOnAuthChange) {
      _ctrl.add(_user);
    }
    return const Success(_user);
  }

  @override
  Future<Result<AuthUser>> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  }) async => const Success(_user);

  @override
  Future<Result<void>> signOut() async => const Success(null);

  @override
  Future<Result<void>> sendPasswordResetEmail({required String email}) async =>
      const Success(null);

  @override
  Future<Result<UserProfile>> fetchProfile(String userId) async =>
      const Success(UserProfile(userId: 'user-fake-1', fullName: 'Fake User'));

  @override
  Future<Result<UserProfile>> updateProfile({
    required String userId,
    required String fullName,
    String? phone,
  }) async =>
      Success(UserProfile(userId: userId, fullName: fullName, phone: phone));

  @override
  Future<Result<List<WorkspaceContext>>> fetchWorkspaces() async {
    fetchWorkspacesCalls += 1;
    await Future<void>.delayed(const Duration(milliseconds: 20));
    if (failWorkspaces) {
      return const Failure<List<WorkspaceContext>>(
        AppFailure.network(message: 'Simulated workspace fetch failure'),
      );
    }
    return const Success<List<WorkspaceContext>>(<WorkspaceContext>[]);
  }

  @override
  Future<Result<void>> acceptOrganizationInvitation(String token) async =>
      const Success(null);

  @override
  Future<Result<void>> claimMemberProfile(String token) async =>
      const Success(null);
}
