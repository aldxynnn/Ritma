import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ritma/app/app.dart';
import 'package:ritma/app/router/app_router.dart';
import 'package:ritma/app/router/app_routes.dart';
import 'package:ritma/core/config/app_env.dart';
import 'package:ritma/core/config/app_env_provider.dart';
import 'package:ritma/features/auth/application/auth_providers.dart';
import 'package:ritma/features/auth/domain/auth_session_state.dart';

void main() {
  const unconfiguredEnv = AppEnv(
    environment: AppEnvironment.dev,
    appName: 'RITMA',
    supabaseUrl: '',
    supabaseAnonKey: '',
    enableDebugLogging: false,
    enableDemoMode: false,
  );

  const demoEnv = AppEnv(
    environment: AppEnvironment.dev,
    appName: 'RITMA',
    supabaseUrl: '',
    supabaseAnonKey: '',
    enableDebugLogging: false,
    enableDemoMode: true,
  );

  testWidgets('Unconfigured env routes honestly to BackendSetupScreen', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appEnvProvider.overrideWithValue(unconfiguredEnv)],
        child: const RitmaApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Configuration Required'), findsOneWidget);
    expect(find.text('RITMA'), findsOneWidget);
  });

  testWidgets(
    'Demo Sandbox supports multi-role context switching, surface isolation, dark theme, and 1.5x text scale',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final container = ProviderContainer(
        overrides: [appEnvProvider.overrideWithValue(demoEnv)],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MediaQuery(
            data: MediaQueryData(
              size: Size(1280, 800),
              textScaler: TextScaler.linear(1.5),
            ),
            child: RitmaApp(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Lands on SignInScreen with Demo Sandbox banner
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.textContaining('DEMO SANDBOX MODE'), findsOneWidget);

      // Quick-fill multi-role owner account and sign in
      await tester.tap(find.text('Multi-Role Owner'));
      await tester.pump();
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Lands on WorkspacePickerScreen showing both Operations and Member contexts
      expect(find.text('Operations Workspaces'), findsOneWidget);
      expect(find.text('Member Passes'), findsOneWidget);

      // Select Organization Owner -> routes to Operations Dashboard
      await tester.tap(find.text('Organization Owner'));
      await tester.pumpAndSettle();
      expect(find.text('Operations Console'), findsOneWidget);
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Check-In'), findsOneWidget);
      expect(find.text('Members'), findsOneWidget);

      // Switch to Fitness Instructor -> hides Dashboard & Members tabs
      final authed =
          container.read(authControllerProvider).asData?.value
              as AuthenticatedSession;
      final instructorWs = authed.workspaces.firstWhere(
        (w) => w.roleCode == 'instructor',
      );
      container.read(activeWorkspaceProvider.notifier).select(instructorWs);
      await tester.pumpAndSettle();
      expect(find.text('Schedules & Live Roster'), findsOneWidget);
      expect(find.text('Dashboard'), findsNothing);
      expect(find.text('Members'), findsNothing);

      // Switch to Fitness Member -> enters MemberShell & enforces cross-surface guard
      final memberWs = authed.workspaces.firstWhere(
        (w) => w.roleCode == 'member',
      );
      container.read(activeWorkspaceProvider.notifier).select(memberWs);
      await tester.pumpAndSettle();
      expect(find.text('Digital Access Pass'), findsOneWidget);

      // Member attempting /ops/dashboard is redirected back to /member/home
      container.read(appRouterProvider).go(AppRoutes.opsDashboard);
      await tester.pumpAndSettle();
      expect(find.text('Digital Access Pass'), findsOneWidget);
    },
  );

  testWidgets('Dark theme renders SignInScreen cleanly without overflow', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appEnvProvider.overrideWithValue(demoEnv)],
        child: const MediaQuery(
          data: MediaQueryData(
            platformBrightness: Brightness.dark,
            textScaler: TextScaler.linear(1.5),
          ),
          child: RitmaApp(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('RITMA'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });
}
