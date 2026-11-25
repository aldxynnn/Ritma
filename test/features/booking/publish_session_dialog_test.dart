import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ritma/core/config/app_env.dart';
import 'package:ritma/core/config/app_env_provider.dart';
import 'package:ritma/core/demo/demo_sandbox_engine.dart';
import 'package:ritma/core/errors/app_failure.dart';
import 'package:ritma/core/result/result.dart';
import 'package:ritma/core/theme/ritma_spacing.dart';
import 'package:ritma/core/theme/ritma_theme.dart';
import 'package:ritma/features/auth/application/auth_providers.dart';
import 'package:ritma/features/auth/domain/auth_session_state.dart';
import 'package:ritma/features/auth/domain/workspace_context.dart';
import 'package:ritma/features/booking/application/booking_providers.dart';
import 'package:ritma/features/booking/domain/booking_models.dart';
import 'package:ritma/features/booking/domain/booking_repository.dart';
import 'package:ritma/features/booking/presentation/ops_schedule_roster_view.dart';
import 'package:ritma/features/organizations/application/organization_providers.dart';

void main() {
  const demoEnv = AppEnv(
    environment: AppEnvironment.dev,
    appName: 'RITMA',
    supabaseUrl: '',
    supabaseAnonKey: '',
    enableDebugLogging: false,
    enableDemoMode: true,
  );

  Future<ProviderContainer> signInOwner({
    BookingRepository? bookingRepo,
  }) async {
    final container = ProviderContainer(
      overrides: [
        appEnvProvider.overrideWithValue(demoEnv),
        if (bookingRepo != null)
          bookingRepositoryProvider.overrideWithValue(bookingRepo),
      ],
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
    double textScale = 1.0,
  }) {
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: RitmaTheme.dark(density: RitmaDensity.operations),
        home: MediaQuery(
          data: MediaQueryData(
            size: const Size(1280, 960),
            textScaler: TextScaler.linear(textScale),
          ),
          child: const Scaffold(body: OpsScheduleRosterView()),
        ),
      ),
    );
  }

  testWidgets(
    'publishes Yoga Flow session in a fresh org with 0 rooms and 0 class types and shows success SnackBar',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 960));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final container = await signInOwner();
      final orgRes = await container
          .read(organizationRepositoryProvider)!
          .createOrganizationWithOwner(
            name: 'Fresh Yoga Collective',
            slug: 'fresh-yoga-collective',
            businessType: 'studio',
            timezone: 'UTC',
            currencyCode: 'USD',
            firstBranchName: 'RITMA Central',
            firstBranchCode: 'CTR',
          );
      final newOrgId = orgRes.when(
        success: (id) => id,
        failure: (f) => throw StateError(f.message),
      );

      await container.read(authControllerProvider.notifier).refreshWorkspaces();
      final authed =
          container.read(authControllerProvider).asData!.value
              as AuthenticatedSession;
      final newOrgWs = authed.workspaces.firstWhere(
        (w) => w.organizationId == newOrgId,
      );
      container.read(activeWorkspaceProvider.notifier).select(newOrgWs);

      await tester.pumpWidget(wrapView(container: container));
      await tester.pumpAndSettle();

      await tester.tap(find.text('New Session'));
      await tester.pumpAndSettle();

      expect(find.text('New Class Session'), findsOneWidget);
      expect(
        find.widgetWithText(TextFormField, 'Room / Studio Name'),
        findsOneWidget,
      );
      expect(find.widgetWithText(TextFormField, 'Class Type'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Session Title'),
        'Yoga Flow',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Instructor Name'),
        'Maya Putri',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Capacity'),
        '10',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Credit Cost'),
        '1',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Publish Session'));
      await tester.pumpAndSettle();

      expect(find.text('New Class Session'), findsNothing);
      expect(find.text('Session "Yoga Flow" published.'), findsOneWidget);
      expect(find.text('Yoga Flow'), findsOneWidget);
      expect(find.textContaining('Maya Putri'), findsOneWidget);
      expect(find.text('0/10 booked'), findsOneWidget);
      expect(find.text('1 credit'), findsOneWidget);

      final engine = container.read(demoSandboxEngineProvider);
      final published = engine.classSessions.values.firstWhere(
        (s) => s.organizationId == newOrgId && s.title == 'Yoga Flow',
      );
      expect(published.instructorDisplayName, 'Maya Putri');
      expect(published.capacity, 10);
      expect(published.creditCost, 1);
      expect(published.waitlistEnabled, isTrue);
      expect(published.endsAt.difference(published.startsAt).inMinutes, 60);
    },
  );

  testWidgets(
    'publishes session in a seeded org with existing rooms and class types at 1.5x text scale without overflow',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 960));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final container = await signInOwner();
      final authed =
          container.read(authControllerProvider).asData!.value
              as AuthenticatedSession;
      final ownerWs = authed.workspaces.firstWhere(
        (w) => w.roleCode == 'org_owner',
      );
      container.read(activeWorkspaceProvider.notifier).select(ownerWs);

      await tester.pumpWidget(wrapView(container: container, textScale: 1.5));
      await tester.pumpAndSettle();

      await tester.tap(find.text('New Session'));
      await tester.pumpAndSettle();

      expect(find.text('Room / Studio'), findsOneWidget);
      expect(find.text('Class Type'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Session Title'),
        'Evening Yoga Flow',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Instructor Name'),
        'Maya Putri',
      );
      await tester.tap(find.text('Publish Session'));
      await tester.pumpAndSettle();

      expect(find.text('New Class Session'), findsNothing);
      expect(
        find.text('Session "Evening Yoga Flow" published.'),
        findsOneWidget,
      );
      expect(find.text('Evening Yoga Flow'), findsOneWidget);
    },
  );

  testWidgets(
    'branch-scoped manager on a branch with 0 rooms sees actionable setup warning and error instead of silent failure',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 960));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final container = await signInOwner();
      final authed =
          container.read(authControllerProvider).asData!.value
              as AuthenticatedSession;
      final ownerWs = authed.workspaces.firstWhere(
        (w) => w.roleCode == 'org_owner',
      );
      final emptyBranchRes = await container
          .read(organizationRepositoryProvider)!
          .createBranch(
            orgId: ownerWs.organizationId,
            name: 'Empty Satellite Branch',
            code: 'SAT',
          );
      final emptyBranch = emptyBranchRes.when(
        success: (b) => b,
        failure: (f) => throw StateError(f.message),
      );

      final branchMgrWs = WorkspaceContext(
        organizationId: ownerWs.organizationId,
        organizationName: ownerWs.organizationName,
        branchId: emptyBranch.id,
        branchName: emptyBranch.name,
        roleCode: 'branch_manager',
        roleDisplayName: 'Branch Manager',
        roleRank: 60,
        permissions: const <String>[
          'schedule.manage',
          'booking.read',
          'booking.manage',
        ],
      );
      container.read(activeWorkspaceProvider.notifier).select(branchMgrWs);

      await tester.pumpWidget(wrapView(container: container));
      await tester.pumpAndSettle();

      await tester.tap(find.text('New Session'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('No rooms are configured for this branch yet.'),
        findsOneWidget,
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Session Title'),
        'Yoga Flow',
      );
      await tester.tap(find.text('Publish Session'));
      await tester.pumpAndSettle();

      expect(find.text('New Class Session'), findsOneWidget);
      expect(
        find.textContaining('No active room exists for this branch.'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'displays backend error message visibly inside dialog when publish fails',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 960));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final fakeRepo = _SpyBookingRepository(
        onCreateFailure: const AppFailure.forbidden(
          message: 'Missing schedule.manage permission for this branch.',
        ),
      );
      final container = await signInOwner(bookingRepo: fakeRepo);
      final authed =
          container.read(authControllerProvider).asData!.value
              as AuthenticatedSession;
      final ownerWs = authed.workspaces.firstWhere(
        (w) => w.roleCode == 'org_owner',
      );
      container.read(activeWorkspaceProvider.notifier).select(ownerWs);

      await tester.pumpWidget(wrapView(container: container));
      await tester.pumpAndSettle();

      await tester.tap(find.text('New Session'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Session Title'),
        'Yoga Flow',
      );
      await tester.tap(find.text('Publish Session'));
      await tester.pumpAndSettle();

      expect(fakeRepo.createCalls, 1);
      expect(find.text('New Class Session'), findsOneWidget);
      expect(
        find.text('Missing schedule.manage permission for this branch.'),
        findsOneWidget,
      );
      expect(find.text('Publish Session'), findsOneWidget);
    },
  );

  testWidgets(
    'shows inline validation error and skips repository call when form input is invalid',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 960));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final spyRepo = _SpyBookingRepository();
      final container = await signInOwner(bookingRepo: spyRepo);
      final authed =
          container.read(authControllerProvider).asData!.value
              as AuthenticatedSession;
      final ownerWs = authed.workspaces.firstWhere(
        (w) => w.roleCode == 'org_owner',
      );
      container.read(activeWorkspaceProvider.notifier).select(ownerWs);

      await tester.pumpWidget(wrapView(container: container));
      await tester.pumpAndSettle();

      await tester.tap(find.text('New Session'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Session Title'),
        'Y',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Capacity'),
        '0',
      );
      await tester.tap(find.text('Publish Session'));
      await tester.pumpAndSettle();

      expect(spyRepo.createCalls, 0);
      expect(find.text('Enter at least 2 characters'), findsOneWidget);
      expect(find.text('Min 1'), findsOneWidget);
      expect(
        find.text('Please check the highlighted fields before publishing.'),
        findsOneWidget,
      );
    },
  );
}

