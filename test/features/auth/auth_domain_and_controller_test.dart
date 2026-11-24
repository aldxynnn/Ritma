import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ritma/core/config/app_env.dart';
import 'package:ritma/core/config/app_env_provider.dart';
import 'package:ritma/features/auth/application/auth_providers.dart';
import 'package:ritma/features/auth/domain/auth_session_state.dart';
import 'package:ritma/features/auth/domain/ritma_role.dart';
import 'package:ritma/features/auth/domain/workspace_context.dart';

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
}
