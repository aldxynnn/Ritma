import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ritma/app/app.dart';
import 'package:ritma/core/config/app_env.dart';
import 'package:ritma/core/config/app_env_provider.dart';
import 'package:ritma/core/result/result.dart';
import 'package:ritma/core/theme/ritma_spacing.dart';
import 'package:ritma/core/theme/ritma_theme.dart';
import 'package:ritma/core/theme/theme_mode_provider.dart';
import 'package:ritma/features/auth/application/auth_providers.dart';
import 'package:ritma/features/auth/domain/auth_repository.dart';
import 'package:ritma/features/auth/domain/auth_session_state.dart';
import 'package:ritma/features/auth/domain/auth_user.dart';
import 'package:ritma/features/auth/domain/user_profile.dart';
import 'package:ritma/features/auth/domain/workspace_context.dart';
import 'package:ritma/features/auth/presentation/sign_in_screen.dart';
import 'package:ritma/features/facility_access/presentation/front_desk_checkin_view.dart';
import 'package:ritma/features/members/presentation/members_directory_view.dart';
import 'package:ritma/features/packages/domain/package_models.dart';
import 'package:ritma/features/packages/presentation/packages_catalog_view.dart';

void main() {
  const demoEnv = AppEnv(
    environment: AppEnvironment.dev,
    appName: 'RITMA',
    supabaseUrl: '',
    supabaseAnonKey: '',
    enableDebugLogging: false,
    enableDemoMode: true,
  );

  const cloudDevEnv = AppEnv(
    environment: AppEnvironment.dev,
    appName: 'RITMA',
    supabaseUrl: 'https://demo.supabase.co',
    supabaseAnonKey: 'sb_publishable_demo_only',
    enableDebugLogging: false,
    enableDemoMode: false,
  );

  const cloudProdEnv = AppEnv(
    environment: AppEnvironment.prod,
    appName: 'RITMA',
    supabaseUrl: 'https://prod.supabase.co',
    supabaseAnonKey: 'sb_publishable_prod_only',
    enableDebugLogging: false,
    enableDemoMode: true,
  );

  Future<ProviderContainer> signInDemoOwner() async {
    final container = ProviderContainer(
      overrides: [appEnvProvider.overrideWithValue(demoEnv)],
    );
    await container.read(authControllerProvider.future);
    await container
        .read(authControllerProvider.notifier)
        .signInWithEmail(email: 'owner@ritma.demo', password: 'RitmaDemo1!');
    final authed =
        container.read(authControllerProvider).asData!.value
            as AuthenticatedSession;
    final ownerWs = authed.workspaces.firstWhere(
      (w) => w.roleCode == 'org_owner',
    );
    container.read(activeWorkspaceProvider.notifier).select(ownerWs);
    return container;
  }

  testWidgets(
    'ThemeModeNotifier defaults to dark and toggles to light inside RitmaApp',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final container = ProviderContainer(
        overrides: [appEnvProvider.overrideWithValue(demoEnv)],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const RitmaApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(container.read(themeModeProvider), ThemeMode.dark);
      await tester.tap(find.byTooltip('Switch to light theme'));
      await tester.pumpAndSettle();
      expect(container.read(themeModeProvider), ThemeMode.light);
      expect(find.byTooltip('Switch to dark theme'), findsOneWidget);
    },
  );

  testWidgets(
    'SignInScreen renders Cloud showcase shortcuts in dev and strips them in prod',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final dummyRepo = _IdleAuthRepository();
      addTearDown(dummyRepo.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appEnvProvider.overrideWithValue(cloudDevEnv),
            authRepositoryProvider.overrideWithValue(dummyRepo),
          ],
          child: MaterialApp(
            theme: RitmaTheme.dark(),
            home: const SignInScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Showcase Demo Accounts (Live Cloud)'), findsOneWidget);
      expect(
        find.text('One platform.\nEvery fitness business.'),
        findsOneWidget,
      );

      await tester.tap(find.text('Owner (Multi-Role)'));
      await tester.pump();
      expect(find.text('demo.owner@ritma.app'), findsOneWidget);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appEnvProvider.overrideWithValue(cloudProdEnv),
            authRepositoryProvider.overrideWithValue(dummyRepo),
          ],
          child: MaterialApp(
            theme: RitmaTheme.dark(),
            home: const SignInScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Showcase Demo Accounts (Live Cloud)'), findsNothing);
      expect(find.text('Quick Demo Sandbox Accounts'), findsNothing);
    },
  );

  testWidgets(
    'PackagesCatalogView validates empty input inline and creates PT Pack cleanly',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final container = await signInDemoOwner();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: RitmaTheme.dark(density: RitmaDensity.operations),
            home: const Scaffold(body: PackagesCatalogView()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('New Package'));
      await tester.pumpAndSettle();

      // Submit without package name -> inline validation banner inside dialog
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();
      expect(find.text('Please fix the highlighted fields.'), findsOneWidget);
      expect(find.text('Enter at least 2 characters.'), findsOneWidget);

      // Switch package type to PT Pack
      await tester.tap(find.text('Gym Membership').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text(PackageType.ptPack.label).last);
      await tester.pumpAndSettle();
      expect(find.text('Included PT Credits'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Package Name'),
        'Elite 1-on-1 Pack',
      );
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      expect(find.text('Package "Elite 1-on-1 Pack" created.'), findsOneWidget);
      expect(find.text('Elite 1-on-1 Pack'), findsOneWidget);
    },
  );

  testWidgets(
    'MembersDirectoryView validates Register dialog inline and shows confirmation',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final container = await signInDemoOwner();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: RitmaTheme.dark(density: RitmaDensity.operations),
            home: const Scaffold(body: MembersDirectoryView()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      // Empty submit must show validation feedback, not silently return
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.widgetWithText(FilledButton, 'Register'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Please fix the highlighted fields.'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Full Name'),
        'Sari Dewi',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Member Code (e.g. RTM-2001)'),
        'RTM-9999',
      );
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.widgetWithText(FilledButton, 'Register'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Member "Sari Dewi" registered.'), findsOneWidget);
      expect(find.text('Sari Dewi'), findsOneWidget);
    },
  );

  testWidgets(
    'FrontDeskCheckInView renders cleanly at phone (360x740) and split (649x629) widths without overflow',
    (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final container = await signInDemoOwner();
      addTearDown(container.dispose);

      for (final size in const [Size(360, 740), Size(649, 629)]) {
        await tester.binding.setSurfaceSize(size);
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              theme: RitmaTheme.dark(density: RitmaDensity.operations),
              home: const Scaffold(body: FrontDeskCheckInView()),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Front-Desk Facility Check-In'), findsOneWidget);
        expect(find.text('Recent Branch Visits'), findsOneWidget);

        // Trigger Manual Member Lookup so lookup result rows render under narrow constraints too.
        await tester.enterText(
          find.widgetWithText(TextField, 'Name or Member Code'),
          'RTM',
        );
        await tester.ensureVisible(find.text('Search'));
        await tester.tap(find.text('Search'));
        await tester.pumpAndSettle();
        expect(find.text('Check In'), findsWidgets);
        expect(tester.takeException(), isNull);
      }
    },
  );
}

class _IdleAuthRepository implements AuthRepository {
  final StreamController<AuthUser?> _ctrl =
      StreamController<AuthUser?>.broadcast();

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
  }) async => throw UnimplementedError();

  @override
  Future<Result<AuthUser>> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  }) async => throw UnimplementedError();

  @override
  Future<Result<void>> signOut() async => const Success(null);

  @override
  Future<Result<void>> sendPasswordResetEmail({required String email}) async =>
      const Success(null);

  @override
  Future<Result<UserProfile>> fetchProfile(String userId) async =>
      Success(UserProfile(userId: userId));

  @override
  Future<Result<UserProfile>> updateProfile({
    required String userId,
    required String fullName,
    String? phone,
  }) async => throw UnimplementedError();

  @override
  Future<Result<List<WorkspaceContext>>> fetchWorkspaces() async =>
      const Success(<WorkspaceContext>[]);

  @override
  Future<Result<void>> acceptOrganizationInvitation(String token) async =>
      const Success(null);

  @override
  Future<Result<void>> claimMemberProfile(String token) async =>
      const Success(null);
}