class _SpyBookingRepository implements BookingRepository {
  _SpyBookingRepository({this.onCreateFailure});

  final AppFailure? onCreateFailure;
  int createCalls = 0;

  @override
  Future<Result<List<ClassSessionModel>>> fetchSessions({
    required String orgId,
    String? branchId,
  }) async => const Success<List<ClassSessionModel>>(<ClassSessionModel>[]);

  @override
  Future<Result<ClassSessionModel>> createClassSession({
    required String orgId,
    required String branchId,
    required String roomId,
    required String classTypeId,
    required String title,
    required DateTime startsAt,
    required DateTime endsAt,
    required int capacity,
    required int creditCost,
    required DateTime cancellationCutoffAt,
    bool waitlistEnabled = true,
    String? instructorUserId,
    String instructorDisplayName = '',
  }) async {
    createCalls += 1;
    if (onCreateFailure != null) {
      return Failure<ClassSessionModel>(onCreateFailure!);
    }
    return Success<ClassSessionModel>(
      ClassSessionModel(
        id: 'spy-session-1',
        organizationId: orgId,
        branchId: branchId,
        roomId: roomId,
        classTypeId: classTypeId,
        instructorUserId: instructorUserId,
        instructorDisplayName: instructorDisplayName,
        title: title,
        startsAt: startsAt,
        endsAt: endsAt,
        capacity: capacity,
        creditCost: creditCost,
        cancellationCutoffAt: cancellationCutoffAt,
        waitlistEnabled: waitlistEnabled,
      ),
    );
  }

