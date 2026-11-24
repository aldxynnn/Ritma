import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:ritma/core/config/app_env.dart';
import 'package:ritma/core/config/app_env_provider.dart';
import 'package:ritma/core/theme/ritma_spacing.dart';
import 'package:ritma/core/theme/ritma_theme.dart';
import 'package:ritma/features/auth/application/auth_providers.dart';
import 'package:ritma/features/auth/domain/auth_session_state.dart';
import 'package:ritma/features/booking/presentation/ops_schedule_roster_view.dart';
import 'package:ritma/features/dashboard/presentation/ops_dashboard_view.dart';
import 'package:ritma/features/facility_access/presentation/front_desk_checkin_view.dart';
import 'package:ritma/features/facility_access/presentation/member_pass_view.dart';

void main() {
  const demoEnv = AppEnv(
    environment: AppEnvironment.dev,
    appName: 'RITMA',
    supabaseUrl: '',
    supabaseAnonKey: '',
    enableDebugLogging: false,
    enableDemoMode: true,
  );

  Future<ProviderContainer> signInOwner(WidgetTester tester) async {
    final container = ProviderContainer(
      overrides: [appEnvProvider.overrideWithValue(demoEnv)],
    );
    addTearDown(container.dispose);

    await container.read(authControllerProvider.future);
    await container
        .read(authControllerProvider.notifier)
        .signInWithEmail(email: 'owner@ritma.demo', password: 'RitmaDemo1!');
    return container;
  }

  Widget wrapView({
    required ProviderContainer container,
    required Widget child,
    required RitmaDensity density,
  }) {
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: RitmaTheme.dark(density: density),
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(1024, 900),
            textScaler: TextScaler.linear(1.5),
          ),
          child: Scaffold(body: child),
        ),
      ),
    );
  }

  testWidgets(
    'MemberPassView renders rotating QR code and separated credits without overflow in dark 1.5x mode',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1024, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final container = await signInOwner(tester);
      final authed =
          container.read(authControllerProvider).asData?.value
              as AuthenticatedSession;
      final memberWs = authed.workspaces.firstWhere(
        (w) => !w.isOperationsSurface,
      );
      container.read(activeWorkspaceProvider.notifier).select(memberWs);

      await tester.pumpWidget(
        wrapView(
          container: container,
          density: RitmaDensity.member,
          child: const MemberPassView(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(QrImageView), findsOneWidget);
      expect(find.text('Digital Access Pass'), findsOneWidget);
      expect(find.text('Class Credits'), findsOneWidget);
      expect(find.text('PT Credits'), findsOneWidget);
      expect(find.text('Rotate QR'), findsOneWidget);
    },
  );

  testWidgets(
    'Operations views (Dashboard, Front-Desk Check-In, Schedule Roster) render live data without overflow',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1024, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final container = await signInOwner(tester);
      final authed =
          container.read(authControllerProvider).asData?.value
              as AuthenticatedSession;
      final ownerWs = authed.workspaces.firstWhere(
        (w) => w.roleCode == 'org_owner',
      );
      container.read(activeWorkspaceProvider.notifier).select(ownerWs);

      await tester.pumpWidget(
        wrapView(
          container: container,
          density: RitmaDensity.operations,
          child: const LiveOpsDashboardView(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Active Members'), findsOneWidget);
      expect(find.text("Today's Gym Visits"), findsOneWidget);
      expect(find.text('Class Occupancy'), findsOneWidget);

      await tester.pumpWidget(
        wrapView(
          container: container,
          density: RitmaDensity.operations,
          child: const FrontDeskCheckInView(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Front-Desk Facility Check-In'), findsOneWidget);
      expect(find.text('Validate & Check In'), findsOneWidget);

      await tester.pumpWidget(
        wrapView(
          container: container,
          density: RitmaDensity.operations,
          child: const OpsScheduleRosterView(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Schedules & Live Roster'), findsOneWidget);
      expect(find.text('New Session'), findsOneWidget);
    },
  );
}