  @override
  Future<Result<List<AssignableInstructor>>> fetchAssignableInstructors({
    required String orgId,
    String? branchId,
  }) async =>
      const Success<List<AssignableInstructor>>(<AssignableInstructor>[]);

  @override
  Future<Result<ClassSessionModel>> updateClassSession({
    required String orgId,
    required String sessionId,
    required String roomId,
    required String classTypeId,
    required String title,
    required DateTime startsAt,
    required DateTime endsAt,
    required int capacity,
    required int creditCost,
    required DateTime cancellationCutoffAt,
    required bool waitlistEnabled,
    String? instructorUserId,
    required String instructorDisplayName,
  }) async => Success<ClassSessionModel>(
    ClassSessionModel(
      id: sessionId,
      organizationId: orgId,
      branchId: 'b1',
      roomId: roomId,
      classTypeId: classTypeId,
      instructorUserId: instructorUserId,
      instructorDisplayName: instructorDisplayName,
      title: title,
      startsAt: startsAt,
      endsAt: endsAt,
      capacity: capacity,
      creditCost: creditCost,
      cancellationCutoffAt: cancellationCutoffAt,
      waitlistEnabled: waitlistEnabled,
    ),
  );

  @override
  Future<Result<void>> cancelClassSession({
    required String orgId,
    required String sessionId,
    String? reason,
  }) async => const Success<void>(null);

  @override
  Future<Result<List<ClassBookingModel>>> fetchMemberBookings({
    required String orgId,
    required String memberId,
  }) async => const Success<List<ClassBookingModel>>(<ClassBookingModel>[]);

  @override
  Future<Result<BookingActionOutcome>> bookClassSession({
    required String orgId,
    required String sessionId,
    required String memberId,
    required String idempotencyKey,
  }) async => throw UnimplementedError();

  @override
  Future<Result<CancelBookingOutcome>> cancelClassBooking({
    required String orgId,
    required String bookingId,
    String? reason,
  }) async => throw UnimplementedError();

  @override
  Future<Result<List<SessionRosterEntry>>> fetchSessionRoster({
    required String orgId,
    required String sessionId,
  }) async => const Success<List<SessionRosterEntry>>(<SessionRosterEntry>[]);

  @override
  Future<Result<void>> markAttendance({
    required String orgId,
    required String bookingId,
    required AttendanceStatus attendanceStatus,
  }) async => const Success<void>(null);
}
